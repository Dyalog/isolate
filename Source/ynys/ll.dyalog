 ll←{
     z←Init 1
     trapErr''::signal''
     s←⍺⍺ fnSpace'f'

     i←New s
     0=⎕NC'⍺':i.f ⍵
     ⍺ i.f ⍵

⍝ parallel
⍝ ⍺     [larg]
⍝ ⍺⍺    [fn to apply to or between [⍺] and or ⍵
⍝ ⍵     rarg
⍝ ←     result of running ⍺⍺ in a parallel process.
 }
