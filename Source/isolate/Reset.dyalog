 Reset←{ ⍝ Reset all isolate processes
     0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
     ynys.Reset ⍵
 }
