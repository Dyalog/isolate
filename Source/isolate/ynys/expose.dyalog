 expose←{⍺←⊢
     (src snm)←⍵
     (tgt tnm)←⍺⊣#             ⍝ dflt target  - #
     tnm←snm∘⊣⍣(tgt≡tnm)⊢tnm   ⍝ dflt tnames  - snames
     ss←⍕src
     trap←'⋄0::(⊃⍬⍴⎕DMX.EN) ⎕SIGNAL ⎕DMX.⎕EN⋄'
     fix←{op←4=src.⎕NC ⍵
         (aa ww)←2↑(0 2⊃src.⎕AT ⍵)⍴'⍺⍺' '⍵⍵'
⍝         tgt.⎕FX(⍺,'←{⍺←⊢')trap('⍵≡⍺⍵:',aa,ss,'.',⍵,ww,'⊢⍵')('⍺(',aa,ss,'.',⍵,ww,')⍵')'}'
         tgt.⎕FX,⊂⍺,'←{⍺←⊢',trap,(op/'⍵≡⍺⍵:',aa,ss,'.',⍵,ww,'⊢⍵⋄'),'⍺(',aa,ss,'.',⍵,ww,')⍵}'
     }
     z←tnm fix¨snm
     1:1
⍝ expose public functions and operators elsewhere
⍝ ⍵         (src) (snms)
⍝ ⍺         [tgt  [tnms] ]
⍝ src       ref containing fns to run
⍝ snms      names of fns & ops therein
⍝ tgt       ref to contain fns to call - dflt #
⍝ tnms      corresponding names in tgt - dflt snms
⍝ tgt.tnm←{⍺←⊢⋄0::(⊃⍬⍴⎕DM)⎕SIGNAL⎕EN⋄                      ⍺(  #.src.snm  )⍵} ⍝ function
⍝ tgt.tnm←{⍺←⊢⋄0::(⊃⍬⍴⎕DM)⎕SIGNAL⎕EN⋄ ⍵≡⍺⍵:⍺⍺#.src.snm  ⊢⍵⋄⍺(⍺⍺#.src.snm  )⍵} ⍝ adverb
⍝ tgt.tnm←{⍺←⊢⋄0::(⊃⍬⍴⎕DM)⎕SIGNAL⎕EN⋄ ⍵≡⍺⍵:⍺⍺#.src.snm⍵⍵⊢⍵⋄⍺(⍺⍺#.src.snm⍵⍵)⍵} ⍝ conjunction
 }
