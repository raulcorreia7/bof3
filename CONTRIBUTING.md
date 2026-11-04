# Contributing

All contributions follow the [code of conduct](CODE_OF_CONDUCT.md). Choose the repository that owns
the change. This workspace owns the shared build entry points. Each member repository is pinned
here as a submodule and owns its source, documentation and validation; the wiki is
[bof3-wiki](https://github.com/raulcorreia7/bof3-wiki), pinned at `wiki/`.

| Change                                         | Start here                                                                                             |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Game code, matching or decompilation setup     | [bof3-decomp contributor guide](https://github.com/raulcorreia7/bof3-decomp/blob/main/CONTRIBUTING.md) |
| Music, sound or player interfaces              | [bof3-player contributor guide](https://github.com/raulcorreia7/bof3-player/blob/main/CONTRIBUTING.md) |
| Disc, archive or asset tools                   | [bof3-tools README](https://github.com/raulcorreia7/bof3-tools/blob/main/README.md)                    |
| Progress site                                  | [bof3-status README](https://github.com/raulcorreia7/bof3-status/blob/main/README.md)                  |
| Shared builds or game and format documentation | [workspace README](README.md), [wiki](https://raulcorreia7.github.io/bof3-wiki/)                       |
| Project maintenance standards                  | [project standard](docs/standard.md)                                                                   |

## Work in the owning repository

Create a branch in the repository you are changing. A submodule may be checked out
at a detached commit, so create its branch there before committing:

```sh
git -C decomp switch -c my-change
```

Submit source changes to that project's repository. Update a parent submodule pointer
only after the child commit is available from its repository.

Keep each change focused. Use commit subjects such as `fix(setup): validate disc tracks`
or `docs(formats): clarify EMI padding`. Describe the behavior and checks in the pull request.

## Checks and data

Run the owning project's checks, and `make check` for shared documentation changes.
Run `make check-all` to validate the full workspace.
Game-code changes also need bof3-decomp's byte-identity gate, `make check-game`, which needs your disc.

Use your own disc for local validation. Commit source and synthetic fixtures only;
keep disc tracks, extracted game data, compiled game images, PsyQ objects, build
output and local work outside Git. Generated reports and files change through their
generator.

Format shared Markdown with `make format`; use `make format CHECK=1` to verify it.

## Shared tool installers

Each `tools/install/` script is standalone: it may duplicate the download and
checksum steps of its neighbours so that it reads and runs alone.

## Your first change and where to ask

[Your first change](README.md#your-first-change) lists four steps, from a docs fix to matching one
function. Ask questions in [GitHub Discussions](https://github.com/raulcorreia7/bof3/discussions).
Report a security or conduct problem privately ([SECURITY.md](SECURITY.md)).

## License

The workspace is MIT licensed. By contributing you agree that your contribution is under the
license of the repository you change: MIT here, CC0 1.0 in bof3-decomp. Do not submit code you did not
write or cannot license.

## Agent guidance

[AGENTS.md](AGENTS.md) and the `.agents/skills` folders in the members are optional guidance for
coding agents. You do not need them to contribute. In them, "maintainer" means the repository owner,
who reviews and merges pull requests, and "owner" means the project that owns a change.
