 Config←{ ⍝ ⍵: option new-value (or '' to list current settings)
     0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
     ynys.Config ⍵
 }
