 r←FindWs ws;paths

 paths←1↓¨{(1+';'=⍵)⊆⍵}';',2 ⎕NQ'.' 'GetEnvironment' 'WSPATH'
 paths,←(2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'),'/ws'
 r←{(1⍳⍨⎕NEXISTS¨⍵)⊃⍵,⊂''}paths,¨⊂'/',ws
