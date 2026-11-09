# Agent guidance

This is the workspace of the *Breath of Fire III* (PS1) projects. Each project is a Git submodule
with its own `AGENTS.md`, checks and commits. Work in the project that owns the change: read its
`AGENTS.md`, then its `README.md`.

## Where things are

Paths are relative to this folder. A member folder is empty until you initialize it: run
`make init-<name>` (for example `make init-game`) or `git submodule update --init <path>`.

| Path                       | Project                                    | Agent guide                                                            | Repository                                                 |
| -------------------------- | ------------------------------------------ | ---------------------------------------------------------------------- | ---------------------------------------------------------- |
| `decomp/`                  | Matching decompilation (C89, GCC 2.7.2)    | [decomp/AGENTS.md](decomp/AGENTS.md)                                   | [bof3-decomp](https://github.com/raulcorreia7/bof3-decomp) |
| `decomp/tools/bof3-tools/` | Rust disc and EMI archive tools (`bof3`)   | [decomp/tools/bof3-tools/AGENTS.md](decomp/tools/bof3-tools/AGENTS.md) | [bof3-tools](https://github.com/raulcorreia7/bof3-tools)   |
| `player/`                  | Audio player and Rust audio crates         | [player/AGENTS.md](player/AGENTS.md)                                   | [bof3-player](https://github.com/raulcorreia7/bof3-player) |
| `status/`                  | Progress site                              | [status/AGENTS.md](status/AGENTS.md)                                   | [bof3-status](https://github.com/raulcorreia7/bof3-status) |
| `wiki/`                    | Game and file-format specs                 | [wiki/AGENTS.md](wiki/AGENTS.md)                                       | [bof3-wiki](https://github.com/raulcorreia7/bof3-wiki)     |
| `docs/standard.md`         | The bar every project meets                | [project standard](docs/standard.md)                                   | this repository                                            |
| `Makefile`, `tools/`       | Workspace front door and submodule scripts | `make help`                                                            | this repository                                            |

## Find the guide for a task

| Task                                       | Read first                                                                                                        |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| Match, name or restructure game code       | [decomp/AGENTS.md](decomp/AGENTS.md), then [the `decomp` skill](decomp/.agents/skills/decomp/SKILL.md)            |
| Build setup, toolchain, Meson              | [decomp/docs/toolchain.md](decomp/docs/toolchain.md)                                                              |
| Disc or EMI extraction, the `bof3` command | [decomp/tools/bof3-tools/AGENTS.md](decomp/tools/bof3-tools/AGENTS.md)                                            |
| Music, sound, the player                   | [player/AGENTS.md](player/AGENTS.md)                                                                              |
| The progress page                          | [status/AGENTS.md](status/AGENTS.md)                                                                              |
| A game or file-format fact                 | [wiki/AGENTS.md](wiki/AGENTS.md) to edit; the [published wiki](https://raulcorreia7.github.io/bof3-wiki/) to read |
| Workspace builds, submodules, shared docs  | [README.md](README.md), [CONTRIBUTING.md](CONTRIBUTING.md), `make help`                                           |

## Checks

- `make doctor` lists the host tools each target needs; the README `#requirements` section of each project says how to install them.
- `make check` checks the shared docs and config and builds the wiki.
- `make check-<game|tools|player|status>` runs one project's checks; `make check-all` runs them all.
- Each project's own guide names its full gate; run that gate inside the project before a report.

## Rules

- Each submodule owns its commits and checks. Change a parent pin only after the child commit is on
  the child's `main`.
- Preserve unrelated changes and the existing submodule pins.
- Keep game data, build output and local backups outside the tracked tree.
- Update generated files through their generator.

## Index

Everything an agent can read, in one list. Initialize a member before you open its paths.

- Skills: [decomp/.agents/skills/decomp/SKILL.md](decomp/.agents/skills/decomp/SKILL.md) is the only
  skill. Its references are in `decomp/.agents/skills/decomp/references/`: `match.md`, `name.md`,
  `refactor.md`, `research.md`, `review.md`, `tool.md`. `.agents/skills` and `.claude/skills` link to
  it, so an agent started here loads it once `decomp` is initialized.
- Tools: `make help` here; [decomp/tools/README.md](decomp/tools/README.md) for the decomp tools;
  [decomp/tools/bof3-tools/docs/cli.md](decomp/tools/bof3-tools/docs/cli.md) for `bof3`;
  [player/docs/player.md](player/docs/player.md) for `bof3player`. Every tool takes `--help`.
- Docs: [decomp/docs/README.md](decomp/docs/README.md) lists every decomp page; each member's
  `README.md` and `docs/` hold the rest.
- CI: `.github/workflows/docs.yml` here; each member has its own `.github/workflows/`.
- Wiki: edit in [wiki/](wiki/AGENTS.md); read the [site](https://raulcorreia7.github.io/bof3-wiki/). For a model: [llms.txt](https://raulcorreia7.github.io/bof3-wiki/llms.txt) (index), [llms-small.txt](https://raulcorreia7.github.io/bof3-wiki/llms-small.txt) (compact, for a small context), [llms-full.txt](https://raulcorreia7.github.io/bof3-wiki/llms-full.txt) (everything).
- Standard: [docs/standard.md](docs/standard.md).

## Writing

Docs, comments, commit messages and pull requests follow the [project standard](docs/standard.md#writing): present tense, what and why instead of how, in the game developer's own terms, and Orwell's six rules.
Comments say what, never how: one line, only where a name cannot say it ([standard](docs/standard.md#comments)).
