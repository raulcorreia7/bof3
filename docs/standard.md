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
- **ASD-STE100** is the basis for technical text: short sentences, one instruction per sentence,
  active voice, one term for one concept, numbered steps for a procedure. Exact technical terms
  stay.
- **Orwell's six rules** ("Politics and the English Language", 1946):
  1. Never use a metaphor, simile or other figure of speech that you are used to seeing in print.
  2. Never use a long word where a short one will do.
  3. If it is possible to cut a word out, always cut it out.
  4. Never use the passive where you can use the active.
  5. Never use a foreign phrase, a scientific word or a jargon word if you can think of an everyday
     English equivalent.
  6. Break any of these rules sooner than say anything outright barbarous.

## Comments

Comments say what, never how. They are minimal and high signal: one line, only where a name or a
type cannot carry the meaning. This holds for C, Rust, TypeScript, shell and YAML. A comment never
retells the code, its history, the evidence or the tools. Evidence for a name goes in the commit
body, and in `config/symbols.toml` `source` for decomp names.

Standing exceptions: legal text, tool directives and `@bug`. The decomp exceptions (`FAKE:` notes
and the `INCLUDE_ASM` line) are in the
[decomp conventions](https://github.com/raulcorreia7/bof3-decomp/blob/main/docs/conventions.md#comments).
