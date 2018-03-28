 derv←{⍺←⊢
     ⍕{
         ⊃,/{
             0=≡⍵:⍵
             0∊⍴⍵:((''⍬ ⍵)⍳⊂⍵)⊃'''''' '⍬'⍵
⍝             1=≡⍵:'(',,∘')'⊃,/(⊂(' ',,⍵)⍳,⍵)⌷(⊂''' '' '),,⍵
             1=≡⍵:'(',,∘')'⊃,/,⍵
             ⊃,/'(',,∘')'∇¨⍵
         }⍵
     }⎕CR(f←⍺⍺)/'f'
⍝ ⍺⍺    derv
⍝ ←     executable text-string representation of ⍺⍺
⍝ sometimes adds too many parens but would need MUCH more analysis not to
⍝ handles scalar nums, ' ', '' & ⍬ but not arrays in general
⍝ e.g.
⍝       sec ← (⊢⊣)/∘⍳∘(15E5∘×)
⍝       sec derv 0
⍝ ((((⊢⊣)/)∘⍳)∘( 1500000 ∘×))
 }
