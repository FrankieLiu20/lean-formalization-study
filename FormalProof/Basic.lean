import FormalProof.Definitions
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Finset.Max

/-!
# Basic lemmas

The first proved layer on top of `FormalProof/Definitions.lean`: the standard
algebraic properties of bitwise XOR and Hamming distance, and the elementary
facts about the distance to a code.

This module is the model for how every later proof module looks: one section
per topic, one short docstring per declaration, and a small
compile-time-checked example wherever a convention (bit order, an instance, a
formula) could be misread.

Adapted from `NMCode/CodingTheory.lean` in Shenghao Yang's
`n4code_lean_dev` repository (Apache-2.0); see `NOTICE`.
-/

open scoped BigOperators

namespace FormalProof

/-! ## Bitwise XOR -/

/-- XOR is commutative. -/
lemma bitXor_comm {n : ℕ} (x y : Word n) : bitXor x y = bitXor y x := by
  funext i
  by_cases hx : x i = true <;> by_cases hy : y i = true <;> simp [bitXor, hx, hy]

/-- XOR is associative. -/
lemma bitXor_assoc {n : ℕ} (x y z : Word n) :
    bitXor (bitXor x y) z = bitXor x (bitXor y z) := by
  funext i
  by_cases hx : x i = true <;> by_cases hy : y i = true <;> by_cases hz : z i = true <;>
    simp [bitXor, hx, hy, hz]

/-- XOR with itself is the all-zero word. -/
lemma bitXor_self {n : ℕ} (x : Word n) : bitXor x x = fun _ => false := by
  funext i
  by_cases hx : x i = true <;> simp [bitXor, hx]

/-- The all-zero word is the identity for XOR. -/
lemma bitXor_false {n : ℕ} (y : Word n) : bitXor (fun _ => false) y = y := by
  funext i
  by_cases hy : y i = true <;> simp [bitXor, hy]

/-- XOR is the all-zero word exactly when the two words agree. -/
lemma bitXor_eq_false_iff {n : ℕ} (x y : Word n) :
    (bitXor x y = fun _ => false) ↔ x = y := by
  constructor
  · intro h
    funext i
    have h' := congrFun h i
    cases hx : x i <;> cases hy : y i <;> simp [bitXor] at h'
    all_goals simp_all
  · intro h
    rw [← h]
    exact bitXor_self x

/-- Two bits differ exactly when their XOR is `true`. -/
lemma bool_xor_eq_true (a b : Bool) : Bool.xor a b = true ↔ a ≠ b := by
  cases a <;> cases b <;> simp [Bool.xor]

/-! ## Hamming weight and distance -/

/-- A word has Hamming weight zero exactly when it is the all-zero word. -/
lemma hammingWeight_eq_zero_iff {n : ℕ} (w : Word n) :
    hammingWeight w = 0 ↔ ∀ i : Fin n, w i = false := by
  unfold hammingWeight
  rw [Finset.sum_eq_zero_iff]
  constructor
  · intro h i
    have hi := h i (Finset.mem_univ i)
    cases hx : w i <;> simp [hx] at hi ⊢
  · intro h i _
    have hx : w i = false := h i
    simp [hx]

/-- Hamming distance is reflexive. -/
lemma hammingDist_self {n : ℕ} (x : Word n) : hammingDist x x = 0 := by
  rw [hammingDist, bitXor_self]
  simp [hammingWeight]

/-- Hamming distance is symmetric. -/
lemma hammingDist_symm {n : ℕ} (x y : Word n) : hammingDist x y = hammingDist y x := by
  rw [hammingDist, hammingDist, bitXor_comm]

/-- Hamming distance is zero exactly when the words are equal. -/
lemma hammingDist_eq_zero_iff {n : ℕ} (x y : Word n) : hammingDist x y = 0 ↔ x = y := by
  rw [hammingDist, hammingWeight_eq_zero_iff]
  rw [show (∀ i : Fin n, bitXor x y i = false) ↔ bitXor x y = fun _ => false by
    constructor
    · intro h
      funext i
      exact h i
    · intro h i
      simpa using (congrFun h i)]
  exact bitXor_eq_false_iff x y

/-- The Hamming distance between two `n`-bit words is at most `n`. -/
lemma hammingDist_le {n : ℕ} (x y : Word n) : hammingDist x y ≤ n := by
  unfold hammingDist hammingWeight
  calc
    (∑ i ∈ (Finset.univ : Finset (Fin n)), if bitXor x y i = true then 1 else 0) ≤
        ∑ _i ∈ (Finset.univ : Finset (Fin n)), 1 := by
      apply Finset.sum_le_sum
      intro i _
      by_cases h : bitXor x y i = true <;> simp [h]
    _ = n := by simp

/-! ## Distance to a code -/

/-- The distance to a code is at most the distance to any of its codewords. -/
lemma dCode_le_dRow {n M : ℕ} [NeZero M] (C : Code n M) (j : Fin M) (y : Word n) :
    dCode C y ≤ dRow C j y := by
  unfold dCode
  exact Finset.min'_le _ _ (Finset.mem_image.mpr ⟨j, Finset.mem_univ j, rfl⟩)

/-- The distance from any word to any code is at most `n`. -/
lemma dCode_le {n M : ℕ} [NeZero M] (C : Code n M) (y : Word n) : dCode C y ≤ n :=
  (dCode_le_dRow C ⟨0, NeZero.pos M⟩ y).trans (hammingDist_le _ _)

/-! ## Compile-time sanity checks

`decide` proves these goals by evaluating the definitions inside the kernel,
so they pin down the meaning of the model: if a definition is ever changed
(bit order, indices, normalisation) these examples stop compiling.
-/

/-- XOR of the two constant words is the all-zero word. -/
example : bitXor (fun _ : Fin 2 => true) (fun _ : Fin 2 => true) = fun _ => false := by
  decide

/-- The weight of `110` is 2. -/
example : hammingWeight (fun i : Fin 3 => decide (i.val < 2)) = 2 := by
  decide

/-- `100` and `010` are at Hamming distance 2. -/
example :
    hammingDist (fun i : Fin 3 => decide (i.val = 0)) (fun i : Fin 3 => decide (i.val = 1)) = 2 := by
  decide

/-- A word is at distance 0 from itself. -/
example : hammingDist (fun i : Fin 4 => decide (i.val % 2 = 0)) (fun i : Fin 4 => decide (i.val % 2 = 0)) = 0 := by
  decide

end FormalProof
