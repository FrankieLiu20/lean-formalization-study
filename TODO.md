# TODO — open work

Follow `AGENTS.md` when working in this repository.

## Blocking

- [ ] Choose the target paper (see `PLAN.md` §1.1) and record the decision here
      and in `DEVLOG.md`.
- [x] Move the working copy out of OneDrive (`ONBOARDING.md` §3) — done: the
      working copy lives in `E:\lean\lean-formalization-study`.

## Repository hygiene

- [x] `git init`, first commit, and push to GitHub (`ONBOARDING.md` §8) —
      <https://github.com/FrankieLiu20/lean-formalization-study>
- [ ] Install the VS Code "Lean 4" extension (`ONBOARDING.md` §2).
- [x] Add the CI badge to `README.md` once the workflow has run once (green on
      the first successful run).
- [ ] Set the repository description/topics on GitHub.

## Formalization

- [ ] Fill in `PLAN.md` §1.1 (statement table) and §5 (dependency graph).
- [ ] Fill in `Notation.md` §1 (paper conventions) and §3 (paper definitions).
- [ ] Fill in `FormalProof/Statements.lean`.
- [ ] Add a paper-specific module per phase and import it from
      `FormalProof.lean`.

## Optional, later

- [ ] Generalise the core from `M` to arbitrary finite alphabets, if a chosen
      paper needs it.
- [ ] Contribute the paper-independent lemmas to mathlib (the reference
      project plans the same; see its `REUSE.md`).
- [ ] Port the core into a separate reusable library (the reference project
      does this with its `NMCode` library).
