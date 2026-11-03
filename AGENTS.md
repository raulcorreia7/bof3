# Agent guidance

Work in the project that owns the change. Read its `AGENTS.md` when present, then
its `README.md`. Preserve unrelated changes and existing submodule pins.

| Change                                     | Read                                                                                                                                                                                                                                                     |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Shared builds or workspace documentation   | [README.md](README.md), [CONTRIBUTING.md](CONTRIBUTING.md)                                                                                                                                                                                               |
| Game code, matching or decompilation setup | [decomp/AGENTS.md](https://github.com/raulcorreia7/bof3-decomp/blob/main/AGENTS.md), [decomp/README.md](https://github.com/raulcorreia7/bof3-decomp/blob/main/README.md), [skills](https://github.com/raulcorreia7/bof3-decomp/tree/main/.agents/skills) |
| Audio and player                           | [player/AGENTS.md](https://github.com/raulcorreia7/bof3-player/blob/main/AGENTS.md), [player/README.md](https://github.com/raulcorreia7/bof3-player/blob/main/README.md)                                                                                 |
| Progress site                              | [status/AGENTS.md](https://github.com/raulcorreia7/bof3-status/blob/main/AGENTS.md), [status/README.md](https://github.com/raulcorreia7/bof3-status/blob/main/README.md)                                                                                 |
| Rust disc and archive tools                | [tools README](https://github.com/raulcorreia7/bof3-tools/blob/main/README.md)                                                                                                                                                                           |
| Game and file-format facts                 | [wiki](https://raulcorreia7.github.io/bof3-wiki/)                                                                                                                                                                                                        |
| Project maintenance standards              | [project standard](docs/standard.md)                                                                                                                                                                                                                     |

Each submodule owns its commits and checks. Change a parent pin after the child
commit is available. Keep game data, build output and local backups
outside the tracked tree. Update generated files through their generator.
