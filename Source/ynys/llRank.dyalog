 llRank←{⍺←⊢
     z←Init 1
     trapErr''::signal''
     mlr←⌽3⍴⌽⍵⍵,⍬
     m←⍵≡⍺ ⍵
     l r←-1↓r⌊|l+r×0>l←(⊂⍒m×⍳3)⌷mlr⌊r←3⍴(⍴⍴⍵),⍴⍴⍺⊣0
     w←⊂[r↑⍳⍴⍴⍵]⍵
     m:⍺⍺ llEach w              ⍝ monad
     (⊂[l↑⍳⍴⍴⍺]⍺)⍺⍺ llEach w    ⍝ dyad
⍝ parallel rank
⍝ ⍺     [larg]
⍝ ⍺⍺    fn to apply to or between corresponding cells of [⍺] and/or ⍵
⍝ ⍵⍵    ranks (monadic, left, right) of cells of [⍺] and/or ⍵
⍝           to or between which to apply ⍺⍺
⍝ ⍵     rarg
⍝ ←     results or futures from running ⍺⍺ in each of one
⍝           or more ephemeral isolates
⍝ to emulate primitive rank completely it should mix (↑) the results.
⍝   This CANNOT BE DONE here as it dereferences the futures.
⍝ Phil Last ⍝ 2007-06-22 22:57
 }
