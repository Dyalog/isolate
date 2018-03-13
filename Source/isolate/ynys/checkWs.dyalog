 checkWs←{⍺←⊢
                                   ⍝ ⍵ IS a string
     z←⎕NS''
     0::'WS NOT FOUND'⎕SIGNAL 11  ⍝ any error bar Value
     6::⍵                          ⍝ value error implies copy ok
     z←{}'⎕IO'z.⎕CY ⍵              ⍝ force value error → return ⍵
⍝
 }
