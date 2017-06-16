NS=emacski
REPO=k8s-fluentd
VERSION?=latest

GIT_URL?=none
GIT_COMMIT?=none

.PHONY: build push shell run _validate-release release clean

build:
	docker build --pull \
	--build-arg GIT_URL=$(GIT_URL) \
	--build-arg GIT_COMMIT=$(GIT_COMMIT) \
	-t $(NS)/$(REPO):$(VERSION) .

push:
	docker push $(NS)/$(REPO):$(VERSION)

shell:
	docker run --rm -ti --entrypoint /bin/bash $(NS)/$(REPO):$(VERSION)

run:
	docker run --rm -ti $(NS)/$(REPO):$(VERSION)

_validate-release:
ifeq ($(VERSION),latest)
	$(error VERSION must be specified for release and not be 'latest')
endif

release: _validate-release build push
	# set latest tag to current release
	docker tag $(NS)/$(REPO):$(VERSION) $(NS)/$(REPO):latest
	docker push $(NS)/$(REPO):latest

clean:
	@docker image prune -f
	@docker images -f "label=image.name=$(REPO)" | grep "none" && \
	docker rmi $$(docker images -f "label=image.name=$(REPO)" | grep "none" | awk '{print $$3}') || \
	exit 0

default: build
