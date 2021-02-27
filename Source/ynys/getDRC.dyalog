 r←getDRC ref;ws
 :If ref≠# ⋄ r←ref                 ⍝ Not set, so we must create it
 :ElseIf 9=#.⎕NC'DRC' ⋄ r←#.DRC    ⍝ in # already?
 :Else
     ws←'conga.dws'
     :Trap 0
         'DRC'#.⎕CY ws              ⍝ See if the interpreter can find it
     :Else
         ws←addWSpath'conga.dws'     ⍝ Actually adds [DYALOG]/ws
         :Trap 0
             'DRC'#.⎕CY ws
         :Else
             'Unable to locate conga.dws'⎕SIGNAL 11
         :EndTrap
     :EndTrap
     r←#.DRC
 :EndIf
