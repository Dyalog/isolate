 res←where decode(a b c d e);home;x;DMX
 home←where=#  ⍝ would be #.IsoNNNNN for outward call
 x←where.⍎
 :Trap 999×{0::0 ⋄ ##.onerror≡⍵}'debug'
     :Select a
     :Case 0 ⋄ res←0(x b)
     :Case 1 ⋄ res←0((x b)c)
     :Case 2 ⋄ res←0(b(x c)d)
     :Case 3 ⍝ Assignment
         :If (0=⍴⍴c)∧1=≡c ⋄ where.⎕FX c ⋄ res←0 c ⍝ c is ⎕OR
         :Else ⋄ res←0(c⊢b{x ⍺,'←⍵'}c)
         :EndIf
     :Case 4 ⋄ res←0(⍎'c⌷[d]where.',b)
     :Case 5 ⋄ res←0(⍎'(c⌷[d]where.',b,')←e')
     :EndSelect
 :Else
     :If ⎕DMX.(EN ENX)≡11 4 ⍝ DOMAIN ERROR: isolate function iSyntax does not exist ...
         res←11((⊂'ISOLATE ERROR: Callbacks not enabled'),1↓⎕DM)
     :ElseIf ⎕DMX.((EN=6)∧∨/'##'⍷,⍕DM)
         res←6((⊂'VALUE ERROR IN CALLBACK'),1↓⎕DM)
     :Else
         res←⎕DMX.(EN DM)
     :EndIf
 :EndTrap
⍝ ⍺ target space
⍝ ⍵ encoded list
⍝   decode list and execute requisite syntax in target.
⍝   return (0 value) if OK, (⎕EN ⎕DM) on failure
⍝ Syntax cases:
⍝ a | b      | c       | d    | e
⍝ 0 | array  |         |      |
⍝ 0 | nilad  |         |      |
⍝ 0 | (expr) |         |      |
⍝ 1 | monad  | rarg    |      |
⍝ 2 | larg   | dyad    | rarg |
⍝ 3 | array  | value   |      |
⍝ 4 | array  | indices | axes |
⍝ 5 | array  | indices | axes | value
