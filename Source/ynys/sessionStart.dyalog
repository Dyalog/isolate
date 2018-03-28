 sessionStart←{⍺←⊢
     24 60 60 1000{(dateNo ⍵)-(⍺-⍺⍺⊥3↓⍵)÷×/⍺⍺}/(2⊃⎕AI)⎕TS
⍝ diff twixt ⎕ts and ⎕ai
⍝ ← number of days and the decimal part thereof after the start of the last
⍝   day of the penultimate year of the nineteenth century: 1899-12-31 00.00
⍝ immune to system clock change as both rely on that.
 }
