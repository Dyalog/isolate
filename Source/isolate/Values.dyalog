 Values←{ ⍝ Return computed values in ⍵, return ⍺ in place of futures (or ⎕NULL if ⍺ not specified)
     ⍺←⊢
     0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
     ⍵≡⍺ ⍵:ynys.Values⊢⍵
     ⍺(ynys.Values)⍵
 }
