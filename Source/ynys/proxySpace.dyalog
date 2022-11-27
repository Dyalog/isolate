:Namespace proxySpace
(⎕IO ⎕ML ⎕WX)←0 1 3

 iEvaluate←{z←{0::0 ⋄ 2503⌶⍵}3 ⍝ Thread and its children are un-interruptible
     ⍺←⊢
     data←⍺ iSpace.encode ⍵
     ID←iD.numid
     ss←{iSpace.session}⍣home⊢home←2∊⎕NC'iSpace.session.started' ⍝ is this true ?
     z←{iso←ss.assoc.iso
         (≢iso)≤i←iso⍳⍵:'ISOLATE: No longer accessible'⎕SIGNAL 6
         (i⊃ss.assoc.busy)←1}⍣home⊢ID
     (rc res)←z←iSend iD.tgt data      ⍝ the biz
     ok←0=rc
     ~home:{rc=0:⍵ ⋄ ⍎'#.Iso',(⍕ID),'error←rc ⍵' ⋄ ⎕SIGNAL rc}res   ⍝ call back? then we're done
     z←ss.assoc.{((iso⍳⍵)⊃busy)←0}ID
     ok:⊢res                           ⍝ spiffing!
     (,⍕(⍕rc),': ',(0⊃res),{(⍵∨.≠' ')/': ',⍵}1⊃res,'' '')iSpace.qsignal rc
        ⍝ execute expression supplied to isolate
 }

∇ r←iSend data;send;ev;nm;rc;res;cmd
 send←'#.isolate.ynys.execute' data    ⍝ RPCServer runs this
 :Trap 0 ⋄ res←iSpace.DRC.Send iD.chrid send
 :Else
     'ISOLATE: Transmission failure'iSpace.qsignal 6
 :EndTrap
 rc cmd ev data←4↑res
 :If 0≠rc ⋄ r←86(('COMMUNICATIONS FAILURE ',⍕rc cmd)ev)          ⍝ ret ⎕EN ⎕DM
 :Else
WAIT:
     :Trap 1000
         :Repeat
             res←(rc nm ev data)←4↑iSpace.DRC.Wait cmd
         :Until ~(rc=100)∨(⊂ev)∊'Progress' 'Timeout' ⍝ Tolerate eventmode on (ev="Timeout") or off (rc=100)
     :Else
         iSpace.checkLocalServer ⍬
         ⍞←'ISOLATE: Interrupt - continue waiting (Y/N)? '
         →(∨/'Yy'∊⊃{(1+⍵⍳'?')↓⍵}⍞~' ')⍴WAIT
         ('USER INTERRUPT ',⍕⎕DMX.EN)iSpace.qsignal 6
     :EndTrap
     :If rc=0
         :If 0=⊃data ⋄ r←1⊃data     ⍝ if rc is 0 res which will be (0 result)
         :Else ⋄ r←(1↑data),⊂1↓data,⊂'' ⍝ error from RPCServer framework itself
         :EndIf
     :Else ⋄ r←rc((⍕rc nm)ev) ⍝ else return rc and faked ⎕DM
     :EndIf
        ⍝ called from iSyntax, iEvaluate and from
        ⍝ ##.cleanup to remove isolate from remote process
 :EndIf
∇

 iSyntax←{⍺←⊢
                   ⍝z←tracelog ⍵
     c←⊣/⍵
     '('=c:⊢3 32                            ⍝ if '(expr)' ⍝ 1 0 0 0 0 0
     '{'=c:⊢3 52                            ⍝ if '{defn}' ⍝ 1 1 0 1 0 0
     '#'∊⍵:⊢0 0                             ⍝ # in anything un-parenthesised is an error
     '⎕'=c:⊢{0::0 0 ⋄ x←⍎⍵ ⋄ c←⎕NC'x' ⋄ (2 3⍳c)⊃(2 0)(3 52)(0 0)}⍵ ⍝ assumes ⎕FNS ambi
                                                    ⍝ ↑ reject ops & nss
     f←',⊢-⊂⍴⊃≡+!=⍳⊣↓↑|⍪⍕⍎∊⌽~×≠>⌊∨?⌷<≢⌈≥⍷⍉∪÷⍒⊥∧⍋⊖*○⍲⍱⍟⌹⊤≤∩'
     
     c∊f:⊢3 52
     0>⎕NC ⍵:⊢0 0                           ⍝ primitive operators
     expr←'((2⍴⎕nc∘⊂,⎕at),''',⍵,''')'       ⍝ then what is it?
     (rc res)←iSend iD.tgt(0 expr)          ⍝ from the horse's mouth
     rc≠0:(,⍕res)iSpace.qsignal rc          ⍝ lost connection?
     (nc at)←res                            ⍝ ⎕NC ⎕AT - rc?
     nc∊3.2 3.3:⊢3 52                       ⍝ 3,32+16+4 res ambi omega
     c←⌊nc                                  ⍝ class
     c∊0 2:⊢2 0                             ⍝ undef, var
     (r fv ov)←at                           ⍝ result, valence
     w←∨/(a d w)←fv=¯2 2 1                  ⍝ (ambi, dyad, omega)
     r←c,2⊥r a d w 0 0                      ⍝ class, encoded syntax
     1:⊢r
        ⍝ return nameclass and syntax for supplied name (string)
 }

:EndNamespace 
