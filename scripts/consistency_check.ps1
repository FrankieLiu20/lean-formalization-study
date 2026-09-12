<#
.SYNOPSIS
    Paper <-> Lean consistency check.  Run after EVERY step of development.

.DESCRIPTION
    1. builds the project (incremental);
    2. checks that every paper label referenced from a FormalProof/*.lean
       docstring or from Notation.md exists in the paper (Lean/Notation -> paper);
    3. checks that every theorem/lemma/corollary/proposition label in the paper
       appears somewhere in the library (paper -> Lean);
    4. checks that every module under FormalProof/ is imported by the library
       (no orphan modules that `lake build` would silently skip);
    5. reports how many `sorry` statements remain in code (comments and
       docstrings excluded; informational -- the authoritative stub gate is
       scripts/axioms_check.ps1, which fails on `sorryAx`).

    These checks are label-level only: semantic fidelity to the paper
    (hypotheses, conditions, formulas) is enforced by the manual checklist in
    CONSISTENCY.md.

    If the paper's LaTeX source is not found, the label checks [3]/[4] are
    skipped with a warning while the build and orphan-module checks still run,
    so the script works on a fresh clone that does not ship the paper.

.PARAMETER PaperTex
    Path to the paper's LaTeX source.  Defaults to $env:PAPER_TEX, then to the
    first .tex file under paper/ if that directory exists.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\consistency_check.ps1
    powershell -ExecutionPolicy Bypass -File scripts\consistency_check.ps1 -PaperTex "C:\papers\main.tex"

.NOTES
    Works in both Windows PowerShell 5.1 (`powershell`) and PowerShell 7
    (`pwsh`).  The file is pure ASCII on purpose: Windows PowerShell 5.1 reads
    .ps1 files as ANSI unless they carry a byte-order mark.
#>
[CmdletBinding()]
param([string]$PaperTex)

$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$failed = 0

# -------------------------------------------------------------- paper source
Write-Host '== [1/5] paper source =='
if (-not $PaperTex) { $PaperTex = $env:PAPER_TEX }
if (-not $PaperTex -and (Test-Path 'paper')) {
  $cand = Get-ChildItem 'paper' -Filter *.tex -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($cand) { $PaperTex = $cand.FullName }
}
$hasPaper = $false
if ($PaperTex -and (Test-Path -LiteralPath $PaperTex)) {
  $hasPaper = $true
  Write-Host "  ok: $(Split-Path -Leaf $PaperTex)"
} else {
  Write-Host '  skip: paper LaTeX source not found (pass -PaperTex <path>)'
  Write-Host '        label checks [3/4] are skipped; build and orphan checks still run.'
}

# ------------------------------------------------------------------- 2. build
Write-Host '== [2/5] lake build (incremental) =='
lake build
if ($LASTEXITCODE -ne 0) {
  Write-Host 'FAIL: build'
  exit 1
}

$leanFiles = @(Get-ChildItem 'FormalProof' -Filter *.lean -ErrorAction SilentlyContinue)

# ------------------------------------- 3. Lean/Notation -> paper (labels used)
Write-Host '== [3/5] Lean/Notation -> paper: referenced labels must exist in the paper =='
if ($hasPaper) {
  $tex = Get-Content -LiteralPath $PaperTex -Raw
  $used = @()
  foreach ($f in $leanFiles) {
    $t = Get-Content -LiteralPath $f.FullName -Raw
    $used += [regex]::Matches($t, '`(thm|lemma|cor|lm|the|eq):[a-z0-9_-]+`') |
      ForEach-Object { $_.Value.Trim('`') }
  }
  if (Test-Path 'Notation.md') {
    $t = Get-Content 'Notation.md' -Raw
    $used += [regex]::Matches($t, '(thm|lemma|cor|lm|the|eq):[a-z0-9_-]+') |
      ForEach-Object { $_.Value }
  }
  $used = @($used | Sort-Object -Unique)
  $miss = 0
  foreach ($lb in $used) {
    if ($tex -notmatch [regex]::Escape("\label{$lb}")) {
      Write-Host "  MISSING in paper: $lb"
      $miss = 1
    }
  }
  if ($miss -eq 1) { $failed = 1 }
  elseif ($used.Count -eq 0) { Write-Host '  ok: no paper labels referenced yet' }
  else { Write-Host "  ok: all $($used.Count) referenced label(s) exist in the paper" }
} else {
  Write-Host '  skipped (no paper source)'
}

# ------------------------------------- 4. paper -> Lean (labels must be stated)
Write-Host '== [4/5] paper -> Lean: theorem-like labels must appear in the library =='
if ($hasPaper) {
  $inEnv = $false
  $texLabels = @()
  foreach ($line in Get-Content -LiteralPath $PaperTex) {
    if ($line -match '\\begin\{(theorem|lemma|corollary|proposition)\}') { $inEnv = $true }
    if ($inEnv) {
      foreach ($m in [regex]::Matches($line, '\\label\{([^}]+)\}')) { $texLabels += $m.Groups[1].Value }
    }
    if ($line -match '\\end\{(theorem|lemma|corollary|proposition)\}') { $inEnv = $false }
  }
  $texLabels = @($texLabels | Sort-Object -Unique)
  $missing = 0
  foreach ($lb in $texLabels) {
    if ($lb -match '^(eq|fig|tab|ex|sec|app|alg|def|rem):') { continue }
    $found = $false
    foreach ($f in $leanFiles) {
      if (Select-String -LiteralPath $f.FullName -Pattern $lb -SimpleMatch -Quiet) { $found = $true; break }
    }
    if (-not $found) {
      Write-Host "  NOT covered in the library: $lb"
      $missing = 1
    }
  }
  if ($missing -eq 1) { $failed = 1 }
  else { Write-Host "  ok: all $($texLabels.Count) theorem-like paper label(s) are stated" }
} else {
  Write-Host '  skipped (no paper source)'
}

# ---------------------------------------------------------- 5. orphans + sorry
Write-Host '== [5/5] module graph and sorry count =='
$orphans = 0
foreach ($f in $leanFiles) {
  $importLine = "import FormalProof.$($f.BaseName)"
  $hit = $false
  foreach ($g in @(Get-ChildItem -Filter *.lean) + $leanFiles) {
    if ($g.FullName -eq $f.FullName) { continue }
    if (Select-String -LiteralPath $g.FullName -Pattern $importLine -SimpleMatch -Quiet) { $hit = $true; break }
  }
  if (-not $hit) {
    Write-Host "  NOT imported by any module: FormalProof/$($f.BaseName).lean"
    $orphans = 1
  }
}
if ($orphans -eq 1) { $failed = 1 } else { Write-Host '  ok: all FormalProof modules are imported' }

$sorryCount = 0
foreach ($f in $leanFiles) {
  foreach ($line in Get-Content -LiteralPath $f.FullName) {
    if ($line -match '^\s*(\u00B7\s*)?sorry(\s|$)') { $sorryCount++ }
  }
}
Write-Host "  sorry statements in code: $sorryCount (comments/docstrings excluded;"
Write-Host '                            see scripts/axioms_check.ps1 for the stub gate)'

if ($failed -eq 0) {
  Write-Host 'OK: paper and Lean are in sync (build, labels, module graph).'
} else {
  Write-Host 'FAIL: see items above; fix before committing (CONSISTENCY.md).'
}
exit $failed
