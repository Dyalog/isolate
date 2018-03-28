 II←{ ⍝ Model of parallel operator: [⍺] (f II) ⍵
    ⍺←⊢
    0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN       ⍝ Throw all errors
    ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.ll⊢⍵ ⍝ Monadic case
    ⍺(⍺⍺ #.isolate.ynys.ll)⍵     ⍝ Dyadic case
    }
