import FormalProof.Definitions
import FormalProof.Basic
import FormalProof.Statements
import FormalProof.AxiomCheck

/-!
# FormalProof

Library root module.  It must live at the package root and its module name
must equal the library name in `lakefile.toml`; `lake build` compiles the
whole formalization by importing the modules below.

Layout:
* `FormalProof/Definitions.lean` — the paper-independent mathematical model
  (binary words, Hamming distance, `(n, M)` codes, ML decoding).
* `FormalProof/Basic.lean` — proved lemmas about that model.
* `FormalProof/Statements.lean` — the paper-numbered statement catalogue.
* `FormalProof/AxiomCheck.lean` — `#print axioms` audit of the headline results.

When a paper is chosen, add one module per proof phase (see `PLAN.md`) and
import it here, otherwise `lake build` silently skips it.
-/
