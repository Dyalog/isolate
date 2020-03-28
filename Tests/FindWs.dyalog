 r←FindWs ws;paths;sep
 sep←(1+'W'=⊃⊃'.'⎕WG'APLVersion')⊃':;'
 paths←1↓¨{(1+sep=⍵)⊆⍵}sep,2 ⎕NQ'.' 'GetEnvironment' 'WSPATH'
 paths,←(2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'),'/ws'
 r←{(1⍳⍨⎕NEXISTS¨⍵)⊃⍵,⊂''}paths,¨⊂'/',ws
