#!/usr/bin/env python3.7
##
##  Package uploader for Bintray.
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

import fnmatch
import getopt
import json
import os
import sys

try:
    import requests
except ModuleNotFoundError:
    print("[!] Please, install 'requests' python module.")
    sys.exit(1)

# Repository configuration.
REPO_NAME = "science-packages"
REPO_GITHUB = "grimler91/science-packages"
REPO_DISTRIBUTION = "science"
REPO_COMPONENT = "stable"

# This variable is determined automatically.
TERMUX_PACKAGES_BASEDIR = None


class PackageMetadata():
    """Represents metadata structure used by Bintray."""

    def __init__(self, build_script_path):
        if not os.path.exists(build_script_path):
            print(f"[!] File {build_script_path} is not exist.")
            sys.exit(1)

        if os.path.basename(build_script_path) != "build.sh":
            print(f"[!] File '{build_script_path}' is not a build script.")
            sys.exit(1)

        package_name = os.path.basename(os.path.dirname(build_script_path))

        self.name = package_name
        self.desc = None
        self.licenses = None
        self.vcs_url = f"https://github.com/{REPO_GITHUB}"
        self.website_url = None
        self.issue_tracker_url = f"https://github.com/{REPO_GITHUB}/issues"
        self.github_repo = f"{REPO_GITHUB}"
        self.public_download_numbers = True
        self.public_stats = False

        with open(build_script_path, "r") as build_script:
            for line in build_script:
                if line.startswith("TERMUX_PKG_LICENSE"):
                    self.licenses = [l.strip(' ') for l in self.get_value(line, "TERMUX_PKG_LICENSE").split(",")]

                if line.startswith("TERMUX_PKG_DESCRIPTION"):
                    self.desc = self.get_value(line, "TERMUX_PKG_DESCRIPTION")

                if line.startswith("TERMUX_PKG_HOMEPAGE"):
                    self.website_url = self.get_value(line, "TERMUX_PKG_HOMEPAGE")

                if line.startswith("TERMUX_PKG_VERSION"):
                    self.version = self.get_value(line, "TERMUX_PKG_VERSION")

                if line.startswith("TERMUX_PKG_REVISION"):
                    self.version = "{}-{}".format(self.version, self.get_value(line, "TERMUX_PKG_REVISION"))

        if not self.licenses:
            print(f"[!] No license for package '{package_name}'.")
            sys.exit(1)

        if not self.website_url:
            print(f"[!] No homepage for package '{package_name}'.")
            sys.exit(1)

        if not self.desc:
            print(f"[!] No description for package '{package_name}'.")
            sys.exit(1)

        if not self.version:
            print(f"[!] No version for package '{package_name}'.")
            sys.exit(1)

    def get_value(self, string, key):
        value = string.split(f"{key}=")[1]

        for char in "\"'\n":
            value = value.replace(char, '')

        return value

    def dump(self):
        return self.__dict__


def req_delete_package(session, metadata):
    """Process request for deleting package."""

    print(f"[@] Deleting published package '{metadata.name}' from remote... ", end="", flush=True)
    response = session.delete(f"https://api.bintray.com/packages/{session.auth[0]}/{REPO_NAME}/{metadata.name}")

    if response.status_code == 200:
        print("done")
    elif response.status_code == 404:
        print("no-need")
    else:
        print("failure")
        print(f"[!] {response.json()['message']}.")
        sys.exit(1)


def req_upload_package(session, metadata, debfiles_dir):
    """Process request for uploading package."""

    debfiles_catalog = dict()

    for arch in ['all', 'aarch64', 'arm', 'i686', 'x86_64']:
        debfiles = set()

        # Regular package.
        debfiles.add(f"{metadata.name}_{metadata.version}_{arch}.deb")

        # Development package.
        debfiles.add(f"{metadata.name}-dev_{metadata.version}_{arch}.deb")

        # Discover subpackages.
        for file in os.listdir(os.path.join(TERMUX_PACKAGES_BASEDIR, "packages", metadata.name)):
            if fnmatch.fnmatch(file, "*.subpackage.sh"):
                package_name = file.split(".subpackage.sh")[0]
                package_file_name = f"{package_name}_{metadata.version}_{arch}.deb"
                debfiles.add(package_file_name)

        # Filter out nonexistent files.
        for file in debfiles.copy():
            file_path = os.path.join(debfiles_dir, file)

            if not os.path.exists(file_path):
                debfiles.discard(file)

        # Finally append list to catalog.
        debfiles_catalog[arch] = debfiles

    # Purge empty sets from catalog.
    for arch in debfiles_catalog.copy():
        if not debfiles_catalog[arch]:
            debfiles_catalog.pop(arch)

    # Verify that our catalog is not empty.
    if not debfiles_catalog:
        print("[!] No *.deb files to upload.")
        sys.exit(1)

    # Delete entry for package (with all related debfiles).
    req_delete_package(session, metadata)

    # Create new entry for package.
    print(f"[@] Creating new entry for package '{metadata.name}'... ", end="", flush=True)
    response = session.post(f"https://api.bintray.com/packages/{session.auth[0]}/{REPO_NAME}",
                            json=metadata.dump())
    if response.status_code == 201:
        print("done")
    elif response.status_code == 409:
        print("unchanged")
    else:
        print("failure")
        print(f"[!] {response.json()['message']}.")
        sys.exit(1)

    # Go through catalog and upload things.
    for arch, debfile_list in debfiles_catalog.items():
        session.headers.update({
            "X-Bintray-Debian-Distribution": REPO_DISTRIBUTION,
            "X-Bintray-Debian-Component": REPO_COMPONENT,
            "X-Bintray-Debian-Architecture": arch
        })

        for debfile in sorted(debfile_list):
            debfile_path = os.path.join(debfiles_dir, debfile)

            with open(debfile_path, "rb") as data_stream:
                print(f"[*]   Uploading '{debfile}'... ", end="", flush=True)

                response = session.put(f"https://api.bintray.com/content/{session.auth[0]}/{REPO_NAME}/{metadata.name}/{metadata.version}/{arch}/{debfile};publish=1",
                                       data=data_stream)

                if response.status_code == 201:
                    print("done")
                elif response.status_code == 409:
                    print("unchanged")
                else:
                    print("failure")
                    print(f"[!] {response.json()['message']}.")
                    sys.exit(1)

    print(f"[@] Finished publication of package '{metadata.name}'.")

