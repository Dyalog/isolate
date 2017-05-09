 Build;file;ver;src;t;version;rev;path;root
⍝ Build v15.0 distribution workspace containing unsalted classes and namespaces
⍝ Updates to include ll namespace
⍝    Insert SVN revision number

 (⎕IO ⎕ML)←1 1
 ⎕EX ⎕NL 9
 version←'1.0'
 path←'file://',(root←⊃⎕NPARTS ⎕WSID),'Sources/'

 :If '15.0'≢4↑2⊃'.'⎕WG'APLVersion'
     ⎕←'*** WARNING - Production builds should be run using Dyalog 15.0 ***'
 :EndIf

 'isolate'⎕NS'' ⋄ isolate.(⎕IO ⎕ML)←0 1
 BuildCovers

 ⎕←isolate.⎕FIX path,'isolate.ynys.dyalog'
 ⎕←isolate.⎕FIX path,'RPCServer.dyalog'
 ⎕←isolate.⎕FIX path,'APLProcess.dyalog'
 ⎕←⎕FIX path,'ll.dyalog'

 :If 0=⍴rev←{0::'' ⋄ ⎕CMD ⎕←'subwcrev ''',⍵,''''}root
     ⎕←'NB: Unable to get SVN revision information!'
     ver←0
 :ElseIf 1≠⍴ver←('Updated to revision (\w+)'⎕S'\1')rev
 :OrIf 1∊'Local modifications found'⍷∊rev
     ⎕←'NB: SVN state is possibly not up-to-date - version information NOT added!'
     ⎕←⍪rev
 :EndIf

 ver←version,'.',⍕1+2⊃⎕VFI⍕ver ⍝ Join base version and 1+SVN revision
 ⎕←'isolate.Version set to:'
 ⎕←isolate.Version←'Version ',ver,' built at ',,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 1 6⍴⎕TS

 ⎕LX←'#.isolate.ynys.isoStart ⍬'
 ⎕←'      )WSID ',⎕WSID←root,'Distribution/isolate.dws'
 ⎕←'⍝ Now:'
 ⎕←'      )erase Build BuildCovers Clear Dev Load'
 ⎕←'      )SAVE'
