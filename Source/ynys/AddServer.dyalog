 r←AddServer w;msg;addr;ports;z;ss;id;pclts;m;old;local
 msg←messages'⍝- '
 :If 'server'≡Config'status' ⋄ r←0⊃msg ⋄ :Return ⋄ :EndIf
 :If local←''≡w
     addr←whoami''
 :Else
     :If ''⍬≢0/¨w ⋄ r←1⊃msg ⋄ :Return ⋄ :EndIf
     (addr ports)←,¨w
     :If {1∊∊∘∊⍨⍵⊣⎕ML←0}addr ports ⋄ r←2⊃msg ⋄ :Return ⋄ :EndIf
 :EndIf
 z←Config'status' 'client'
 z←Init 0
 ss←session
 :If (⊂addr)∊ss.procs[;2] ⋄ r←(3⊃msg),' ',addr ⋄ :Return ⋄ :EndIf
 :If local
     ss.procs⍪←ss InitProcesses options
 :Else
     id←(⍳≢ports)+1+0⌈⌈/⊣/ss.procs
     ss.retry_limit←2⊣old←ss.retry_limit
     pclts←id InitConnections addr ports ¯1 ⍬
     ss.retry_limit←old
     :If m←0∊≢¨pclts ⋄ r←(4⊃msg),' ',addr,': ',⍕m/ports ⋄ :Return ⋄ :EndIf
     ss.procs⍪←id,0,(⊂addr),ports,⍪pclts
 :EndIf
 r←State''
⍝- Session already started as server
⍝- Argument must be 'ip-address' (ip-ports)
⍝- IP-address nor IP-ports can be empty
⍝- Already added:
⍝- Unable to connect to
