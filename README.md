# bof3

[![CI](https://github.com/raulcorreia7/bof3/actions/workflows/docs.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3/actions/workflows/docs.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The workspace of the *Breath of Fire III* (US, PlayStation) projects: a matching decompilation, Rust
tools for discs, archives and assets, an audio player, a progress site and a specification wiki. Each
project is its own repository, pinned here as a Git submodule. This repository holds the shared
`make` entry point and the pins.

**No game data is included.** Dump your own US disc (Redump-verified CUE sheet and BIN tracks). This
is a fan project, not affiliated with or endorsed by Capcom. *Breath of Fire* is Capcom's trademark.

## Projects

| Project                                                    | Folder                     | What it is                                             | Status                                                                                                                                                       |
| ---------------------------------------------------------- | -------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [bof3-decomp](https://github.com/raulcorreia7/bof3-decomp) | `decomp/`                  | Readable C89 that builds to the retail bytes (CC0).    | [![CI](https://github.com/raulcorreia7/bof3-decomp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-decomp/actions)     |
| [bof3-tools](https://github.com/raulcorreia7/bof3-tools)   | `decomp/tools/bof3-tools/` | Disc, EMI archive and asset tools; the `bof3` command. | [![CI](https://github.com/raulcorreia7/bof3-tools/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-tools/actions)       |
| [bof3-player](https://github.com/raulcorreia7/bof3-player) | `player/`                  | Play, browse and export the game's music and sound.    | [![CI](https://github.com/raulcorreia7/bof3-player/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-player/actions)     |
| [bof3-status](https://github.com/raulcorreia7/bof3-status) | `status/`                  | Decompilation progress from the generated report.      | [![CI](https://github.com/raulcorreia7/bof3-status/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-status/actions) |
| [bof3-wiki](https://raulcorreia7.github.io/bof3-wiki/)     | `wiki/`                    | Shared game and file-format facts.                     | [![Pages](https://github.com/raulcorreia7/bof3-wiki/actions/workflows/pages.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-wiki/actions)   |

`make build-tools` builds the `bof3` command and installs it as `bin/bof3`.

## Quick start

```sh
git clone https://github.com/raulcorreia7/bof3.git
cd bof3
make help
```

Do not pass `--recurse-submodules`: it also fetches nested pins the build
never reads. `make` clones the submodule a target needs the first time you run it. To work in a member without
`make`, run `git submodule update --init -- PATH`. `make doctor` lists the host tools each target
needs and which are missing.

Pick what you want to change:

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
with install commands, is in the
[toolchain guide](https://github.com/raulcorreia7/bof3-decomp/blob/main/docs/toolchain.md#host-tools).

A game build needs your own complete US disc image: the Redump CUE sheet and its two BIN tracks.
Run `make init-game` to clone bof3-decomp and put the disc files in `decomp/inputs/external/` (see
[decomp/inputs](https://github.com/raulcorreia7/bof3-decomp/blob/main/inputs/README.md)). Then run
`make setup`: it installs the pinned toolchain, extracts the disc and configures Meson. `make check-game` then confirms that all 428 images match
the retail bytes.

Without a disc, `make setup SETUP_ARGS="--dev --no-payloads"` installs the toolchain, and
`make check-game-free` runs the checks that need no game data (Meson `pre-push`).
The tools, player, site and wiki build and check without game data.

`make build-all` builds every project, and each project has its own target:

```sh
make build             # game images (Meson)
make build-tools       # disc/archive tools; bin/bof3
make build-player      # CLI and terminal player
make build-player-gui  # graphical player
make build-status      # status site; requires Node/npm
make wiki              # shared documentation
```

For the player alone, use the [bof3-player releases](https://github.com/raulcorreia7/bof3-player/releases)
or its [install instructions](https://github.com/raulcorreia7/bof3-player/blob/main/README.md#install).
Each project's README lists its prerequisites.

## Build ownership

The root `Makefile` forwards to the members; it owns no compiler or build graph. bof3-decomp owns
its [Meson build](https://github.com/raulcorreia7/bof3-decomp/blob/main/docs/toolchain.md#how-the-build-works)
and `decomp/tools/setup.sh`, the Rust workspaces own their Cargo manifests, and the status site owns its
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

`bash tools/install/host.sh format|game|analysis` installs the other pinned tools. The wiki build
and `make check` need Node.js 22.23.4 or later.

Pull requests and manual CI runs run `make check`: the shared Markdown check and the wiki build.
Each member repository owns its CI; full game byte checks use the maintainer's disc.

## Update the submodules

`make status` shows every submodule revision. `make sync` moves all members and the nested tools to
the pins recorded here; it can move clean submodule checkouts, and setup and builds never do.

To take a member's newest `main` and record it as the new pin:

```sh
git submodule update --remote --merge -- player   # or decomp, status, wiki
git add player
git commit -m "chore(submodules): update player"
```

Change a pin only after the member's commit is on its `main`. The pin of the tools lives in
bof3-decomp (`decomp/tools/bof3-tools`).

## Your first change

Start with the smallest step that fits what you have:

1. Fix a docs page, here or in a member. `make check` verifies it.
2. Improve a [wiki](https://raulcorreia7.github.io/bof3-wiki/) page.
3. Add a Rust test to the [tools](https://github.com/raulcorreia7/bof3-tools) or the
   [player](https://github.com/raulcorreia7/bof3-player) (`make check-tools`, `make check-player`).
4. With a disc, match one function in bof3-decomp (`decomp/tools/match.sh`, then `check-<image>`).

Each member's contributor guide has the details:
[decomp](https://github.com/raulcorreia7/bof3-decomp/blob/main/CONTRIBUTING.md),
[tools](https://github.com/raulcorreia7/bof3-tools/blob/main/CONTRIBUTING.md),
[player](https://github.com/raulcorreia7/bof3-player/blob/main/CONTRIBUTING.md),
[status](https://github.com/raulcorreia7/bof3-status/blob/main/CONTRIBUTING.md),
[wiki](https://github.com/raulcorreia7/bof3-wiki/blob/main/CONTRIBUTING.md).

## Where to ask

Ask questions and share ideas in
[GitHub Discussions](https://github.com/raulcorreia7/bof3/discussions). Report
bugs as issues in the repository that owns the code. Report a security or conduct problem privately
([SECURITY.md](SECURITY.md)).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md), the [code of conduct](CODE_OF_CONDUCT.md) and the
[security policy](SECURITY.md). Agent guidance is in [AGENTS.md](AGENTS.md).

## License

MIT, except bof3-decomp, which uses CC0 1.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE). Each project
and third-party dependency keeps its own license and notices.
