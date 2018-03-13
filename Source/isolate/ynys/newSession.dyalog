 r←newSession w;z
 :If 0=⎕NC'session.started'
 :OrIf 0.0001<|session.started-sessionStart''
     r←1
 :Else ⋄ r←0 ⍝ not a new session
     session.listen←options.listen
     checkLocalServer ⍬
 :EndIf

⍝ The session is new if session.started is missing.
⍝ It needs to be restarted if session.started differs from the actual
⍝ start of the session by more than 8.64 seconds (1/10000 of a day)
⍝ that indicates that the ws was saved with the session space intact
