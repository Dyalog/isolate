 r←SendWait(r cmd);z
     ⍝ Used by InitConnection for first 2 transactions with newly started process
 :If 0=⊃z←DRC.Send r cmd
 :AndIf 0=⊃z←DRC.Wait r 30000
     :If 0 'Receive'≡z[0 2]
         r←3 1⊃z
     :EndIf
 :Else
     {}DRC.Close r
     ('ISOLATE: New process did not respond to handshake:',,⍕z)⎕SIGNAL 11
 :EndIf
