 r←cleanDM r;t;msg;line;caret;m
 →(0=⊃r)⍴0         ⍝ Not an error
 →(3≠⍴t←1⊃r)⍴0     ⍝ Not a ⎕DM
 (msg line caret)←t
 msg←('⍎'=⊃msg)↓msg
 :If 'f[] f←'≡6↑line ⋄ (line caret)←6↓¨line caret
 :ElseIf 'decode['≡7↑line
     :If ∨/':Case'⍷line ⋄ line←caret←''
     :ElseIf ∨/m←'c⌷[d]where.'⍷line
         (line caret)←(11+m⍳1)↓¨line caret
         line←((⌊/line⍳') ')↑line),'[...]',('←'∊line)/'←...'
     :Else ⋄ (line caret)←(1+line⍳']')↓¨line caret
     :EndIf
 :EndIf
 (1⊃r)←msg line caret
