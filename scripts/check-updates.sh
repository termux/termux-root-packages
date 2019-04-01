#!/bin/bash
##
##  Script for checking package updates.
##
##  Leonid Plyushch <leonid.plyushch@gmail.com> (C) 2019
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

TERMUX_PACKAGES_BASEDIR=$(realpath "$(dirname "$0")/../")
DISPLAY_SOURCE_SHA256=false

print_divider() {
	if $DISPLAY_SOURCE_SHA256; then
		echo -e "\n================================================================\n" >&2
	else
		echo -e "\n==============================\n" >&2
	fi
}

compare_versions() {
	test "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n 1)" != "$1"
}

# Some packages have different name than actual in
# our repository. This should be fixed in order to
# be able get a latest version from the database.
#
# Some packages are custom and should not be
# checked for updates. These packages have translated
# name set to '/hidden/'.
translate_package_name() {
	local translated_name

	case "$1" in
		frida-server) translated_name="frida";;
		hping3) translated_name="hping";;
		chroot) translated_name="coreutils";;
		tshark) translated_name="wireshark";;
		libdevmapper) translated_name="lvm2";;
		libccid) translated_name="ccid";;
		libpcsclite) translated_name="pcsc-lite";;

		*) translated_name="$1";;
	esac

	echo "$translated_name"
}

# Source build.sh in order to execute code that it
# contains and print requested variable to stdout.
get_value_from_buildsh() {
	local package_name=$1
	local buildsh_property=$2

	if [ ! -f "$TERMUX_PACKAGES_BASEDIR/packages/$package_name/build.sh" ]; then
		echo "No build.sh found for '$package_name'." >&2
		return 1
	fi

	# Sourcing is done in subshell to prevent overwriting
	# variables in our environment.
	(set -o noglob
		if [ -e "$TERMUX_PACKAGES_BASEDIR/scripts/properties.sh" ]; then
			. "$TERMUX_PACKAGES_BASEDIR/scripts/properties.sh"
		fi
		. "$TERMUX_PACKAGES_BASEDIR/packages/$package_name/build.sh" 2>/dev/null

		if [ "$buildsh_property" = "TERMUX_PKG_SRCURL" ]; then
			local i
			for i in "${TERMUX_PKG_SRCURL[@]}"; do
				echo "$i"
			done
		else
			echo "${!buildsh_property}"
		fi
	)
}

