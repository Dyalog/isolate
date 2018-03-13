 callerSpace←{⍺←⊢
     ⍬⍴((0,⎕RSI)~0,⎕THIS,##,⍵),#
⍝ caller excluding this space and the main isolate method-space above it.
⍝ none of the code above is redundant. 2014-01-09
 }
