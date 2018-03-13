 llOuter←{⍺←'VALENCE ERROR'⎕SIGNAL 6
     z←Init 1
     trapErr''::signal''
     (⍉(⌽s)⍴⍉⍺)⍺⍺ llEach ⍵⍴⍨s←(⍴⍺),⍴⍵

⍝     s←,⍴a←∪,⍺
⍝     s,←⍴w←∪,⍵
⍝     r←(⍉(⌽s)⍴⍉a)⍺⍺ llEach s⍴w
⍝     1:r[a⍳⍺;w⍳⍵]

⍝ parallel outer product
⍝ ⍺  array
⍝ ⍺⍺ fn to apply between items of ⍺ and ⍵
⍝ ⍵  array
⍝ ←  aray of futures from ⍺⍺ applied between
⍝    each pair of items selected from ⍺ and ⍵
 }
