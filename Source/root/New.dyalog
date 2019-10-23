 ø←{ ⍝ Model of [currency sign] (create isolate)
     ⍺←⊢
     0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN     ⍝ Throw all errors
     ⍺(#.isolate.ynys.New)⍵
 }
