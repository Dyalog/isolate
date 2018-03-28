 r←pid InitConnection(addr port id remote);z;ok
     ⍝ Establish connection to new process,
     ⍝ Verify it's identity and configure it
     ⍝ Return CONGA client name or '' on failure

 ok←0
 :If 0≠⊃z←DRCClt('PROC',⍕pid)addr port
     ('ISOLATE: Unable to connect to ',addr,':',(⍕port),':',,⍕z)⎕SIGNAL 11
 :Else ⍝ Connection made
     r←1⊃z
     ok←id∊¯1,1⊃SendWait r('#.isolate.ynys.execute'('' 'identify'))
     :If id≠¯1 ⍝ Only set remote access if we started the process
         ok←(0=⍴remote)∨remote≡SendWait r('AllowRemoteAccess'remote)
     :EndIf

     :If ~ok
         r←''⊣DRC.Close r
     :EndIf
 :EndIf
