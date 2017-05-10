 Dev;root
 root←⌽{(⌊/⍵⍳'/\')↓⍵}⌽⎕WSID

 ⎕←'      )clear'
 ⎕←'      ]load "',root,'/Sources/Dev/*"'
 ⎕←'      )wsid "',root,'/dev.dws"'
 ⎕←'      ⎕LX←''Load'''
 ⎕←'      )save'
