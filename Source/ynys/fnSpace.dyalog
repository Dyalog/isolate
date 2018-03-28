 fnSpace←{⍺←⊢

     trapErr''::signal''
     s←(callerSpace'').⎕NS''
     N←,⍵
     f←⍺⍺
     c←⎕CR'f'
     q←'#'≡⊃⊃c    ⍝ qualified
     c←⊃∘⌽⍣q⊢c    ⍝ remove qualification
     d←'{'≡⍬⍴c    ⍝ anon dfn
     t←1=≢⍴c      ⍝ tacit derv
     n←s.⎕FX{,↓⍣(1=≡⍵){N,'←',1↓,'⋄',⍵}⍣d⊢⍵}c
     ⍝ name anon dfn as N
     z←s.⎕FX(,↓N,'←{⍺←⊢ ⋄ ⍺',n,'⍵}')/⍨~(⊂n)∊N 0 1
     ⍝ if not N then N calls it
     z←s.⍎⍣t⊢N,'←',f derv⍣t⊢0
     1:s
⍝ ⍺⍺ fn
⍝ ⍵  required name for fn in space
⍝ ←  space child of caller containing fn as ⍵
⍝    for use by ephemeral isolates in llEach &c.

     trapErr''::signal''
     op←{}
     z←⎕FX,⊂'op←{⍵.',⍵,'←⍺⍺ ⋄ ⍵}'
     1:⍺⍺ op(callerSpace'').⎕NS''
⍝ possible alternative algorithm 2014-03-09
⍝ so far I can't find the reason I thought I needed
⍝ all the other stuff as this seems to do it ok.

 }
