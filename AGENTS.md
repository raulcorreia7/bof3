# Agent guidance

Work in the project that owns the change. Read its `AGENTS.md` when present, then
its `README.md`. Preserve unrelated changes and existing submodule pins.

| Change                                     | Read                                                                                                                                                                                                                                                     |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Shared builds or workspace documentation   | [README.md](README.md), [CONTRIBUTING.md](CONTRIBUTING.md)                                                                                                                                                                                               |
| Game code, matching or decompilation setup | [decomp/AGENTS.md](https://github.com/raulcorreia7/bof3-decomp/blob/main/AGENTS.md), [decomp/README.md](https://github.com/raulcorreia7/bof3-decomp/blob/main/README.md), [skills](https://github.com/raulcorreia7/bof3-decomp/tree/main/.agents/skills) |
| Audio and player                           | [player/AGENTS.md](https://github.com/raulcorreia7/bof3-player/blob/main/AGENTS.md), [player/README.md](https://github.com/raulcorreia7/bof3-player/blob/main/README.md)                                                                                 |
| Progress site                              | [status/AGENTS.md](https://github.com/raulcorreia7/bof3-status/blob/main/AGENTS.md), [status/README.md](https://github.com/raulcorreia7/bof3-status/blob/main/README.md)                                                                                 |
| Rust disc and archive tools                | [tools/AGENTS.md](https://github.com/raulcorreia7/bof3-tools/blob/main/AGENTS.md), [tools/README.md](https://github.com/raulcorreia7/bof3-tools/blob/main/README.md)                                                                                     |
| Game and file-format facts                 | [wiki](https://raulcorreia7.github.io/bof3-wiki/)                                                                                                                                                                                                        |
| Project maintenance standards              | [project standard](docs/standard.md)                                                                                                                                                                                                                     |

Each submodule owns its commits and checks. Change a parent pin after the child
commit is available. Keep game data, build output and local backups
outside the tracked tree. Update generated files through their generator.

## Writing

Docs, comments, commit messages and pull requests follow one standard.

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
