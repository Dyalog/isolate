 getDRC←{⍺←⊢
     ⍵≠#:⍵                          ⍝ if not # it must exist
     9=#.⎕NC'DRC':#.DRC             ⍝ in # already?
     ws←addWSpath'conga'            ⍝ dyalog WS
     0::⊢#.DRC                      ⍝ this is result
     z←{}'DRC'#.⎕CY ws              ⍝ ⎕CY no result
⍝
 }
