VERSION := $(shell cat VERSION)
IMAGE   ?= ghcr.io/codeonym-oss/design-skills
BATS    ?= $(shell command -v bats 2>/dev/null || echo npx --yes bats@1.13.0)
DOCKER  ?= docker
# Integration tests run inside the image, against this checkout (same path, read-only).
RUN_IN   = $(DOCKER) run --rm --user $$(id -u):$$(id -g) -v $(CURDIR):$(CURDIR):ro -w /tmp

.PHONY: help build build-core build-full test test-unit test-core test-full test-bash32 lint clean-test

help:
	@echo "make build        build core + full images, tagged $(IMAGE):$(VERSION)-{core,full}"
	@echo "make test         unit tests (host) + integration tests (both images)"
	@echo "make test-unit    dispatcher/CLI/check-library tests on the host (needs bats or npx)"
	@echo "make test-core    integration tests in the core image"
	@echo "make test-full    integration tests in the full image (everything)"
	@echo "make test-bash32  unit tests under bash 3.2 (macOS compatibility of the host-side code)"
	@echo "make lint         shellcheck every script"

build: build-core build-full

build-core:
	$(DOCKER) build -f docker/Dockerfile --target core --build-arg VERSION=$(VERSION) -t $(IMAGE):$(VERSION)-core .

build-full:
	$(DOCKER) build -f docker/Dockerfile --target full --build-arg VERSION=$(VERSION) -t $(IMAGE):$(VERSION)-full .

test: test-unit test-core test-full

test-unit:
	$(BATS) tests/unit

test-core:
	$(RUN_IN) $(IMAGE):$(VERSION)-core bats --filter-tags '!full' $(CURDIR)/tests/integration

test-full:
	$(RUN_IN) $(IMAGE):$(VERSION)-full bats $(CURDIR)/tests/integration

test-bash32:
	$(DOCKER) run --rm -v $(CURDIR):/repo:ro -w /repo bash:3.2 sh -c \
	  'apk add -q --no-cache git >/dev/null && git clone -q --depth 1 -b v1.13.0 https://github.com/bats-core/bats-core /tmp/bats && /tmp/bats/bin/bats tests/unit/ds.bats tests/unit/ds-cli.bats tests/unit/check.bats'

lint:
	$(DOCKER) run --rm -v $(CURDIR):/repo:ro -w /repo koalaman/shellcheck:stable -x -S warning \
	  bin/ds lib/*.sh skills/*/scripts/*.sh
