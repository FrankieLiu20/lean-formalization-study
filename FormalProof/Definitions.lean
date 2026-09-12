import Mathlib.Data.Fintype.Pi
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Finset.Max
import Mathlib.Basic.Real.Basic

/-!
# Core definitions

The paper-independent layer of the formalization: binary words, Hamming
distance, `(n, M)` binary codes, maximum-likelihood decoding
(`dCode`, `alpha`, `lambda`), and code equivalence.

Everything is parameterized by the blocklength `n` and the number of
codewords `M` (with `[NeZero M]`, i.e. `M ≥ 1`).  Paper-specific notions
(code classes, special regions, extra performance functionals) belong in
their own module, not here.

Adapted from `NMCode/CodingTheory.lean` in Shenghao Yang's
`n4code_lean_dev` repository (Apache-2.0); see `NOTICE`.
-/

open scoped BigOperators

namespace FormalProof

/-! ## Binary words and Hamming distance -/

/-- An `n`-bit binary word, i.e. the set `{0,1}^n`. -/
abbrev Word (n : ℕ) := Fin n → Bool

/-- Bitwise XOR `x ⊕ y` of two words. -/
def bitXor {n : ℕ} (x y : Word n) : Word n := fun i => Bool.xor (x i) (y i)

/-- Hamming weight `w(x)`: the number of ones in `x`. -/
def hammingWeight {n : ℕ} (x : Word n) : ℕ :=
  ∑ i ∈ (Finset.univ : Finset (Fin n)), if x i = true then 1 else 0

/-- Hamming distance `d(x,y) = w(x ⊕ y)`. -/
def hammingDist {n : ℕ} (x y : Word n) : ℕ := hammingWeight (bitXor x y)

/-! ## `(n, M)` codes and ML decoding -/

/-- A column of an `(n, M)` code: the `M` entries (codeword 0 at index 0). -/
abbrev Column (M : ℕ) := Fin M → Bool

/-- An `(n, M)` code, given by its `n` columns. -/
abbrev Code (n M : ℕ) := Fin n → Column M

/-- The `j`-th codeword (row) of a code. -/
def row {n M : ℕ} (C : Code n M) (j : Fin M) : Word n := fun t => C t j

/-- `d_j(y)`: Hamming distance from the word `y` to the `j`-th codeword. -/
def dRow {n M : ℕ} (C : Code n M) (j : Fin M) (y : Word n) : ℕ :=
  hammingDist (row C j) y

/-- The image of the row-index set under a distance function is nonempty as
soon as `M ≥ 1`; needed to take the minimum over the codewords. -/
lemma row_image_nonempty (M : ℕ) [NeZero M] (f : Fin M → ℕ) :
    ((Finset.univ : Finset (Fin M)).image f).Nonempty :=
  Finset.image_nonempty.mpr ⟨⟨0, NeZero.pos M⟩, Finset.mem_univ _⟩

/-- `d_C(y)`: the minimum Hamming distance from `y` to any codeword of `C`. -/
def dCode {n M : ℕ} [NeZero M] (C : Code n M) (y : Word n) : ℕ :=
  ((Finset.univ : Finset (Fin M)).image (fun j : Fin M => dRow C j y)).min'
    (row_image_nonempty M _)

/-- `α_C(d)`: the number of words whose code distance is exactly `d`. -/
def alpha {n M : ℕ} [NeZero M] (C : Code n M) (d : ℕ) : ℕ :=
  ∑ y : Word n, if dCode C y = d then 1 else 0

/-- `λ_C(ε)`: the average correct-decoding probability of `C` under
maximum-likelihood decoding on a binary symmetric channel with crossover
probability `ε` (normalized by `1 / M`). -/
noncomputable def lambda {n M : ℕ} [NeZero M] (C : Code n M) (ε : ℝ) : ℝ :=
  (1 / (M : ℝ)) * ∑ y : Word n, (1 - ε) ^ (n - dCode C y) * ε ^ (dCode C y)

/-- Per-word decoding weight `(1-ε)^(n-x) ε^x`. -/
def weight (n : ℕ) (ε : ℝ) (x : ℕ) : ℝ := (1 - ε) ^ (n - x) * ε ^ x

/-! ## Equivalence -/

/-- Two codes are *equivalent* when one is obtained from the other by a row
permutation `ρ`, a column permutation `p`, and flipping all bits of some
columns `f`.  Equivalent codes have the same performance. -/
def Equivalent {n M : ℕ} (C C' : Code n M) : Prop :=
  ∃ ρ : Equiv (Fin M) (Fin M), ∃ p : Equiv (Fin n) (Fin n), ∃ f : Fin n → Bool,
    ∀ t : Fin n, C' (p t) = fun j : Fin M => if f t then !(C t (ρ j)) else C t (ρ j)

end FormalProof
