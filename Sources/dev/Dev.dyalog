 Dev;z
 z←¯1↓⊃⎕NPARTS ⎕WSID
 ⎕←'      )clear'
 ⍝⎕←'      {⎕FIX ''file://'',⍵}¨⊃(⎕NINFO⍠1)''',z,'/Sources/Dev/*'''
 ⎕←'      ]load "',z,'/Sources/Dev/*"'
 ⎕←'      )wsid "',z,'/dev.dws"'
 ⎕←'      ⎕LX←''Load'''
 ⎕←'      )save'
