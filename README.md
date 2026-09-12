# FormalProof: machine-checked formalization of papers in coding theory

This repository is a **Lean 4 + mathlib** formalization project for
independent study: it turns the definitions, theorems and proofs of a
published paper into Lean code that the proof kernel checks mechanically, so
that the argument is either confirmed beyond doubt or a gap/typo in the paper
surfaces.

The repository layout, documentation practice, verification workflow and
module conventions follow Shenghao Yang's
[`n4code_lean_dev`](https://github.com/shhyang/n4code_lean_dev) project; the
core definitions in `FormalProof/Definitions.lean` and the lemmas in
`FormalProof/Basic.lean` are adapted from its `NMCode/CodingTheory.lean`
(Apache-2.0, see [`NOTICE`](NOTICE)).

## New here? Read this first

[`ONBOARDING.md`](ONBOARDING.md) is a from-zero guide (in Chinese) covering
what Lean/mathlib/Lake/elan are, how to read Lean code, the daily
edit → build → check → commit loop, how to put the project on GitHub, and the
rules this repository follows.  [`AGENTS.md`](AGENTS.md) is the short version
of those rules, addressed to AI coding agents.

## Status

| Module | Contents | Status |
| --- | --- | --- |
| `FormalProof/Definitions.lean` | Binary words, XOR, Hamming weight/distance, `(n, M)` codes, `dRow`/`dCode`/`alpha`/`lambda`, code equivalence | Complete |
| `FormalProof/Basic.lean` | XOR and Hamming algebra, `hammingDist_le`, `dCode_le_dRow`, `dCode_le`, compile-time `decide` checks | Complete |
| `FormalProof/Statements.lean` | Paper-numbered statement catalogue (the phase modules own the proofs) | Template — empty until a paper is chosen |
| `FormalProof/AxiomCheck.lean` | `#print axioms` audit of the headline results | Complete |

No target paper is fixed yet; the candidates are listed in `PLAN.md` §1.1.
When one is chosen, the statement catalogue is filled in with `sorry` stubs
(one per numbered paper result, each tagged with its paper label), and the
proofs land in one module per phase.

## Build

The toolchain is pinned in [`lean-toolchain`](lean-toolchain)
(`leanprover/lean4:v4.34.0-rc2`) and mathlib in
[`lake-manifest.json`](lake-manifest.json) (revision also pinned in
`lakefile.toml`).

> The Lean version must match the one mathlib requires: mathlib master pins
> `leanprover/lean4:v4.34.0-rc2`, so this project does too.  A mismatch makes
> `lake exe cache get` refuse to restore the prebuilt oleans and forces an
> (incompatible, failing) build of mathlib from source.

```bash
lake exe cache get   # fetch prebuilt mathlib oleans (only needed once)
lake build           # incremental build (seconds when up to date)
```

Individual modules build in isolation, e.g. `lake build FormalProof.Basic`.

**Build-performance rules** (important for mathlib-heavy projects): never run
bare `lake clean` (it deletes the prebuilt mathlib oleans and forces a long
source rebuild); restore them with `lake exe cache get` instead; keep imports
minimal and never `import Mathlib`.  Details in [`AGENTS.md`](AGENTS.md).

> **Windows/OneDrive note.**  A Lean project creates a multi-gigabyte `.lake/`
> build directory.  Do not build inside a OneDrive-synced folder — keep the
> working copy outside sync (e.g. `C:\lean\...`).  See `ONBOARDING.md` §3.

## Verification

What "verified" means for this repository, the trusted axiom set, and how to
reproduce the check from a fresh clone are recorded in
[`VERIFICATION.md`](VERIFICATION.md).  In short:

```powershell
lake build                                    # kernel check
pwsh scripts/consistency_check.ps1            # build + paper/Lean label coverage + orphan modules
pwsh scripts/axioms_check.ps1                 # per-theorem axiom audit (fails on sorryAx)
```

The same commands run in CI (GitHub Actions) on every push; see
`.github/workflows/ci.yml`.

## Repository layout

```text
FormalProof.lean          # library root module (imports every module below)
FormalProof/              # the formalization
ONBOARDING.md             # from-zero guide (Chinese)
AGENTS.md                 # rules for AI agents / contributors
PLAN.md                   # scope, statement table, phase plan
Notation.md               # paper ↔ Lean dictionary (symbols, labels, conventions)
CONSISTENCY.md            # per-step paper/Lean consistency protocol
VERIFICATION.md           # what is verified and how to reproduce it
DEVLOG.md                 # dated development log
TODO.md                   # open work
PUBLISHING.md             # venue/artifact/Zenodo plan
NOTICE                    # third-party code attribution
CITATION.cff              # machine-readable citation info
lakefile.toml             # libraries and dependencies
lean-toolchain            # pinned Lean version
lake-manifest.json        # pinned dependency revisions
scripts/                  # consistency + axiom checks (PowerShell and bash)
paper/                    # the papers being formalized (local-only, gitignored)
```

## Citing

See [`CITATION.cff`](CITATION.cff).  If you build on this project, cite it and
the paper it formalizes.

## License

Apache-2.0 (see [`LICENSE`](LICENSE)).  The formalization is original work; the
theorem statements it formalizes belong to the cited papers.  Code adapted
from `n4code_lean_dev` is used under the same license and is credited in
[`NOTICE`](NOTICE).
