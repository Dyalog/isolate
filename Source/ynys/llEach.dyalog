llEach←{⍺←⊢
     z←Init 1
     trapErr''::signal''
     n←⍺⍺ fnSpace'f'
     s←⍴⍺⊢¨⍵
     i←New¨(×/s)⍴n
     s⍴⍺ i.f,⍵

⍝ parallel each
⍝ ⍺     [larg]
⍝ ⍺⍺    fn to apply to or between corresponding items of [⍺] and/or ⍵
⍝ ⍵     rarg
⍝ ←     results (which may be futures) of running ⍺⍺ in each
⍝       of one or more ephemeral isolates
 }