def req_sign_repo(session, gpg_passphrase):
    """Sign bintray repo."""

    session.headers.update({
        "X-GPG-PASSPHRASE": gpg_passphrase
    })

    print(f"[@] Signing repository... ", end="", flush=True)

    # Send a request to trigger repo signing
    response = session.post(f"https://api.bintray.com/calc_metadata/{session.auth[0]}/{REPO_NAME}")

    if response.status_code == 202:
        print("done")
    else:
        print("failure")
        print(f"[!] {response.json()['message']}.")
        sys.exit(1)

def show_usage():
    """Print information about usage."""

    script_name = os.path.basename(sys.argv[0])

    print(f"\nUsage: {script_name} [OPTIONS] [package name] ...\n"
          "\n"
          "Package uploader script for Bintray.\n"
          "\n"
          "Options:\n"
          "\n"
          "  -d, --delete    Delete package instead of uploading.\n"
          "\n"
          "  -h, --help      Print this help.\n"
          "\n"
          "  -p, --path      Override path to directory with\n"
          "                  the *.deb files.\n"
          "\n"
          "Credentials are specified via environment variables:\n"
          "\n"
          "  BINTRAY_USERNAME  - User or organization name.\n"
          "  BINTRAY_API_KEY   - API key.\n")


def main():
    """Handle command line arguments."""

    delete_package = False
    debfiles_dir = os.path.join(TERMUX_PACKAGES_BASEDIR, "debs")

    if len(sys.argv) == 1:
        show_usage()
        sys.exit(1)

    try:
        options, args = getopt.getopt(sys.argv[1:], "dhp:",
                                      ['delete', 'help', 'path='])
    except getopt.GetoptError as err:
        print(f"[!] Error: {err}.")
        sys.exit(1)

    for opt, value in options:
        if opt in ('-d', '--delete'):
            delete_package = True
        elif opt in ('-h', '--help'):
            show_usage()
            sys.exit(0)
        elif opt in ('-p', '--path'):
            debfiles_dir = value
        else:
            print("[!] Error while parsing options.")
            sys.exit(1)

    if not args:
        print("[!] You have to specify package name(s).")
        sys.exit(1)

    # Obtain authentication credentials.
    try:
        bintray_user = os.environ['BINTRAY_USERNAME']
    except:
        print("[!] Environment variable 'BINTRAY_USERNAME' is not set.")
        sys.exit(1)
    try:
        bintray_api_key = os.environ['BINTRAY_API_KEY']
    except:
        print("[!] Environment variable 'BINTRAY_API_KEY' is not set.")
        sys.exit(1)
    try:
        gpg_passphrase = os.environ['GPG_PASSPHRASE']
    except:
        print("[@] Environment variable 'GPG_PASSPHRASE' is not set. Repository will not be signed.")

    # Process all specified packages.
    for package_name in args:
        build_script_path = os.path.join(TERMUX_PACKAGES_BASEDIR, "packages",
                                         package_name, "build.sh")

        metadata = None
        if os.path.exists(build_script_path):
            metadata = PackageMetadata(build_script_path)
        else:
            print(f"[!] Package '{package_name}' does not exist.")
            sys.exit(1)

        http_session = requests.Session()
        http_session.auth = (bintray_user, bintray_api_key)

        if delete_package:
            req_delete_package(http_session, metadata)
        else:
            req_upload_package(http_session, metadata, debfiles_dir)

    if gpg_passphrase:
        http_session = requests.Session()
        http_session.auth = (bintray_user, bintray_api_key)
        req_sign_repo(http_session, gpg_passphrase)

    sys.exit(0)

if __name__ == "__main__":
    # Obtain absolute path to the Termux packages repository.
    # (this script was launched from Termux repository, right ??)
    script_dir = os.path.dirname(os.path.realpath(sys.argv[0]))
    TERMUX_PACKAGES_BASEDIR = os.path.realpath(os.path.join(script_dir, "../"))

    if not os.path.exists(os.path.join(TERMUX_PACKAGES_BASEDIR, "packages")):
        print("[!] Cannot find packages directory.")
        sys.exit(1)
    else:
        main()
