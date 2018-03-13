 r←{default}Values name
 :If 0=⎕NC'default' ⋄ default←⊢ ⋄ :EndIf
 r←⊃default(1⊃⎕RSI).(702⌶)name
