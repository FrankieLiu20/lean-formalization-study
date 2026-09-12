# Paper ↔ Lean consistency protocol

Source of truth: the paper chosen in `PLAN.md` §1.1 (its LaTeX source, if
available, otherwise the published PDF).

**Rule:** after every step of Lean development (each change that touches
definitions, statements or proofs — i.e. each commit), run the consistency
check before finishing.  If it fails, fix the mismatch in the same step.  For
what "verified" means at release level (axiom allowlist, fresh-clone
reproduction, CI), see `VERIFICATION.md`; this file is the per-step
development protocol.

## 1. Automated check (always run)

```powershell
pwsh scripts/consistency_check.ps1
# if the paper's LaTeX source lives elsewhere:
pwsh scripts/consistency_check.ps1 -PaperTex "C:\path\to\paper.tex"
```

If a LaTeX source is available (not just a PDF), the script additionally checks
the label correspondence.  It verifies:

1. `lake build` passes (incremental);
2. every paper label referenced in a `FormalProof/*.lean` docstring or in
   `Notation.md` exists as `\label{...}` in the paper (Lean/Notation → paper) —
   catches invented or misremembered references;
3. every theorem/lemma/corollary/proposition label in the paper appears
   somewhere in the library (paper → Lean) — catches theorems not yet stated;
4. every module under `FormalProof/` is imported by the library — no orphan
   modules that `lake build` would silently skip;
5. how many `sorry` statements remain in code (comments/docstrings excluded;
   informational — the authoritative stub gate is `scripts/axioms_check.ps1`,
   which fails on `sorryAx`).

**Scope of the automated checks:** they are label- and build-level only.  They
cannot verify that a Lean statement's hypotheses or formulas semantically
match the paper.  That is the job of the manual checklist below, done in the
same step.

## 2. Manual checklist (per step, in addition to the script)

For each definition or theorem touched in the step:

- [ ] the definition matches the paper's equation/formula exactly, including
      the conventions listed in `Notation.md` §1 (bit order, index origin,
      normalisation);
- [ ] the theorem statement has the same hypotheses as the paper (parity
      conditions, ranges of parameters such as `0 < ε < 1/2`, strict versus
      non-strict inequalities, "for all sufficiently large n" wording);
- [ ] the docstring carries the paper label, backticked and with the section
      number (never a tex line number);
- [ ] equality/strictness characterisations list the same cases as the paper;
- [ ] any new paper symbol is added to `Notation.md`; anything that had to be
      corrected or clarified is recorded in `Notation.md` §4;
- [ ] statements added in this step live in the phase module that owns them and
      are reachable from the library root module (`FormalProof.lean`).

## 3. When to re-check the whole paper

- after every phase completes;
- whenever the paper file changes (e.g. a new arXiv version);
- whenever a statement is strengthened or weakened during proving.