# Program entry point.
check_packages_for_updates() {
	local package_name
	local available_packages
	local available_packages_count
	local -a updatable_packages
	local -A updatable_packages_data
	local progress_counter=0

	available_packages=$(find "$TERMUX_PACKAGES_BASEDIR/packages" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -n 1 basename)
	available_packages_count=$(echo "$available_packages" | wc -w)

	for package_name in $available_packages; do
		local package_current_version
		local package_latest_version
		local package_homepage

		echo -ne "\rProcessing packages: $((progress_counter * 100 / available_packages_count))%"

		# Search for packages in several repositories in order to retrieve latest
		# version. Search is stopped once we get package version.
		local repo
		for repo in arch aur alpine_edge linuxbrew debian_unstable freebsd openbsd gentoo_ovl_pentoo; do
			local translated_package_name
			translated_package_name=$(translate_package_name "$package_name")

			# Do not process packages that are hidden.
			if [ "$translated_package_name" = "/hidden/" ]; then
				package_latest_version="/hidden/"
				break
			fi

			local api_response
			api_response=$(curl --silent --location "https://repology.org/api/v1/metapackage/$translated_package_name")
			package_latest_version=$(echo "$api_response" | jq -r ".[] | select(.repo == \"$repo\" and .name == \"$translated_package_name\").version")

			if [ -z "$package_latest_version" ]; then
				package_latest_version=$(echo "$api_response" | jq -r ".[] | select(.repo == \"$repo\" and .name == \"$package_name\").version")
			fi

			if [ -n "$package_latest_version" ]; then
				break
			fi
		done

		# Do not process packages that are hidden.
		if [ "$package_latest_version" = "/hidden/" ]; then
			continue
		fi

		package_current_version=$(get_value_from_buildsh "$package_name" "TERMUX_PKG_VERSION")
		package_homepage=$(get_value_from_buildsh "$package_name" "TERMUX_PKG_HOMEPAGE")

		if [ -n "$package_current_version" ]; then
			if [ -z "$package_latest_version" ]; then
				# Some packages may not exist in the database,
				updatable_packages+=("$package_name")
				updatable_packages_data["${package_name}-version"]="@NO_VERSION@"
				updatable_packages_data["${package_name}-homepage"]="$package_homepage"
			else
				if compare_versions "$package_latest_version" "$package_current_version"; then
					# If we got version newer than in our repository, add package
					# information to the updates list.
					updatable_packages+=("$package_name")
					updatable_packages_data["${package_name}-version"]="$package_latest_version"

					if $DISPLAY_SOURCE_SHA256; then
						# Download source archives and compute SHA-256 checksums
						# if requested.

						# It is not possible to use 'get_value_from_buildsh()' here
						# since we need to modify build.sh file in order to get
						# correct link for latest sources.
						local package_src_urls
						package_src_urls=$(set -o noglob
								if [ -e "$TERMUX_PACKAGES_BASEDIR/scripts/properties.sh" ]; then
									. "$TERMUX_PACKAGES_BASEDIR/scripts/properties.sh"
								fi

								local new_ver_buildsh
								new_ver_buildsh=$(mktemp "/tmp/.build.sh.XXXXXXXX")

								cat "$TERMUX_PACKAGES_BASEDIR/packages/$package_name/build.sh" \
									> "$new_ver_buildsh"

								# Set custom TERMUX_PKG_VERSION.
								sed -i "s/^TERMUX_PKG_VERSION=/_TERMUX_PKG_VERSION=/g" \
									"$new_ver_buildsh"
								sed -i "/^_TERMUX_PKG_VERSION=.*/i TERMUX_PKG_VERSION=$package_latest_version" \
									"$new_ver_buildsh"

								. "$new_ver_buildsh" 2>/dev/null

								local i
								for i in "${TERMUX_PKG_SRCURL[@]}"; do
									echo "$i"
								done
						)

						if [ -n "$package_src_urls" ]; then
							updatable_packages_data["${package_name}-sha256"]=$(
								local url
								for url in $package_src_urls; do
									curl --silent --location "$url" | sha256sum - | awk '{ print $1 }'
								done
							)
						fi
					fi
				fi
			fi
		fi

		progress_counter=$((progress_counter + 1))
	done
	echo -ne "\\e[2K"

	print_divider

	# Just print our collected information about updates.
	for package_name in "${updatable_packages[@]}"; do
		echo "Package: $package_name" >&2

		if [ "${updatable_packages_data["${package_name}-version"]}" == "@NO_VERSION@" ]; then
			echo "Unable to get latest version." >&2
			echo "Please, check the homepage: ${updatable_packages_data["${package_name}-homepage"]}" >&2
		else
			echo "Latest version: ${updatable_packages_data["${package_name}-version"]}" >&2

			if $DISPLAY_SOURCE_SHA256 && [ -n "${updatable_packages_data["${package_name}-sha256"]}" ]; then
				echo >&2
				echo "Source SHA-256:" >&2

				local sha256
				for sha256 in ${updatable_packages_data["${package_name}-sha256"]}; do
					echo "$sha256"
				done
			fi
		fi

		print_divider
	done

	if [ "${#updatable_packages[@]}" = 0 ]; then
		echo "All packages seems up-to-date."
		print_divider
	fi
}

if [ $# -gt 0 ] && [ "$1" = "--sha256" ]; then
	DISPLAY_SOURCE_SHA256=true
fi

check_packages_for_updates
