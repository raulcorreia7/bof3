# Agent guidance

This is the workspace of the *Breath of Fire III* (PS1) projects. Each project is a Git submodule
with its own `AGENTS.md`, checks and commits. Work in the project that owns the change: read its
`AGENTS.md`, then its `README.md`.

## Members

The members are `decomp/`, `player/`, `status/` and `wiki/`; `decomp/tools/bof3-tools/` is a nested
submodule. A member folder is empty until `make init-<name>` checks it out (`game`, `tools`,
`player`, `status` or `wiki`); see [README](README.md#set-up).

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

- `make check` checks the shared docs and config and builds the wiki.
- `make check-<game|tools|player|status>` runs one project's checks; `make check-all` runs them all.
- Run the gate named in the project's own guide before you report.
- `make doctor` lists missing host tools; each project's README `#requirements` is the full list.

## Rules

- Each submodule owns its commits and checks. Change a parent pin only after the child commit is on
  the child's `main`.
- Preserve unrelated changes and the existing submodule pins.
- Keep game data, build output and local backups outside the tracked tree.
- Update generated files through their generator.

## Index

Initialize a member before you open its paths.

- Skill: [decomp](decomp/.agents/skills/decomp/SKILL.md) is the only skill. Its references (`match`,
  `name`, `refactor`, `research`, `review`, `tool`) sit beside it in `references/`. `.agents/skills`
  and `.claude/skills` here link to it.
- Tools: `make help`; [decomp tools](decomp/tools/README.md); [`bof3`](decomp/tools/bof3-tools/docs/cli.md);
  [`bof3player`](player/docs/player.md). Every tool takes `--help`.
- Docs: [decomp/docs/README.md](decomp/docs/README.md) lists the decomp pages; each member's
  `README.md` and `docs/` hold the rest.
- CI: `.github/workflows/docs.yml` here; each member has its own.
- Wiki: edit in [wiki/](wiki/AGENTS.md); read the [site](https://raulcorreia7.github.io/bof3-wiki/).
  For a model: [llms.txt](https://raulcorreia7.github.io/bof3-wiki/llms.txt) (index),
  [llms-small.txt](https://raulcorreia7.github.io/bof3-wiki/llms-small.txt) (compact),
  [llms-full.txt](https://raulcorreia7.github.io/bof3-wiki/llms-full.txt) (everything).

## Writing

Docs, comments, commit messages and pull requests follow the [project standard](docs/standard.md#writing).
A comment is one line and only where a name cannot say it ([standard](docs/standard.md#comments)).
