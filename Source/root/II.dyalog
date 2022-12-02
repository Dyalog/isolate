 II←{ ⍝ Model of parallel operator: [⍺] (f II) ⍵
     0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN       ⍝ Throw all errors
     0=⎕NC'⍺':(⍺⍺ #.isolate.ynys.ll)⍵
     ⍺(⍺⍺ #.isolate.ynys.ll)⍵
 }
