# BOF3 workspace front door. Each submodule owns its build and checks.

.DEFAULT_GOAL := help

DECOMP := decomp
STATUS := status
TOOLS := $(DECOMP)/tools/bof3-tools
GAME_BUILD := $(DECOMP)/build/meson
BUILD_DIR := build

# Where cargo builds. The root BUILD_DIR is ignored by git.
export CARGO_TARGET_DIR ?= $(CURDIR)/$(BUILD_DIR)/rust

# Options of decomp/tools/setup.sh. --dev adds Ruff and pytest, which format-check and meson test need.
SETUP_ARGS ?= --dev

# Job count handed to decomp and the members: an explicit JOBS= wins, then `make -j N`, then every core.
DEFAULT_JOBS := $(shell nproc 2>/dev/null || echo 4)
ifneq (,$(filter -j%,$(MAKEFLAGS)))
JOBS ?= $(patsubst -j%,%,$(filter -j%,$(MAKEFLAGS)))
endif
JOBS := $(or $(JOBS),$(DEFAULT_JOBS))

.PHONY: help status sync init-game init-tools init-player init-status init-wiki setup build build-all build-tools build-player build-player-gui build-status format check check-all check-game check-game-free doctor check-tools check-player check-status clean distclean

help: ## List the targets (default).
	@echo "BOF3 workspace front door: $(CURDIR)"
	@awk -F':.*## ' '/^[a-z-]+:.*## /{printf "  %-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "Variables: JOBS=N (parallel jobs), SETUP_ARGS=... (setup.sh options, default --dev), CHECK=1 (format: verify only)."

# Submodule handling lives in tools/submodules.sh.
init-game: ## Clone decomp at its pinned commit.
	@sh tools/submodules.sh init game

init-tools: init-game ## Clone decomp and its nested bof3-tools.
	@sh tools/submodules.sh init tools

init-player: ## Clone the player.
	@sh tools/submodules.sh init player

init-status: ## Clone the status page.
	@sh tools/submodules.sh init status

init-wiki: ## Clone the wiki.
	@sh tools/submodules.sh init wiki

status: ## Show root and nested submodule revisions.
	@sh tools/submodules.sh status

# Explicit: this can move clean submodule checkouts back to their pins.
sync: ## Move all members and nested tools to their pins.
	@sh tools/submodules.sh sync

# Setup installs the toolchain and extracts the disc, then (re)configures Meson to see them.
setup: init-game ## Run the decomp setup (disc optional) and configure Meson.
	sh $(DECOMP)/tools/setup.sh $(SETUP_ARGS)
	meson setup $(if $(wildcard $(GAME_BUILD)/build.ninja),--reconfigure) $(GAME_BUILD) $(DECOMP)

# Configure Meson once; `make setup` reconfigures it after the toolchain or disc changes.
$(GAME_BUILD)/build.ninja: | init-game
	meson setup $(GAME_BUILD) $(DECOMP)

build: $(GAME_BUILD)/build.ninja ## Build decomp's game images with Meson.
	meson compile -C $(GAME_BUILD) -j $(JOBS)

build-all: ## Build the game, tools, both players and the status page.
	$(MAKE) $(if $(filter -j%,$(MAKEFLAGS)),,-j$(JOBS)) JOBS=$(JOBS) build-tools build-player build-player-gui build build-status

build-tools: init-tools ## Build the disc and archive tools.
	$(MAKE) -C $(TOOLS) build CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/rust"
	@sh tools/stage.sh tools

build-player: init-player ## Build the player CLI and terminal interface.
	$(MAKE) -C player build-cli CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/audio"
	@sh tools/stage.sh player

build-player-gui: init-player ## Build the graphical player.
	$(MAKE) -C player build-gui CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/audio"
	@sh tools/stage.sh player-gui

build-status: init-status ## Build the status page.
	cd $(STATUS) && npm ci && npm run build

# Shared documentation and configuration. Each member owns its source formatting.
format: ## Format shared docs and config with dprint.
	@command -v dprint >/dev/null 2>&1 || { echo "make: dprint is not installed. Run: bash tools/install/dprint.sh (then put ~/.local/bin on PATH)" >&2; exit 1; }
	dprint $(if $(CHECK),check,fmt)

# Needs dprint, Node, Python and Chrome; not the game or Rust toolchains.
check: init-wiki ## Check shared docs and config, and the wiki.
	$(MAKE) format CHECK=1
	cd wiki && npm ci && npm run check

check-game: $(GAME_BUILD)/build.ninja ## Run the full decomp gate (needs the disc).
	meson compile -C $(GAME_BUILD) -j $(JOBS) check

# The decomp gate without a disc: after `make setup SETUP_ARGS="--dev --no-payloads"`.
check-game-free: $(GAME_BUILD)/build.ninja ## Run the decomp gate that needs no disc.
	meson compile -C $(GAME_BUILD) -j $(JOBS) pre-push

doctor: ## Report the missing host tools.
	@sh tools/doctor.sh

check-tools: init-tools ## Check bof3-tools.
	$(MAKE) -C $(TOOLS) check CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/rust"

check-player: init-player ## Check the player.
	$(MAKE) -C player check CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/audio"

check-status: init-status ## Check the status page.
	cd $(STATUS) && npm ci && npm run check

# Without an extracted disc the game gate is the disc-free one.
check-all: ## Check the shared docs and every project.
	$(MAKE) check $(if $(wildcard $(DECOMP)/build/disc/BIN),check-game,check-game-free) check-tools check-player check-status

clean: ## Remove build output; keep the disc, venv and Rust builds.
	@sh tools/clean.sh clean

distclean: ## Clean, then remove Meson, the venvs and the Rust build.
	@sh tools/clean.sh distclean
