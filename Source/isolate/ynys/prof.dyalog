 prof←{⍺←⊢ ⋄ ⎕IO←0
     z←⎕PROFILE'clear'
     z←⎕PROFILE'start'
     r←⍺ ⍺⍺⍣⍵⍵⊢⍵
     z←⎕PROFILE'stop' ⋄ e←⍬⍴⎕LC
     p←e↓⎕PROFILE'data'
     p[;3 4]{⌊0.5+100×⍺÷⍵}←0 4⌷p
     p[;]←p[⍒p[;3];]
     n←{⍺,~∘' '⍕,'[',(⍪⍵),']'}/2↑⍤1⊢p
     p←4↑⍤1⊢n,0 2↓p
     p⍪⍨←'operation[]' 'called' 'exclusive %' 'inclusive %'
     r p
⍝ ⍺     [larg]
⍝ ⍺⍺    fn
⍝ ⍵⍵    rop to ⍣ (fn or int)
⍝ ⍵     rarg
⍝ ←     res prof
⍝ res   result of: ⍺ ⍺⍺⍣⍵⍵⊢⍵
⍝ prof  ⎕profile wherein
⍝       cols[0,1] joined as fnname[lineno]
⍝       times converted to % so ⍺⍺ takes 100 overall
⍝       last two cols missing
 }
