LOCAL_VERSION = $(shell git describe --tags --always)
PACKAGE_VERSION ?= "0.0.0-${LOCAL_VERSION}"
PACKAGE_REPOSITORY ?= "caladreas/carvel-repo"
PACKAGE_REGISTRY ?= "index.docker.io"

#######################
### CARVEL REPO
repo-release:
	kctrl package repository release\
		--chdir repository \
		--version="${PACKAGE_VERSION}"\
		--yes

#######################
### GITSTAFETTE SERVER
gitstafette-server-imagelock-arm:
	mkdir -p packages/gitstafette-server/.imgpkg
	ytt -f packages/gitstafette-server/config | kbld -f - --platform linux/arm64 --imgpkg-lock-output packages/gitstafette-server/.imgpkg/images.yml

gitstafette-server-validate:
	ytt -f packages/gitstafette-server/test-data/values.yml \
		-f packages/gitstafette-server/config

gitstafette-server-release: gitstafette-server-validate gitstafette-server-imagelock-arm
	rm repository/packages/server.gitstafette.kearos.net/*.yml || true

	kctrl package release --version="${PACKAGE_VERSION}" \
		--tag="${PACKAGE_VERSION}" \
		--chdir packages/gitstafette-server \
		--repo-output ../../repository \
		--yes
#######################
### GITSTAFETTE CLIENT
gitstafette-client-imagelock-arm:
	mkdir -p packages/gitstafette-client/.imgpkg
	ytt -f packages/gitstafette-client/config | kbld -f - --platform linux/arm64 --imgpkg-lock-output packages/gitstafette-client/.imgpkg/images.yml

gitstafette-client-validate:
	ytt -f packages/gitstafette-client/test-data/values.yml \
		-f packages/gitstafette-client/config

gitstafette-client-release: gitstafette-client-validate gitstafette-client-imagelock-arm
	rm repository/packages/client.gitstafette.kearos.net/*.yml || true

	kctrl package release --version="${PACKAGE_VERSION}" \
		--tag="${PACKAGE_VERSION}" \
		--chdir packages/gitstafette-client \
		--repo-output ../../repository \
		--yes

