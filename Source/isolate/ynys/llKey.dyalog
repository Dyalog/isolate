 llKey←{⍺←⊢                                    ⍝ key operator
     z←Init 1
     trapErr''::signal''
     ⍵≡⍺ ⍵:⍵ ∇(callerSpace'').⍳≢⍵

     j←⍋i←{(∪⍳⊢)↓⍣(≢1↓⍴⍵)⊢⍵}⍺
     (⊂⍤¯1⊢((⍳⍴i)=i⍳i)⌿⍺)⍺⍺ llEach(2≠/¯1,i[j])⊂[0](⊂j)⌷⍵

⍝ parallel key : ⍺ ⍺⍺ llkey ⍵
⍝ ⍺     [larg] - array (≢⍺) ≡ ≢⍵
⍝       ⍺⍺ llKey ⍵ ←→ ⍵ ⍺⍺ llKey ⍳≢⍵
⍝ ⍺⍺    fn to apply between each unique major cell of ⍺ and
⍝       the corresponding subarray of ⍵ ; or to the latter.
⍝ ⍵     rarg - array
⍝ ←     futures array - results of each application of ⍺⍺
⍝ to emulate primitive key completely it should mix (↑) the results.
⍝   This CANNOT BE DONE here as it would dereference the futures.
⍝ Phil Last ⍝ 2007-06-22 22:57
 }
