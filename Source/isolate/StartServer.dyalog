 StartServer←{ ⍝ Start an Isolate Server (not usually called by application code)
     0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
     ynys.StartServer ⍵
 }
