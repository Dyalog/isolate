 Failed←{⍝ 1 if an items of ⍵ was a future but computation failed, else 0
     0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
     ynys.Failed ⍵
 }
