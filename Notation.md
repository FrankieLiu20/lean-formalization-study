# Notation Dictionary: Paper ↔ Lean

Source: the paper chosen for this study (see `PLAN.md` §1.1).  Lean files:
`FormalProof/Definitions.lean` (definitions) and
`FormalProof/Statements.lean` (theorem statements, plus the phase modules that
own each proof).

Convention: Lean names are ASCII and final; this dictionary is the single
reference for matching paper symbols to Lean identifiers.

**Rule.** Every paper symbol that appears in the Lean code must have a row in
§1 or §2, and every Lean declaration whose statement comes from the paper must
name the paper label (backticked) in its docstring.  Ambiguities, typos and
statements that had to be corrected are recorded in §4 — this is a deliverable,
not a footnote.

---

## 1. Conventions and representation

| Paper | Meaning | Lean |
| --- | --- | --- |
| `{0,1}^n` | binary words of length `n` | `Word n := Fin n → Bool` |
| `x ⊕ y` | bitwise XOR | `bitXor x y` |
| `w(x)` | Hamming weight: number of ones | `hammingWeight x` |
| `d(x,y)` | Hamming distance `= w(x ⊕ y)` | `hammingDist x y` |
| `(n, M)` code | `M` codewords of blocklength `n` | `Code n M := Fin n → Column M`, `Column M := Fin M → Bool` |
| `c_j` | the `j`-th codeword (row) | `row C j : Word n` |
| `d_j(y)` | distance from `y` to codeword `j` | `dRow C j y` |
| `d_C(y)` | minimum distance from `y` to the code | `dCode C y` |
| `α_C(d)` | number of words with `d_C(y) = d` | `alpha C d` |
| `λ_C(ε)` | correct-decoding probability, BSC with crossover `ε` | `lambda C ε` |
| `(1-ε)^(n-x) ε^x` | per-word decoding weight | `weight n ε x` |
| equivalent codes | row permutation + column permutation + column flips | `Equivalent C C'` |

Global conventions:

* an `(n, M)` code is stored **column-major** (`Code n M = Fin n → Column M`);
  the codewords are `row C j = fun t => C t j`;
* `M ≥ 1` is carried as the typeclass assumption `[NeZero M]` (needed to take
  the minimum over the codewords in `dCode`);
* all blocklengths are `ℕ`; `ε` is a real number with `0 < ε < 1/2` whenever a
  performance comparison is stated;
* `FormalProof/Definitions.lean` takes `M` generic.  If the chosen paper only
  treats `M = 4`, the instantiation happens in the paper module (e.g. via a
  local `abbrev Code4 n := Code n 4`), not by specializing the core.

### Direction of comparison (fill in when the paper is chosen)

The single most error-prone convention: which side is "better".  Record it
here explicitly, with the paper's own wording, as soon as the performance
functional is defined — e.g.

```lean
/-- `thm:com` (Lemma 18): `C'` is universally at least as good as `C`. -/
def UniversalBetter {n M : ℕ} [NeZero M] (C' C : Code n M) : Prop :=
  ∀ ε : ℝ, 0 < ε → ε < 1 / 2 → lambda C' ε ≥ lambda C ε
```

and state in words which argument is the improved code.

---

## 2. Statement catalogue

One row per numbered paper result, added as the catalogue is written.

| Paper label | Paper name | Lean name | Module | Status |
| --- | --- | --- | --- | --- |
| _(to be filled in)_ | | | | |

---

## 3. Definitions specific to the chosen paper

_(to be filled in when the paper is chosen: each paper-specific definition,
its paper equation number, and its Lean name.)_

---

## 4. Discrepancies and corrections found during formalization

_(to be filled in: typos, missing hypotheses, off-by-one indices, statements
that only hold with an extra condition.  For each item: the paper label, what
the paper says, what is actually true, and how the Lean statement records it.
This section is a research output.)_
