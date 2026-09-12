# AGENTS.md — Rules for agents and contributors working in this repository

This repository is a Lean 4 + mathlib formalization of a coding-theory paper
(see `PLAN.md` for the chosen paper and the phase plan, `Notation.md` for the
paper ↔ Lean dictionary, and `ONBOARDING.md` for the human-facing guide).
Read `PLAN.md` and `Notation.md` before writing code.  The toolchain is pinned
in `lean-toolchain`; mathlib is pinned in `lake-manifest.json`.

These rules are adapted from `AGENTS.md` in Shenghao Yang's
`n4code_lean_dev`, which is the model for this project.

## Build performance rules (must follow)

1. **Never run bare `lake clean`.** With no arguments it deletes the build
   directory of every package in the workspace, including the prebuilt mathlib
   oleans under `.lake/packages/mathlib/.lake/build`, forcing a source rebuild
   of ~1000 modules.  To clean this package only: `lake clean FormalProof`.

2. **Never rebuild mathlib from source.** If the mathlib oleans are missing or
   stale, restore them with `lake exe cache get` first, then run `lake build`.
   The local cache under `~/.cache/mathlib` makes this cheap after the first
   download.

3. **Build incrementally.**
   - `lake build` — normal incremental build (seconds when up to date);
   - `lake build FormalProof.<Module>` — rebuild one module;
   - `lake env lean FormalProof/<File>.lean` — type-check a single file.
   Do not add `lake clean` (or any cache-wiping step) to scripts or CI.

4. **Minimal imports, never `import Mathlib`.** Import only the mathlib
   modules a file needs; `FormalProof/Definitions.lean` is the reference for a
   minimal import block.  Workflow for a new file:
   a. start from a small candidate import list;
   b. compile; when the compiler reports an unknown identifier or notation,
      add the module that provides it (find it with `rg` under
      `.lake/packages/mathlib/Mathlib/`);
   c. optionally run `lake shake <file>` to minimise the list automatically.
   Keep imports dependency-ordered and delete ones that become unused.

5. **Keep modules small and the import graph shallow.** Related lemmas belong
   in the same module; do not create one module per lemma.  Avoid tactics that
   blow up elaboration (e.g. `simp`/`aesop` over large `Finset.univ` sets,
   `native_decide` on big search spaces).

6. **Respect the root-module layout.** The library root module is
   `FormalProof.lean` at the *package root*, and its module name must equal the
   library name.  New modules go under `FormalProof/` and must be imported
   from the root module, otherwise `lake build` silently skips them.  If the
   build fails with `some modules have bad imports`, check the root module and
   that every imported name resolves to a source file.

6a. **Docstrings.** Every completed definition/lemma carries a one-line
    docstring.  Lemmas that correspond to a paper statement name the paper
    label and section, with the label backticked (`` `thm:two` (Theorem 1) ``,
    `` `eq:d` ``), so `scripts/consistency_check.ps1` can validate it against
    the paper.  Use section numbers, never tex line numbers.

7. **Never leave the build broken.** `sorry` stubs are allowed while a phase is
   in progress, but every `sorry` must carry a comment naming the paper label
   it corresponds to, and the file must compile.  A module containing `sorry`
   is acceptable; a module with errors is not.

8. **Keep the worktree clean.** `.lake/`, `build/`, `*.olean`, `reference/`,
   `*.pdf` and editor files are untracked; never commit build artifacts.  Commit
   only source: `*.lean`, `*.md`, `lakefile.toml`, `lean-toolchain`,
   `lake-manifest.json`, `scripts/*`.

9. **Commit after every proved lemma.** Small, labelled commits
   (`prove Theorem 8 comparison part`, `simplify row distances`) make it
   possible to find the commit that introduced a wrong statement.

## Verification workflow

1. After editing a module: `lake build FormalProof.<Module>`.
2. After every step (before committing): `pwsh scripts/consistency_check.ps1`
   and follow the checklist in `CONSISTENCY.md` — the paper and the Lean code
   must stay in sync (labels, definitions, hypotheses, notation).
3. Before reporting a phase complete: full `lake build` (must pass).
4. After any change to imports or the lakefile: full `lake build`.
5. Before any release: `pwsh scripts/axioms_check.ps1` (fails on `sorryAx`),
   and fill in the verification report in `VERIFICATION.md`.

## Common failure modes

- `FormalProof: some modules have bad imports` — the library root module
  `FormalProof.lean` is missing from the package root, or an imported module
  name does not resolve; see rule 6.
- `unknown identifier` / `unknown namespace` — a missing import; find the
  module with `rg "def <name>" .lake/packages/mathlib/Mathlib/`.
- `failed to synthesize instance ... Fintype` — add
  `import Mathlib.Data.Fintype.Pi` (for function types).
- `failed to synthesize ... LocallyFiniteOrder ℕ` — add
  `import Mathlib.Order.Interval.Finset.Nat` (needed for `Finset.Icc`).
- `Nat.Even` / `Nat.Odd` unknown — recent mathlib uses the generic `Even` /
  `Odd` from `Mathlib.Algebra.Ring.Parity`.
- `unknown identifier omega` / `bad import Mathlib.Tactic.Omega` — there is no
  `Mathlib.Tactic.Omega` module in the pinned mathlib; `omega` is provided by
  Lean core (and re-exported by some tactic modules).  Add the import the
  compiler asks for, or use `linarith`/`nlinarith` from
  `Mathlib.Tactic.Linarith`.
- `Mathlib.Algebra.BigOperators.Basic` does not exist — the `∑` notation lives
  in `Mathlib.Algebra.BigOperators.Group.Finset.Basic`.
- `decide`/`native_decide` fails on a concrete example — check that the
  definitions involved are computable (no `noncomputable` markers on the
  definitions being evaluated) and that the indices/bit order match the
  convention pinned in `Notation.md`.
