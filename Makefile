# BOF3 monorepo front door. Each submodule owns its build and checks.

.DEFAULT_GOAL := help

DECOMP := decomp
STATUS := status
TOOLS := $(DECOMP)/tools/bof3-tools
GAME_BUILD := $(DECOMP)/build/meson
BUILD_DIR := build

# Where cargo builds. The root BUILD_DIR is ignored by git.
export CARGO_TARGET_DIR ?= $(CURDIR)/$(BUILD_DIR)/rust

# Wall-clock limit of a cargo test run and the niced wrapper that applies it; the whole process
# tree ends when the limit passes.
TEST_TIMEOUT ?= 45m
TEST_RUN = timeout -k 30 $(TEST_TIMEOUT) nice -n 10

# Options of decomp/tools/setup.sh. --dev adds Ruff and pytest, which format-check and meson test need.
SETUP_ARGS ?= --dev

# Job count handed to decomp and the members: an explicit JOBS= wins, then `make -j N`, then every core.
DEFAULT_JOBS := $(shell nproc 2>/dev/null || echo 4)
ifneq (,$(filter -j%,$(MAKEFLAGS)))
JOBS ?= $(patsubst -j%,%,$(filter -j%,$(MAKEFLAGS)))
endif
JOBS := $(or $(JOBS),$(DEFAULT_JOBS))

.PHONY: help status sync init-game init-tools init-player init-status init-wiki setup build build-all build-tools build-player build-player-gui build-status test format lint wiki check check-all check-game check-game-free doctor check-game-free doctor check-tools check-player check-status clean distclean

help:
	@echo "BOF3 monorepo front door: $(CURDIR)"
	@echo ""
	@echo "Targets:"
	@echo "  help      List these targets (default)."
	@echo "  status    Show root and nested submodule revisions (no changes)."
	@echo "  sync      Explicitly update all members and nested tools to their pins."
	@echo "  setup     Initialize decomp, run its setup (needs your disc) and configure Meson."
	@echo "  build     Build decomp's 428 game images with Meson; checks run separately."
	@echo "  build-all Build game, tools, both player interfaces and status."
	@echo "  build-tools Build disc/archive tools."
	@echo "  build-player Build the CLI and terminal player."
	@echo "  build-player-gui Build the graphical player."
	@echo "  build-status Build the status site (Node/npm)."
	@echo "  test      Run disc/archive tool tests."
	@echo "  format    Format shared docs/config with system dprint; CHECK=1 checks."
	@echo "  lint      Lint disc/archive tools."
	@echo "  wiki      Build the wiki into wiki/dist (Node/npm)."
	@echo "  check     Check shared docs/config and build the wiki."
	@echo "  check-game-free Run the decomp gate that needs no disc (Meson pre-push)."
	@echo "  doctor    List the host tools each target needs and report the missing ones."
	@echo "  check-game/check-tools/check-player/check-status Check one project."
	@echo "  check-all Check shared docs and every project."
	@echo "  clean     Remove build output, scratch and caches here and in the members; keep the extracted disc."
	@echo "  distclean clean, then the Meson build, the venvs and the Rust build; run 'make setup' after."
	@echo ""
	@echo "Variables:"
	@echo "  JOBS=N          Parallel jobs (default: nproc; 'make -j N' sets it)."
	@echo "  SETUP_ARGS=...  Options of decomp/tools/setup.sh (default --dev); also --matching, --no-payloads."
	@echo "  CHECK=1         format: verify only."
	@echo "  TEST_TIMEOUT=D  Wall-clock limit of each cargo test run (default 45m)."

# Submodule handling lives in tools/submodules.sh.
init-game:
	@sh tools/submodules.sh init game

init-tools: init-game
	@sh tools/submodules.sh init tools

init-player:
	@sh tools/submodules.sh init player

init-status:
	@sh tools/submodules.sh init status

init-wiki:
	@sh tools/submodules.sh init wiki

status:
	@sh tools/submodules.sh status

# Explicit: this can move clean submodule checkouts back to their pins.
sync:
	@sh tools/submodules.sh sync

# Setup installs the toolchain and extracts the disc, then (re)configures Meson to see them.
setup: init-game
	sh $(DECOMP)/tools/setup.sh $(SETUP_ARGS)
	meson setup $(if $(wildcard $(GAME_BUILD)/build.ninja),--reconfigure) $(GAME_BUILD) $(DECOMP)

# Configure Meson once; `make setup` reconfigures it after the toolchain or disc changes.
$(GAME_BUILD)/build.ninja: | init-game
	meson setup $(GAME_BUILD) $(DECOMP)

build: $(GAME_BUILD)/build.ninja
	meson compile -C $(GAME_BUILD) -j $(JOBS)

build-all:
	$(MAKE) $(if $(filter -j%,$(MAKEFLAGS)),,-j$(JOBS)) JOBS=$(JOBS) build-tools build-player build-player-gui build build-status

build-tools: init-tools
	$(MAKE) -C $(TOOLS) build CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/rust"
	@sh tools/stage.sh tools

build-player: init-player
	$(MAKE) -C player build-cli CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/audio"
	@sh tools/stage.sh player

build-player-gui: init-player
	$(MAKE) -C player build-gui CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/audio"
	@sh tools/stage.sh player-gui

build-status: init-status
	$(MAKE) -C $(STATUS) build

test: init-tools
	$(TEST_RUN) $(MAKE) -C $(TOOLS) test CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/rust"

# Shared documentation and configuration. Each member owns its source formatting.
format:
	@command -v dprint >/dev/null 2>&1 || { echo "make: dprint is not installed. Run: bash tools/install/dprint.sh (then put ~/.local/bin on PATH)" >&2; exit 1; }
	dprint $(if $(CHECK),check,fmt)

lint: init-tools
	$(MAKE) -C $(TOOLS) lint CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/rust"

# Build the wiki submodule (Astro Starlight) into wiki/dist, which the wiki ignores.
# Needs Node.js 22.23.4 or later.
wiki: init-wiki
	cd wiki && npm ci && npm run check && npm run build

# Shared checks do not require the game, Rust, or Node toolchains.
check:
	$(MAKE) format CHECK=1
	$(MAKE) wiki

check-game: $(GAME_BUILD)/build.ninja
	meson compile -C $(GAME_BUILD) -j $(JOBS) check

# The decomp gate without a disc: after `make setup SETUP_ARGS="--dev --no-payloads"`.
check-game-free: $(GAME_BUILD)/build.ninja
	meson compile -C $(GAME_BUILD) -j $(JOBS) pre-push

doctor:
	@sh tools/doctor.sh

check-tools: init-tools
	$(MAKE) -C $(TOOLS) check CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/rust"

check-player: init-player
	$(MAKE) -C player check CARGO_TARGET_DIR="$(CURDIR)/$(BUILD_DIR)/audio"

check-status: init-status
	$(MAKE) -C $(STATUS) check

# Without an extracted disc the game gate is the disc-free one.
check-all:
	$(MAKE) check $(if $(wildcard $(DECOMP)/build/disc/BIN),check-game,check-game-free) check-tools check-player check-status

clean:
	@sh tools/clean.sh clean

distclean:
	@sh tools/clean.sh distclean
