 msgs expect expr;z;got
 ⍝ Check that the expected error was received
 :Trap 86 ⍝ FUTURE ERROR
     z←+⍎expr ⍝ force future to materialize
     ('Did not fail as expected: ',expr) Fail 1
 :Else ⍝ We are expecting a VALUE ERROR
     got←⎕DMX.Message
     :If ((∊⍕¨msgs)~': '){⍺≢(⍴⍺)↑⍵}got~': '
         'expected' 'got'⍪⍉⍪msgs got
         ⎕TRAP←0 'S'
         ∘
         ⎕SIGNAL something
     :EndIf
 :EndTrap
