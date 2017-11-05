#!/bin/sh
set -e -u

HOME=/home/builder
if [ `uname` = Darwin ]; then
	# Workaround for mac readlink not supporting -f.
	REPOROOT=$PWD
else
	REPOROOT="$(dirname $(readlink -f $0))/../"
fi

IMAGE_NAME=termux/package-builder
CONTAINER_NAME=termux-package-builder

USER=builder

echo "Running container '$CONTAINER_NAME' from image '$IMAGE_NAME'..."

docker start $CONTAINER_NAME > /dev/null 2> /dev/null || {
	echo "Creating new container..."
	docker run \
	       --detach \
	       --env HOME=$HOME \
	       --name $CONTAINER_NAME \
	       --volume $REPOROOT:$HOME/termux-root-packages \
	       --tty \
	       $IMAGE_NAME
	if [ $(id -u) -ne 1000 -a $(id -u) -ne 0 ]
	then
		echo "Changed builder uid/gid... (this may take a while)"
		docker exec --tty $CONTAINER_NAME chown -R $(id -u) $HOME
		docker exec --tty $CONTAINER_NAME chown -R $(id -u) /data
		docker exec --tty $CONTAINER_NAME usermod -u $(id -u) builder
		docker exec --tty $CONTAINER_NAME groupmod -g $(id -g) builder
	fi
}

if [ "$#" -eq  "0" ]; then
	docker exec --interactive --tty --user $USER $CONTAINER_NAME bash
else
	docker exec --interactive --tty --user $USER $CONTAINER_NAME $@
fi


