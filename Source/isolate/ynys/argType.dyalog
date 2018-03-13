 argType←{⍺←⊢
     trapErr''::signal''
     (0∊⍴)⍵:⍺.⎕NS''                                         ⍝ empty
     (0=≡)and{9=⎕NC'⍵'}⍵:⍵                                  ⍝ ns
     (1=≡)and(''≡0⍴⊢)⍵:checkWs ⍵
     (2=≡)and(''≡0⍴⊃)nl←,¨⍵:⍺.⎕NS↑nl                              ⍝ nl
     ⎕SIGNAL 11
⍝ ⍺ caller
⍝ ⍵ arg to new - empty | space | namelist | string
⍝ ← :
⍝      arg | res
⍝      --- + ---
⍝    empty | empty ns
⍝    space | clone ns
⍝     list | ns containing named fns
⍝   string | validated wsid
 }
