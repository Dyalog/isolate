 receive←{⍺←⊢
     (source listen id)←⍵                           ⍝ this all happens remotely
     name←id.chrid
     root←⎕NS''
     z←{root.⎕FX¨proxySpace.(⎕CR¨⎕NL ¯3),⊂⎕CR'tracelog'}⍣listen⊢1  ⍝ prepare for calls back
     root.iSpace←⎕THIS
     id.(port←home)
     id.(chrid←'Iso',⍕1+numid)
     id.tgt←,'#'
     root.iD←id
     iso←root.⎕NS(⍴⍴source)⊃source''                ⍝ clone of source
     z←iso.{6::0 ⋄ z←{}⎕CY ⍵}⍣(≡source)⊢source      ⍝ or copy if ws
     z←iso.{6::0 ⋄ z←{}(↑'⎕io' '⎕ml')⎕CY ⍵}⍣(≡source)⊢source
     z←name{#.⍎⍺,'←⍵'}iso                           ⍝ name it in root
     z←#.DRC.Clt⍣listen⊢id.(chrid orig port)        ⍝ orig=host if local
     1⊣1(700⌶)root                                  ⍝ Make isolate
 }
