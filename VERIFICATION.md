# Verifying the formalization

This file records what "verified" means for this repository and how to
reproduce the check.  The README carries a short pointer and `scripts/`
contains the executable checks.  A filled-in verification report (§6) should
be attached to each tagged release.

## 1. What is verified

* **Every statement is proved.**  The library contains no `sorry`, `admit` or
  `axiom` declarations; in particular no headline theorem depends on
  `sorryAx`.
* **The headline theorems depend only on the allowed axiom set** —
  `propext`, `Quot.sound`, `Classical.choice`.  `FormalProof/AxiomCheck.lean`
  prints the axioms of every headline theorem and
  `scripts/axioms_check.ps1` enforces the allowlist.
* **The paper correspondence holds.**  `scripts/consistency_check.ps1`
  validates that every paper label referenced from a docstring or
  `Notation.md` exists in the paper, that every theorem-like paper label
  appears in the library, and that no module is orphaned.
* **The kernel checked every proof.**  `lake build` produces the olean files by
  elaborating and kernel-checking all modules.

## 2. The `decide` / `native_decide` trust

`decide` proves a decidable goal by kernel computation and introduces no extra
axiom.  `native_decide` instead evaluates the goal with the compiled Lean code
generator, which appears in `#print axioms` output as per-lemma axioms of the
form `<lemma>._native.native_decide.ax_*`.  The Lean compiler then becomes part
of the trusted base, and the development can no longer be checked by external
type checkers that do not implement the feature.

Policy here (following the reference project): finite checks in completed
modules use `decide`; `native_decide` may be used to *explore* a problem but
must not be load-bearing for a headline theorem.

## 3. Reproduce from a fresh clone

```powershell
git clone <repository-url> formalproof ; cd formalproof
lake exe cache get                  # fetch prebuilt mathlib oleans
lake build                          # full incremental build
pwsh scripts/consistency_check.ps1  # paper/Lean label correspondence (if paper source present)
pwsh scripts/axioms_check.ps1       # axiom audit; fails on sorryAx
rg -n "\bsorry\b" FormalProof/      # no declaration may use sorry
```

## 4. Expected results

* `lake build` completes with no errors (after a phase is finished: no `sorry`
  warnings either).
* `consistency_check.ps1` prints `OK: paper and Lean are in sync ...`.
* `axioms_check.ps1` prints `OK: per-theorem axiom audit passed ...`.
* the `rg` command prints only docstring mentions of the word "sorry".

## 5. Axiom audit details

`FormalProof/AxiomCheck.lean` contains one `#print axioms` command per headline
theorem; `scripts/headline_theorems.txt` is the checked-in manifest of those
theorems.  `scripts/axioms_check.ps1` first checks that the manifest and
`AxiomCheck.lean` agree in both directions (so a headline theorem cannot be
added or dropped without an explicit, reviewed change), then parses each
theorem's axiom list and checks it against the allowlist.  Any other axiom —
in particular `sorryAx` — fails the check, with the offending theorem named.

## 6. Verification report (fill in and attach at each release)

| Item | Value |
| --- | --- |
| Date | |
| Machine / OS | |
| Lean toolchain (`lean-toolchain`) | |
| mathlib commit (`lake-manifest.json`) | |
| Cold build time (after `lake exe cache get`) | |
| Incremental build time | |
| `#print axioms` output | attached |
| Ran by | |

## 7. CI

The same commands run in CI (GitHub Actions) on every push; see
`.github/workflows/ci.yml`.  A green CI run on the pinned toolchain is the
practical proof of verification for reviewers.
