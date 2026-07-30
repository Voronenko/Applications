SHELL := /bin/bash

ifndef GITHUB_TOKEN
  GITHUB_TOKEN := $(shell gh auth token 2>/dev/null || echo "")
endif

export GITHUB_TOKEN

APPS := \
	aider-desk \
	arduino \
	dbgate \
	logseq \
	mattermost \
	mqtt-explorer \
	obsidian \
	redis-insight \
	smplayer \
	teams-for-linux \
	veracrypt \
	zcode

.PHONY: all $(APPS)

all: $(APPS)

$(APPS):
	@bash appimage-updater/apps/$@.sh
