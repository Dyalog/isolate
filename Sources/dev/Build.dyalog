 Build;file;ver;src;t;version;rev;path
⍝ Build distribution workspace containing unsalted classes and namespaces
⍝    Insert SVN revision number

 (⎕IO ⎕ML)←1 1
 ⎕EX ⎕NL 9
 version←'1.0'
 path←(1-⌊/(⌽⎕WSID)⍳'\/')↓⎕WSID

 :If '14.0'≢4↑2⊃'.'⎕WG'APLVersion'
     ⎕←'*** WARNING - Production builds should be run using Dyalog 14.0 ***'
 :EndIf

 'isolate'⎕NS'' ⋄ isolate.(⎕IO ⎕ML)←0 1
 BuildCovers

 ⎕←⎕SE.SALT.Load'⍵\Sources\isolate.ynys.dyalog -target=isolate -source=no -nolink'
 ⎕←⎕SE.SALT.Load'⍵\Sources\RPCServer -target=isolate -source=no -nolink'
 ⎕←⎕SE.SALT.Load'⍵\Sources\APLProcess -target=isolate -nolink'

 :If 0=⍴rev←⎕CMD'subwcrev ',path
     ⎕←'NB: Unable to get SVN revision information!'
 :ElseIf 1≠⍴ver←('Updated to revision (\w+)'⎕S'\1')rev
 :OrIf 1∊'Local modifications found'⍷∊rev
     ⎕←'NB: SVN state is possibly not up-to-date - version information NOT added!'
     ⎕←⍪rev
 :EndIf

 ver←version,'.',⍕1+2⊃⎕VFI⍕ver ⍝ Join base version and 1+SVN revision
 ⎕←'isolate.Version set to:'
 ⎕←isolate.Version←'Version ',ver,' built at ',,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 1 6⍴⎕TS

 ⎕LX←'#.isolate.ynys.isoStart ⍬'
 ⎕←'      )WSID ',⎕WSID←path,'Distribution\isolate.dws'
 ⎕←'⍝ Now:'
 ⎕←'      )erase Build BuildCovers Clear Load'
 ⎕←'      )SAVE'