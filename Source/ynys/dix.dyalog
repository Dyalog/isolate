 dix←{⍺←⊢
     r←(⍺⊣#).⎕NS''
     r⊣r.{⍎⍕'(',⍺,')←⍵'}/⍵
⍝ dictionary
⍝ [⍺]       container space for dictionary - dflt: #
⍝ ⍵         names values
⍝ names     ' '-del'd or nested list
⍝ values    conformable with names
⍝ e.g.      pt←(dix'⎕ml'3).⊂
 }
