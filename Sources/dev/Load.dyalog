 Load;path
 'isolate'⎕NS''
 BuildCovers
 ⎕←⎕SE.SALT.Load'⍵\Sources\isolate.ynys.dyalog -target=isolate'
 ⎕←⎕SE.SALT.Load'⍵\Sources\TestIso.dyalog'
 path←(1-⌊/(⌽⎕WSID)⍳'\/')↓⎕WSID
 ⎕LX←'#.isolate.ynys.isoStart ⍬'
 ⎕←'      )WSID ',⎕WSID←path,'isolate.dws'