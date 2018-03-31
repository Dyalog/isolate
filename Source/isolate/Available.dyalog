 Available←{ ⍝ 1 if an item of ⍵ has been computed, 0 if it is still a future
     0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
     ynys.Available ⍵
 }
