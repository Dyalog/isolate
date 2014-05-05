 Build;file;ver;src;t;version;rev;path
⍝ Build distribution workspace containing unsalted classes
⍝    Insert SVN revision number

 (⎕IO ⎕ML)←1 1
 ⎕EX ⎕NL 9
 version←'1.0'
 path←(1-⌊/(⌽⎕WSID)⍳'\/')↓⎕WSID

 :If '14.0'≢4↑2⊃'.'⎕WG'APLVersion'
     ⎕←'*** WARNING - Production builds should be run using Dyalog 14.0 ***'
 :EndIf

 'isolate'⎕NS''
 BuildCovers
 ⎕←⎕SE.SALT.Load'⍵\Sources\isolate.ynys.dyalog -target=isolate -nolink'

 :If 0=⍴rev←⎕CMD'subwcrev ',path
     ⎕←'NB: Unable to get SVN revision information!'
 :ElseIf 1≠⍴ver←('Updated to revision (\w+)'⎕S'\1')rev
 :OrIf 1∊'Local modifications found'⍷∊rev
     ⎕←'NB: SVN state is possibly not up-to-date - version information NOT added!'
     ⎕←⍪rev
 :Else
     ver←version,'.',⊃ver ⍝ Join base version and SVN revision
     ⎕←2↓t←'⍝ isolate.ynys version ',ver,' built at ',,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 1 6⍴⎕TS
     t←t(':Field Public Shared Version←''',ver,'''')
     src←{(1↑⍵),t,1↓⍵}⎕SRC isolate.ynys
     ⎕FIX src
 :EndIf

 ⎕LX←'#.isolate.ynys.isoStart ⍬'
 ⎕←'      )WSID ',⎕WSID←path,'Distribution\isolate.dws'
 ⎕←'⍝ Now:'
 ⎕←'      ⎕EX ⎕NL 2 3'
 ⎕←'      )SAVE'