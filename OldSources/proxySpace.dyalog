:namespace proxySpace
⍝ ## ←→ #.isolate.ynys

(⎕IO ⎕ML)←0 0

 iEvaluate←{⍺←⊢
     data←⍺ iSpace.RPCIsolate.encode ⍵
     100+⍳100::(⊃⊣/⎕DM)⎕SIGNAL ⎕EN-100
     res←iSend iD.tgt data
     1:res
⍝ execute expression supplied to isolate
⍝ see notes
 }

 iSend←{data←⍵
     send←('##.RPCIsolate.execute')data   ⍝ RPCServer runs this
     res←iSpace.DRC.Send iD.chrid send
     0≠0⊃res:(⍕res)⎕SIGNAL 100+11
     wait←{
         (r n e d)←res←4↑iSpace.DRC.Wait 1⊃⍵
         r=100:⍵⊣⎕DL 0.1
         r≠0:(⍕res)⎕SIGNAL 100+11
         e≡'Progress':⍵⊣⎕DL 0.1
         e≡'Receive':1 d
         .uh?
     }
     res←1⊃wait⍣(⊃⊣)2⍴res
⍝ ↓ APL error via RPCServer
     0≠0⊃res:{(¯1↓⊃,/⍺,¨⎕UCS 13 13 0)⎕SIGNAL 100+⍵}/⌽res
     res←1⊃res
     1:res
⍝ called from both iEvaluate and iSyntax and also from
⍝ ##.cleanup to get rid of isolate from remote process
 }

 iSyntax←{⍺←⊢
     c←⊣/⍵
     '('=c:⊢3 32                            ⍝ if '(expr)'
     '{'=c:⊢3 52                            ⍝ if '{defn}'
     '⎕'=c:⊢{x←⍎⍵ ⋄ c←⎕NC'x' ⋄ (2 3⍳c)⊃(2 0)(3 52)(0 0)}⍵
                                            ⍝ ↑ reject ops & nss
     f←'!*+,-<=>?|~×÷↑↓∊∧∨∩∪≠≡≢≤≥⊂⊃⊖⊢⊣⊤⊥⌈⌊⌷⌹⌽⍉⍋⍎⍒⍕⍟⍪⍱⍲⍳⍴⍷○'
     c∊f:⊢3 52
     0>⎕NC ⍵:⊢0 0                           ⍝ /\¨⍣⍤⌸
     expr←'((2⍴⎕nc∘⊂,⎕at),''',⍵,''')'       ⍝ then what is it?
     (nc at)←iSend iD.tgt(0 expr)           ⍝ from the horse's mouth
     nc∊3.2 3.3:⊢3 52                       ⍝ 3,32+16+4 res ambi omega
     c←⌊nc                                  ⍝ class
     c∊0 2:⊢2 0                             ⍝ undef, var
     (r fv ov)←at                           ⍝ result, valence
     w←∨/(a d w)←fv=¯2 2 1                  ⍝ (ambi, dyad, omega)
     r←c,2⊥r a d w 0 0                      ⍝ class, encoded syntax
     1:⊢r
⍝ return nameclass and syntax for supplied name (string)
⍝ see notes
 }

:endnamespace
