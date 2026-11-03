# BOF3 workspace

A matching decompilation of *Breath of Fire III* (US, PlayStation), with Rust tools for
disc images, archives, assets and audio. The projects are independent Git submodules;
the [wiki](https://raulcorreia7.github.io/bof3-wiki/) holds the shared game and format documentation.

No game data is included. Dump your own US disc (Redump-verified CUE and BIN).
This is a fan project, not affiliated with or endorsed by Capcom.

## Names

The repository names and the folders in this workspace differ. This table maps them.

| Repository                                                 | Folder                     | What it is                                             |
| ---------------------------------------------------------- | -------------------------- | ------------------------------------------------------ |
| [bof3](https://github.com/raulcorreia7/bof3)               | `.`                        | Shared build entry points and the pins of the members. |
| [bof3-decomp](https://github.com/raulcorreia7/bof3-decomp) | `decomp/`                  | Readable C89 that builds to the retail bytes (CC0).    |
| [bof3-tools](https://github.com/raulcorreia7/bof3-tools)   | `decomp/tools/bof3-tools/` | Disc, EMI archive and asset tools; the `bof3` CLI.     |
| [bof3-player](https://github.com/raulcorreia7/bof3-player) | `player/`                  | Play, browse and export the game's music and sound.    |
| [bof3-status](https://github.com/raulcorreia7/bof3-status) | `status/`                  | Decompilation progress from the generated report.      |
| [bof3-wiki](https://raulcorreia7.github.io/bof3-wiki/)     | `wiki/`                    | Shared game and file-format facts.                     |

The tools build the `bof3` command. `make build-tools` installs it as `bin/bof3`; a plain
`cargo build --release` in the tools repository writes the same binary to `target/release/bof3`.

Rust: the tools and this workspace need 1.99 or later (`rust-toolchain.toml` pins 1.99.1); bof3-player
needs 1.88 or later.

## Your first change

Start with the smallest step that fits what you have:

1. Fix a docs page, here or in a member. `make check` verifies it.
2. Improve a [wiki](https://raulcorreia7.github.io/bof3-wiki/) page.
3. Add a Rust test to the [tools](https://github.com/raulcorreia7/bof3-tools) or the
   [player](https://github.com/raulcorreia7/bof3-player) (`make check-tools`, `make check-player`).
4. With a disc, match one function in bof3-decomp (`tools/match.sh`, then `check-<image>`).

Each member's contributor guide has the details:
[decomp](https://github.com/raulcorreia7/bof3-decomp/blob/main/CONTRIBUTING.md),
[tools](https://github.com/raulcorreia7/bof3-tools/blob/main/CONTRIBUTING.md),
[player](https://github.com/raulcorreia7/bof3-player/blob/main/CONTRIBUTING.md),
[status](https://github.com/raulcorreia7/bof3-status/blob/main/CONTRIBUTING.md),
[wiki](https://github.com/raulcorreia7/bof3-wiki/blob/main/CONTRIBUTING.md).

## Where to ask

Ask questions and share ideas in
[GitHub Discussions](https://github.com/raulcorreia7/bof3/discussions) once enabled. Report
bugs as issues in the repository that owns the code. Report a security or conduct problem privately
([SECURITY.md](SECURITY.md)).

## Get started

```sh
git clone https://github.com/raulcorreia7/bof3.git
cd bof3
make help
```

Submodules are cloned the first time a target needs them. Pick what you want to change:

| Contribution                  | Needs a disc | Run                                           | Owner                                                                           |
| ----------------------------- | ------------ | --------------------------------------------- | ------------------------------------------------------------------------------- |
| Game code, matching           | Yes          | `make setup && make build && make check-game` | [decomp](https://github.com/raulcorreia7/bof3-decomp/blob/main/CONTRIBUTING.md) |
| Disc, archive and asset tools | No           | `make build-tools && make check-tools`        | [bof3-tools](https://github.com/raulcorreia7/bof3-tools/blob/main/README.md)    |
| Music and sound player        | No           | `make check-player`                           | [player](https://github.com/raulcorreia7/bof3-player/blob/main/CONTRIBUTING.md) |
| Progress site                 | No           | `make check-status` (Node/npm)                | [status](https://github.com/raulcorreia7/bof3-status/blob/main/README.md)       |
| Game and format documentation | No           | `make check` (format check and wiki build)    | [wiki](https://raulcorreia7.github.io/bof3-wiki/)                               |

Host tools: `git`, `curl`, `7z`, a C compiler, Meson 1.3 or later with Ninja, `uv`
(`bash tools/install/host.sh game`) and Rust 1.99 or later. `check-tools` and `check-player` also
need `cargo install cargo-deny --locked`; the status site needs Node.js 22 or later. The full list,
with install commands, is in the [toolchain guide](https://github.com/raulcorreia7/bof3-decomp/blob/main/docs/toolchain.md#host-tools).

A game build needs your own complete US disc image: the Redump CUE sheet and its two BIN tracks.
Run `make init-game` to clone bof3-decomp and put the disc files in `decomp/inputs/external/` (see
[decomp/inputs](https://github.com/raulcorreia7/bof3-decomp/blob/main/inputs/README.md)). Then run `make setup`: it installs the pinned toolchain,
extracts the disc and configures Meson. `make check-game` then confirms that all 428 images match
the retail bytes.

Without a disc, `make setup SETUP_ARGS="--dev --no-payloads"` installs the toolchain, and
`meson compile -C decomp/build/meson check-tree include-asm` runs the checks that need no game data.
The tools, player, site and wiki build and check without game data.

`make status` shows submodule revisions. `make sync` moves all members and nested tools to their
pins, which can move clean submodule checkouts; setup and builds never do. `make build-all` builds
every project, and each project has its own target:

```sh
make build             # game images (Meson)
make build-tools       # disc/archive tools; bin/bof3
make build-player      # CLI and terminal player
make build-player-gui  # graphical player
make build-status      # status site; requires Node/npm
make wiki              # shared documentation
```

For the player alone, use the [bof3-player releases](https://github.com/raulcorreia7/bof3-player/releases)
or its [build instructions](https://github.com/raulcorreia7/bof3-player/blob/main/README.md#build-from-source). Each project's README lists its
prerequisites. To work inside a member without `make`, initialize it with
`git submodule update --init -- PATH`.

## Build ownership

The root `Makefile` forwards to the members; it owns no compiler or build graph. The game
repository owns its [Meson build](https://github.com/raulcorreia7/bof3-decomp/blob/main/docs/toolchain.md#how-the-build-works) and
`decomp/tools/setup.sh`, the Rust workspaces own their Cargo manifests, and the status site owns its
npm scripts. Root scripts: `tools/submodules.sh`, `tools/stage.sh` and `tools/clean.sh`.

`make clean` removes build output and keeps the extracted disc. `make distclean` also removes the
Meson build, the virtual environments and the Rust build; run `make setup` afterwards.

## Validate changes

Run the check for the project you changed:

```sh
make check         # shared docs/config formatting and wiki
make check-game    # every game image against its retail SHA-1 (needs a disc)
make check-tools   # disc/archive tools
make check-player  # player and audio libraries
make check-status  # status site; requires Node/npm
make check-all     # shared docs and all projects
```

`make format` formats shared Markdown, JSON and TOML; `CHECK=1` verifies it.
Each member owns its source formatting and checks.

Formatting needs the checksum-verified, pinned dprint release, with no Node/npm or Cargo build.
On Linux x86-64:

```sh
bash tools/install/dprint.sh
export PATH="$HOME/.local/bin:$PATH"
make format CHECK=1
```

Keep `$HOME/.local/bin` on `PATH` in your shell profile. On other platforms, install the matching
dprint release asset. `dprint.json` pins the formatter plugins. Rust uses rustfmt, C/C++ uses
clang-format and Python uses Ruff.

`bash tools/install/host.sh format|game|docs|analysis` installs the other pinned tools. The wiki
build and `make check` need the `docs` set: `bash tools/install/host.sh docs`.

Pull requests and manual CI runs run `make check`: the shared Markdown check and the wiki build.
Each member repository owns its CI; full game byte checks use the maintainer's disc.

Contributing: [CONTRIBUTING.md](CONTRIBUTING.md).
Agent guidance: [AGENTS.md](AGENTS.md).
First-party code is MIT licensed except for bof3-decomp, which uses CC0 1.0.
Each project and third-party dependency keeps its own license and notices.
