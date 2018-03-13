 r←localServer r;srv;rc;z;old
 →(0=⎕NC'session.homeport')⍴0

 :If r=0
 :AndIf r←DRC.Exists srv←'ISO',⍕session.homeport ⍝ Server exists
     {}DRC.Close srv ⍝ Left over - object there but no thread
     :If 2=⎕NC'session.listeningtid'
         ⎕TKILL session.listeningtid
         ⎕EX'session.listeningtid'
     :EndIf
 :Else

     :If r←DRC.Exists srv←'ISO',⍕session.homeport ⍝ Server exists
         :If r←2=⎕NC'session.listeningtid'
         :AndIf r←session.listeningtid∊⎕TNUMS
         :Else
             {}DRC.Close srv ⍝ Left over - object there but no thread
         :EndIf
     :EndIf

     :If ~r ⍝ Already got a listening server
     :AndIf options.listen
         old←{0::0 ⋄ 2503⌶⍵}3 ⍝ Make thread and children un-interruptible
         :Repeat
             :If r←0=rc←⊃z←1 1 ##.RPCServer.Run srv session.homeport
                 session.listeningtid←1⊃z
             :ElseIf 10048=rc ⍝ Socket already in use
                 session.homeport+←options.(1+processes×processors)
             :EndIf
         :Until r∨session.homeport>options.homeportmax
         old←{0::0 ⋄ 2503⌶⍵}old ⍝ Restore thread state
         ('Unable to create listener: ',,⍕z)⎕SIGNAL r↓11
     :EndIf
 :EndIf
