import FormalProof.Basic

/-!
# Axiom audit

`#print axioms` for every headline lemma: the Lean kernel prints the axioms a
proof actually depends on.  For this development the expected set is the
mathlib-standard trusted base

* `propext`, `Quot.sound`, `Classical.choice`,

and nothing else.  In particular `sorryAx` (an unfinished proof) and the
`native_decide` trust axioms must never appear in a headline result;
`scripts/axioms_check.ps1` enforces the allowlist and fails on `sorryAx`.

Every name here must also appear in `scripts/headline_theorems.txt` (the
manifest is checked in both directions, so a headline result cannot be added
or dropped silently).
-/

namespace FormalProof

#print axioms hammingDist_self
#print axioms hammingDist_symm
#print axioms hammingDist_eq_zero_iff
#print axioms hammingDist_le
#print axioms dCode_le

end FormalProof
