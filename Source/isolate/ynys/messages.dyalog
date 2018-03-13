 messages←{⍺←⊢
     {(+/∨\' '≠⌽⍵)↑¨↓⍵}⍵{(0,⍴,⍺)↓⍵⌿⍨>/⍺⍷⍵}⎕CR⊃1↓⎕XSI
⍝ attached to caller
 }
