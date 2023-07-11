#!/bin/bash

doesImageExist=$(docker image ls guru/dev.srv.uk --format="true")
if [ "$doesImageExist" == "true" ]; then
	echo "Image guru/dev.srv.uk exists"
else
	make build
fi
unset doesImageExist

#export localgateway
#localgateway=$(ip r | grep -Pom 1 '[0-9.]{7,15}')

if test -f "$HOME/.ssh/id_rsa"; then
	export SSHKEYPATH="/localhost/.ssh/id_rsa"
fi

if test -f "$HOME/.ssh/id_ed25519"; then
	export SSHKEYPATH="/localhost/.ssh/id_ed25519"
fi

docker run -it --rm \
	--name=ivendi-geodesic-dev \
	--dns-opt="timeout:1 attempts:1 rotate" \
	--env=LS_COLORS \
	--env=TERM \
	--env=TERM_COLOR \
	--env=TERM_PROGRAM \
    --volume=$HOME:/localhost \
	--volume="$HOME/.aws":/localhost/.aws:ro \
	--volume="$HOME/.ssh":/localhost/.ssh:ro \
	--volume="$PWD":/conf \
	--volume="/usr/local/bin/tfenv":/localhost/tfenv \
	--env=LOCAL_HOME=/localhost \
	--privileged \
	--publish 37049:37049 \
	--env=GEODESIC_PORT=37049 \
	--env=DOCKER_IMAGE=ivendi/dev.ivsrv.uk \
	--env=GEODESIC_WORKDIR="/conf" \
	--env=GEODESIC_HOST_CWD="$PWD" \
	--env=SSH_KEY="$SSHKEYPATH" \
	guru/dev.srv.uk

# docker run -it --rm --name=guru-geodesic-dev \
#  --volume $HOME:/localhost \
#     guru/dev.srv.uk
