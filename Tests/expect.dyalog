 msgs expect expr;z;got;dmx
 ⍝ Check that the expected error was receive

 :Trap 0 ⍝ FUTURE ERROR
     z←+⍎expr ⍝ force future to materialize
     ('Did not fail as expected: ',expr)Fail 1

 :Else ⍝ We are expecting a VALUE ERROR
     got←⎕DMX.Message
     ⍝ got,←(0=≢got)/⎕DMX.EM
     :If ((∊⍕¨msgs)~': '){⍺≢(⍴⍺)↑⍵}got~': '
         'expected' 'got'⍪⍉⍪msgs got
         ⎕TRAP←0 'S'
         ∘
         ⎕SIGNAL something
     :EndIf
 :EndTrap
