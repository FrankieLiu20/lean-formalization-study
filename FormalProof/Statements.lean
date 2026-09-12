import FormalProof.Definitions

/-!
# Paper theorem statements

The paper-numbered catalogue: every numbered theorem, lemma, corollary and
proposition of the target paper gets exactly one Lean declaration here (or in
the phase module that owns its proof).  The paper label appears backticked in
the docstring — e.g. `` `thm:two` (Theorem 1) `` — so that
`scripts/consistency_check.sh` can check the paper ↔ Lean correspondence in
both directions.

Conventions:
* state the paper's hypotheses literally; when they can be weakened, keep the
  paper's version as the statement and record the stronger version in the
  module that proves it (`DEVLOG.md` is the place to explain the change);
* an unfinished proof is written `:= by sorry` **with the paper label in the
  docstring above it**; a module with `sorry` is acceptable, a module with
  errors is not;
* nothing in this file may be deleted once the paper's theorem is proved —
  it is the catalogue reviewers read.

The catalogue is empty until the target paper is chosen; see `PLAN.md` §1.1
for how the statement table is built from the paper.
-/

namespace FormalProof

-- TODO(paper): add the paper's numbered statements here, in paper order.
--
-- Template (copy, paste, fill in):
--
-- /-- `thm:example` (Theorem 1) of §2: one-line statement of the theorem. -/
-- theorem example_statement {n M : ℕ} [NeZero M] (C : Code n M) (h : …) :
--     … := by
--   sorry

end FormalProof
