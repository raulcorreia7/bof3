# Project standard

Every repository this project owns meets the same bar: `bof3` (this workspace), `bof3-decomp`
(`decomp`), `bof3-status` (`status`), `bof3-tools` (`decomp/tools/bof3-tools`), `bof3-player`
(`player`) and `bof3-wiki` (`wiki`). Each member is a submodule of its public repository.
Third-party submodules keep their owners' terms and are not changed.

| Area          | The repository has                                                                                                                                                                                                                                  |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Clean clone   | One documented command builds and tests it from a fresh clone; nothing reaches outside the repository except declared submodules and pinned tools (install pins and lock files).                                                                    |
| README        | What it is, how to build, run and test, runnable examples; links only to files in the repository or to public URLs. A repository that can be public carries the notice below.                                                                       |
| Notice        | A fan project, not affiliated with or endorsed by Capcom; Breath of Fire is a Capcom trademark; no game data is included; bring your own disc.                                                                                                      |
| License       | `LICENSE` at the root and in each package that ships alone. bof3-decomp uses CC0 1.0; the workspace, tools, status site and player use MIT. Manifest license fields match; dependencies are checked with `cargo deny` or the language's equivalent. |
| Game data     | No retail bytes, retail text, or extracted assets in the tree or its history; tests that need the disc skip without it; fixtures are synthetic.                                                                                                     |
| Tools         | `--help` with a one-line purpose, every switch and its default, and runnable examples; the same switch names across commands (`-i/--input`, `-o/--output`, `--list`, `--json`, `-q`); errors say what failed and the next action.                   |
| Speed         | Every tool and gate step is fast and light: a no-change run is near instant and work scales with what changed (Ninja and Cargo dependency tracking, content-hash caches). A slow step is a bug; measure it with `time` before changing it.          |
| Build         | bof3-decomp builds natively with Meson and Ninja; Rust projects use Cargo and the site uses npm. The workspace `Makefile` only forwards to them.                                                                                                    |
| Test output   | Artifacts for manual inspection go under the build folder: Rust integration tests use `CARGO_TARGET_TMPDIR`; other builds use a per-test folder under the build folder. Nothing is written into the source tree.                                    |
| Format & lint | The formatters and linters run in the gate (`cargo fmt`, `clippy -D warnings`, `clang-format`, `dprint`, `tsc`, `ruff`); one config per repository.                                                                                                 |
| CI            | CI runs the documented checks that need no game media. Maintainers run disc-dependent checks before merging. The workspace checks Markdown and the wiki; each member owns its source checks.                                                        |
| Wiki          | The wiki states specs only: layouts, offsets, values, behavior, limits and sequences. Evidence is `Name (image@0xADDR)`. It names no repository, tool, build step, source path or code block; a reader needs none of them.                          |
| Prose         | READMEs, docs, comments and help text are plain and current: no history, no hedging, no filler.                                                                                                                                                     |
| Commits       | Conventional subjects; no AI attribution or session trailers.                                                                                                                                                                                       |
| Going public  | History holds nothing the tree may not (filtered or fresh first commit); the owner creates the repository and pushes; the workspace then consumes it as a submodule.                                                                                |

## Writing

Docs, comments, commit messages and pull requests follow one standard.

- **Current.** Present tense, no history.
- **What, not how.** Say what a thing does and why. The code shows how.
- **Developer voice.** Write as the game's own programmers would: the game's names (Ryu, the
  Dragon genes, faeries, the fishing minigame) and standard game-development terms (actor, sprite,
  ordering table, update, draw, spawn, state) instead of generic stand-ins. Short sentences, active
  voice, one term for one concept. Exact technical terms stay.
- **Orwell's six rules** ("Politics and the English Language", 1946):
  1. Never use a metaphor, simile or other figure of speech that you are used to seeing in print.
  2. Never use a long word where a short one will do.
  3. If it is possible to cut a word out, always cut it out.
  4. Never use the passive where you can use the active.
  5. Never use a foreign phrase, a scientific word or a jargon word if you can think of an everyday
     English equivalent.
  6. Break any of these rules sooner than say anything outright barbarous.

Rule 5 never replaces a game or game-development term; those are the everyday words here.

## Comments

A comment is absolutely minimal. It exists only to say one of three things that a name or a type
cannot:

- what the thing is or does, in one line;
- its source: the game function and address, the Sony manual chapter or the psx-spx section;
- a constraint the next editor must keep (a fixed size, an order the bytes require).

Anything else is deleted: a comment that retells the code, its history, the evidence, the tools, a
rationale, or a section banner. A doc comment on a public item states its contract (what it returns,
when it fails, its units) in one line where one line does. This holds for C, Rust, TypeScript, shell
and YAML. Evidence for a name goes in the commit body, and in `config/symbols.toml` `source` for
decomp names.

Standing exceptions: legal text, tool directives and `@bug`. The decomp exceptions (`FAKE:` notes
and the `INCLUDE_ASM` line) are in the
[decomp conventions](https://github.com/raulcorreia7/bof3-decomp/blob/main/docs/conventions.md#comments).
