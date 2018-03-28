 getDefaultWS←{
     win←'W'≡⊃3⊃#.⎕WG'APLVersion'
     ∨/('/\'[win],⍵)⍷⎕WSID:⎕WSID
     ⍵ ⍝ ⍵ is normally 'isolate'
⍝ use exact current ws if looks like an isolate development ws
 }
