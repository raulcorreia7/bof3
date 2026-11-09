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

## Requirements

The workspace needs `git` and `make`. `make check` also needs
[dprint](https://github.com/dprint/dprint/releases/latest) and Node.js 22.23.4 or later.
On Linux x86-64, `bash tools/install/dprint.sh` installs the pinned dprint into `~/.local/bin`; put
that folder on `PATH`.

`make doctor` lists the host tools each target needs and which are missing. Each project's
`#requirements` section (linked below) lists what that project installs and where to get it.

## Set up

```sh
git clone https://github.com/raulcorreia7/bof3.git
cd bof3
make help
```

Clone without `--recurse-submodules`: a project's folder is empty until you initialize it.
`make init-<name>` clones one project at its pinned commit, with `<name>` one of `game`, `tools`,
`player`, `status` or `wiki`. Every build and check target runs the `init` it needs.
`git submodule update --init -- PATH` does the same for one folder.

## Choose a goal

Start in the project that owns the goal. Its README holds the requirements, set-up, build and run
steps.

| Goal                        | Project                                                    | Needs a disc | Initialize         | Start                                                                                                                                  |
| --------------------------- | ---------------------------------------------------------- | ------------ | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| Decompile a function        | [bof3-decomp](https://github.com/raulcorreia7/bof3-decomp) | Yes          | `make init-game`   | [Requirements](https://github.com/raulcorreia7/bof3-decomp#requirements), [Set up](https://github.com/raulcorreia7/bof3-decomp#set-up) |
| Extract or view game assets | [bof3-tools](https://github.com/raulcorreia7/bof3-tools)   | Yes          | `make init-tools`  | [Requirements](https://github.com/raulcorreia7/bof3-tools#requirements), [Set up](https://github.com/raulcorreia7/bof3-tools#set-up)   |
| Play the music and sound    | [bof3-player](https://github.com/raulcorreia7/bof3-player) | Yes          | `make init-player` | [Requirements](https://github.com/raulcorreia7/bof3-player#requirements), [Set up](https://github.com/raulcorreia7/bof3-player#set-up) |
| Read or edit the specs      | [bof3-wiki](https://raulcorreia7.github.io/bof3-wiki/)     | No           | `make init-wiki`   | [Requirements](https://github.com/raulcorreia7/bof3-wiki#requirements), [Set up](https://github.com/raulcorreia7/bof3-wiki#set-up)     |
| Work on the progress site   | [bof3-status](https://github.com/raulcorreia7/bof3-status) | No           | `make init-status` | [Requirements](https://github.com/raulcorreia7/bof3-status#requirements), [Set up](https://github.com/raulcorreia7/bof3-status#set-up) |

The disc is your own US copy: the Redump CUE sheet and its two BIN tracks. Each project that needs
it says where the files go.

## Build

```sh
make build-all         # every project
make build             # game images (Meson)
make build-tools       # bin/bof3 and bin/bof3-edit
make build-player      # CLI and terminal player
make build-player-gui  # graphical player
make build-status      # status site
make wiki              # wiki site
```

`make build-tools` and the player targets stage native binaries in `bin/`. Run those, not
`cargo run`. The root `Makefile` forwards to each project's own build and owns no build graph;
`make setup` runs the decomp set-up.

`make clean` removes build output and keeps the extracted disc. `make distclean` also removes the
Meson build, the virtual environments and the Rust build; run `make setup` afterwards.

## Check

```sh
make check         # shared docs and config formatting, wiki build
make check-game    # every game image against its retail SHA-1 (needs a disc)
make check-tools   # disc and archive tools
make check-player  # player and audio libraries
make check-status  # status site
make check-all     # all of the above
```

`make check-game-free` runs the game checks that need no disc, after
`make setup SETUP_ARGS="--dev --no-payloads"`.

`make format` formats the shared Markdown, JSON and TOML; `make format CHECK=1` verifies it.
Pull requests run `make check`. Each project owns its source formatting and CI.

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
