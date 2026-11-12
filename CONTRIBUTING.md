# Contributing

All contributions follow the [code of conduct](CODE_OF_CONDUCT.md). Ask questions in
[GitHub Discussions](https://github.com/raulcorreia7/bof3/discussions). Report a security or conduct
problem privately ([SECURITY.md](SECURITY.md)).

## Choose the repository

Each project is a submodule that owns its source, documentation and checks. This workspace owns the
`make` entry points and the pins.

The README [goal router](README.md#choose-a-goal) says which project owns a change and how to
initialize it. Each project's `CONTRIBUTING.md` says how to contribute to it; this page covers the
workspace.

## Make a change

1. Initialize the project (`make init-game`, `make init-player` and so on).
2. Create a branch in that project. A submodule can sit at a detached commit:

   ```sh
   git -C decomp switch -c my-change
   ```

3. Keep the change focused. Write commit subjects as `type(scope): subject`, for example
   `fix(setup): validate disc tracks` or `docs(formats): clarify EMI padding`.
4. Run the gate before you push.
5. Open the pull request against that project's `main`. Describe the behavior and the checks you ran.

## Gate

A workspace change runs `make check`; a member change runs that member's gate, named in the project
guide the [goal router](README.md#choose-a-goal) links.

`make format` formats shared Markdown, JSON and TOML; `make format CHECK=1` verifies it.

## What never lands

Disc tracks, extracted game data, compiled game images, PsyQ objects, build output and local work
stay outside Git. Commit source and synthetic fixtures only. Change generated files through their
generator. Do not submit code you did not write or cannot license.

## Update the pins

Change a pin only after the project's commit is on its `main`. The tools pin lives in bof3-decomp
(`decomp/tools/bof3-tools`).

```sh
git submodule update --remote --merge -- player   # or decomp, status, wiki
git add player
git commit -m "chore(submodules): update player"
```

`make status` shows every revision; `make sync` moves all projects to the recorded pins.

## Your first change

1. Fix a docs page. `make check` verifies it.
2. Improve a [wiki](https://raulcorreia7.github.io/bof3-wiki/) page.
3. Add a Rust test to the tools or the player (`make check-tools`, `make check-player`).
4. With a disc, match one function in bof3-decomp. Its
   [README](https://github.com/raulcorreia7/bof3-decomp#readme) and
   [CONTRIBUTING](https://github.com/raulcorreia7/bof3-decomp/blob/main/CONTRIBUTING.md) show how.

## Shared tool installer

`tools/install/dprint.sh` installs the pinned dprint that `make check` and `make format` use.

## License

The workspace is MIT licensed; bof3-decomp is CC0 1.0. A contribution is under the license of the
repository you change.

## Agent guidance

[AGENTS.md](AGENTS.md) and the `.agents/skills` folders are optional guidance for coding agents.
You do not need them to contribute. In them, "maintainer" is the repository owner, who reviews and
merges pull requests; "owner" is the project that owns a change.
