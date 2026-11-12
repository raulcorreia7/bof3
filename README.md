# bof3

[![CI](https://github.com/raulcorreia7/bof3/actions/workflows/docs.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3/actions/workflows/docs.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The workspace of the *Breath of Fire III* (US, PlayStation) projects: a matching decompilation, Rust
tools for discs, archives and assets, an audio player, a progress site and a specification wiki. Each
project is its own repository, pinned here as a Git submodule. This repository holds the shared
`make` entry point and the pins.

**No game data is included.** Dump your own US disc (Redump-verified CUE sheet and BIN tracks). This
is a fan project, not affiliated with or endorsed by Capcom. *Breath of Fire* is Capcom's trademark.

## Requirements

The workspace needs `git` and `make`. `make check` also needs
[dprint](https://github.com/dprint/dprint/releases/latest) and Node.js 22.23.4 or later.
On Linux x86-64, `bash tools/install/dprint.sh` installs the pinned dprint into `~/.local/bin`; put
that folder on `PATH`.

`make doctor` is a partial list of the host tools each target needs. Each project's `#requirements`
section (linked below) is the full list.

## Set up

```sh
git clone https://github.com/raulcorreia7/bof3.git
cd bof3
make help
```

Clone without `--recurse-submodules`: a project's folder is empty until you initialize it.
`make init-<name>` checks out one project at its pinned commit, with `<name>` one of `game`, `tools`,
`player`, `status` or `wiki`. `make init-tools` also initializes `decomp`, because the tools live
inside it. For a top-level member, `git submodule update --init -- PATH` does the same; it does not
reach `decomp/tools/bof3-tools`. Every build and check target runs the `init` it needs.

## Choose a goal

Start in the project that owns the goal. Its README holds the requirements, set-up, build and run
steps.

| Goal                        | Project                                                    | Folder                     | Needs a disc | Initialize         | Start                                                                                                                                  | Status                                                                                                                                                       |
| --------------------------- | ---------------------------------------------------------- | -------------------------- | ------------ | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Decompile a function        | [bof3-decomp](https://github.com/raulcorreia7/bof3-decomp) | `decomp/`                  | Yes          | `make init-game`   | [Requirements](https://github.com/raulcorreia7/bof3-decomp#requirements), [Set up](https://github.com/raulcorreia7/bof3-decomp#set-up) | [![CI](https://github.com/raulcorreia7/bof3-decomp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-decomp/actions)     |
| Extract or view game assets | [bof3-tools](https://github.com/raulcorreia7/bof3-tools)   | `decomp/tools/bof3-tools/` | Yes          | `make init-tools`  | [Requirements](https://github.com/raulcorreia7/bof3-tools#requirements), [Set up](https://github.com/raulcorreia7/bof3-tools#set-up)   | [![CI](https://github.com/raulcorreia7/bof3-tools/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-tools/actions)       |
| Play the music and sound    | [bof3-player](https://github.com/raulcorreia7/bof3-player) | `player/`                  | Yes          | `make init-player` | [Requirements](https://github.com/raulcorreia7/bof3-player#requirements), [Set up](https://github.com/raulcorreia7/bof3-player#set-up) | [![CI](https://github.com/raulcorreia7/bof3-player/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-player/actions)     |
| Read or edit the specs      | [bof3-wiki](https://raulcorreia7.github.io/bof3-wiki/)     | `wiki/`                    | No           | `make init-wiki`   | [Requirements](https://github.com/raulcorreia7/bof3-wiki#requirements), [Set up](https://github.com/raulcorreia7/bof3-wiki#set-up)     | [![Pages](https://github.com/raulcorreia7/bof3-wiki/actions/workflows/pages.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-wiki/actions)   |
| Work on the progress site   | [bof3-status](https://github.com/raulcorreia7/bof3-status) | `status/`                  | No           | `make init-status` | [Requirements](https://github.com/raulcorreia7/bof3-status#requirements), [Set up](https://github.com/raulcorreia7/bof3-status#set-up) | [![CI](https://github.com/raulcorreia7/bof3-status/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/raulcorreia7/bof3-status/actions) |

The disc is your own US copy: the Redump CUE sheet and its two BIN tracks. Each project that needs
it says where the files go.

## Build

```sh
make build-all         # game, tools, both players and status; not the wiki
make build             # game images (Meson)
make build-tools       # bin/bof3 and bin/bof3-edit
make build-player      # CLI and terminal player
make build-player-gui  # graphical player
make build-status      # status site
```

`make build-tools` and the player targets stage native binaries in `bin/`. Run those, not
`cargo run`. The root `Makefile` forwards to each project's own build and owns no build graph;
`make setup` runs the decomp set-up.

`make clean` removes Meson objects, the status site and workspace caches; it keeps the extracted
disc, `decomp/.venv`, `build/rust`, `build/audio` and the `bin/` links. `make distclean` also removes
`decomp/build/meson`, `decomp/.venv`, `build/rust`, `build/audio` and `status/node_modules`; run
`make setup` afterwards. The `bin/` links and `build/bof3-names.json` stay after `distclean`; the
links point at the removed builds.

## Check

`make check` checks the shared docs and config and builds the wiki; `make help` lists every target.
`make check-game` needs your disc, `make check-game-free` is the decomp gate without one (after
`make setup SETUP_ARGS="--dev --no-payloads --no-sdk"`), and `make check-tools`, `make check-player`
and `make check-status` cover one project each. `make check-all` runs them all. `make format` formats
the shared Markdown, JSON and TOML; `make format CHECK=1` verifies it. Pull requests run `make check`;
each project owns its source formatting and CI.

## Next

- [CONTRIBUTING.md](CONTRIBUTING.md): branch, gate, commit and pull request flow. Also the
  [code of conduct](CODE_OF_CONDUCT.md) and [security policy](SECURITY.md).
- [AGENTS.md](AGENTS.md): the same paths for a coding agent.
- [Project standard](docs/standard.md): the bar every project meets and the writing rules.
- [Wiki](https://raulcorreia7.github.io/bof3-wiki/): game and file-format specifications.

## Where to ask

Ask questions and share ideas in
[GitHub Discussions](https://github.com/raulcorreia7/bof3/discussions). Report
bugs as issues in the repository that owns the code. Report a security or conduct problem privately
([SECURITY.md](SECURITY.md)).

## License

MIT, except bof3-decomp, which uses CC0 1.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE). Each project
and third-party dependency keeps its own license and notices.
