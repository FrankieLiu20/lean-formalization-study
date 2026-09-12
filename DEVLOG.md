# Development Log

Working notes for the formalization.  Everything here is supplementary; the
source of truth for the proof state is `PLAN.md`, and the paper is the
authoritative reference for the mathematics.  Newest entries first.

## 2026-09-12 (later) — working area moved to `E:\lean`

All Lean work now lives on `E:` (fixed disk, ~247 GB free, versus ~26 GB free on
`C:`).  The move was done by **re-cloning and rebuilding**, not by moving the
built directory: lake's build traces contain absolute paths, so a moved tree
would have been rebuilt from scratch (and rebuilding mathlib from source is an
hour-long trap).  `lake exe cache get` restored the oleans from the local
cache, and `lake build` was green (952 jobs, standard axiom set).

* `E:\lean\lean-formalization-study` — the project (working copy)
* `E:\lean\reference\n4code_lean_dev` — the reference repository
* `E:\lean\_archive\2026-09-12-onedrive-code-copy` — the old OneDrive copy
* the working copy under `C:\lean` was deleted; the unused Lean 4.33.x
  toolchains were uninstalled (freed ~10 GB on `C:`)

**Trap found: elan's default toolchain.**  The first toolchain installed on this
machine (`leanprover/lean4:v4.33.0`) had silently become elan's *default*.  When
VS Code's Lean extension ran without a project folder opened, it launched the
language server with 4.33.0 instead of the project's 4.34.0-rc2 — the Infoview
stayed empty and the server burned CPU.  Fixed with
`elan default leanprover/lean4:v4.34.0-rc2`, and the lesson is in
`ONBOARDING.md` §3: **always open the project folder, not a single file.**

## 2026-09-12 — GitHub repository, and the first kernel-checked build

The scaffold was pushed to <https://github.com/FrankieLiu20/lean-formalization-study>
(public; one repository per project, following the reference project's habit)
and a working copy was cloned to `C:\lean\lean-formalization-study`, outside
OneDrive.  `lake exe cache get` + `lake build` were run in that copy:

```
✔ [949/952] Built FormalProof.Basic
ℹ [950/952] Built FormalProof.AxiomCheck
  'FormalProof.hammingDist_self' depends on axioms: [propext, Classical.choice, Quot.sound]
  ... (the same for hammingDist_symm, hammingDist_eq_zero_iff, hammingDist_le, dCode_le)
✔ [951/952] Built FormalProof
Build completed successfully (952 jobs).
```

So the paper-independent layer is not just written but **kernel-checked**, and
the headline lemmas use only the standard trusted axioms — no `sorryAx`, no
`native_decide` trust axioms.  `scripts/consistency_check.ps1` (build +
orphan-module check + label check, 0 `sorry`) and `scripts/axioms_check.ps1`
(manifest coverage + allowlist) were both run and pass.

Two mathlib-migration problems were found and fixed while porting the generic
core (both recorded in `AGENTS.md` §Common failure modes):

* `Finset.min'` needs `Mathlib.Data.Finset.Max`;
* `Finset.sum_le_sum` moved to
  `Mathlib.Algebra.Order.BigOperators.Group.Finset`, and
  `Mathlib.Data.Real.Basic` is deprecated in favour of
  `Mathlib.Basic.Real.Basic`.

Tooling note: GitHub CLI 2.100.0 was installed under `C:\Users\lenovo\gh`
(no winget/scoop/choco on this machine), authenticated with the device-code
flow, and `gh auth setup-git` configured the git credential helper.

## 2026-09-12 — Project scaffold

### Toolchain decision (and the trap it avoids)

First attempt: `lean-toolchain` = `leanprover/lean4:stable` (= Lean 4.33.1)
with mathlib required without a `rev`, so `lake update` resolved mathlib
*master*.  mathlib master pins `leanprover/lean4:v4.34.0-rc2`, so lake warned
about conflicting toolchains, `lake exe cache get` refused to restore the
prebuilt oleans ("The cache will not work unless your project's toolchain
matches Mathlib's toolchain"), and `lake build` fell back to rebuilding mathlib
from source with the wrong compiler — which failed immediately with errors like
`Unknown identifier dite_eq_left` and `linearRec is not a definition` inside
mathlib itself.  Nothing was wrong with our code; the toolchain simply did not
match the dependency.

Resolution: `lean-toolchain` = `leanprover/lean4:v4.34.0-rc2` (the version
mathlib master requires) and mathlib pinned by `rev` in `lakefile.toml`
(`70f3f134…`, the master commit at the time of writing).  Lake now reports no
toolchain conflict and the cache restores the oleans.

**Rule for the future:** after any `lake update`, read
`.lake/packages/mathlib/lean-toolchain` and make the project's
`lean-toolchain` say the same thing.  Upgrading the toolchain is a separate,
deliberate commit.

Bootstrapped the repository following the layout of Shenghao Yang's
`n4code_lean_dev`:

* toolchain: elan 4.2.4 with `leanprover/lean4:v4.34.0-rc2`; mathlib pinned by
  `rev` in `lakefile.toml` and recorded in `lake-manifest.json`.
* `FormalProof/Definitions.lean` and `FormalProof/Basic.lean`: the generic
  (paper-independent) layer, adapted from `NMCode/CodingTheory.lean` of the
  reference repository — binary words, bitwise XOR, Hamming weight/distance,
  `(n, M)` codes with `row`/`dRow`/`dCode`/`alpha`/`lambda`, code equivalence.
  Specialisation to `M = 4` (the reference project's case) is deliberately not
  done here.
* `FormalProof/Statements.lean` is an empty, documented catalogue: it is filled
  in once the target paper is chosen.
* Checks: `scripts/consistency_check.ps1` (build + paper-label coverage +
  orphan modules + `sorry` count) and `scripts/axioms_check.ps1` (axiom
  allowlist with a manifest check in both directions), plus a GitHub Actions
  workflow running both on every push.
* Documentation set: `PLAN.md`, `Notation.md`, `CONSISTENCY.md`,
  `VERIFICATION.md`, `TODO.md`, `PUBLISHING.md`, `AGENTS.md`, and
  `ONBOARDING.md` (a from-zero guide in Chinese).

Decision recorded: the reference project pins Lean 4.33.0 to keep its
published artifact reproducible; this project tracks `stable` and the current
mathlib master instead, since it has no artifact to preserve yet.  Upgrading
the toolchain later must be a separate, deliberate commit that records the new
mathlib commit in `lake-manifest.json`.

Decision recorded: a Lean project's `.lake/` directory is several gigabytes
and tens of thousands of files.  Do not build inside a OneDrive-synced folder
(the workspace this project was created in is synced); keep the working copy
outside sync.  See `ONBOARDING.md` §3.

## Planned next steps

1. Choose the target paper (`PLAN.md` §1.1).
2. Extract the statement table from the paper into `PLAN.md` §1.1.
3. Add the paper-specific definitions to `FormalProof/Definitions.lean`
   (or a dedicated module) and to `Notation.md` §3.
4. Fill `FormalProof/Statements.lean` with `sorry`-stubbed statements, one per
   numbered paper result, each tagged with its paper label.
5. Start proving the leaf lemmas of the dependency graph.
