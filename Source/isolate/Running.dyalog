 Running←{ ⍝ 1 for items of ⍵ which are still futures which are being computed, else 0
     0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
     ynys.Running ⍵
 }
