 r←setup dummy;dws;a;nl;tmp;code;isoDir;usf;renamed_setup
⍝ Setup for isolate tests - reset any settings to defaults
 :If 0=#.⎕NC'isolate'
     'isolate'#.⎕NS''
     ⎕SE.SALT.Load'[DYALOG]Library/Core/APLProcess -target=#.isolate'
 :EndIf
 isoDir←1⊃1 ⎕NPARTS ¯1↓1⊃⎕NPARTS ##.TESTSOURCE
 :If ~⎕NEXISTS dws←isoDir,'isolate.dws'
     ('Type' 'I')Log'Could not find ',dws,' -> building it now'

   ⍝ the parameter NODATENEEDED is checked in Build/Build.dyalog and avoids cancellation of build (because we can't query git details in test env) (we don't check for a specific value, any value will do)
     a←⎕NEW #.isolate.APLProcess((isoDir,'/Tests/build_dws')('NODATENEEDED=yup BUILDFILE="',isoDir,'isolate.dyalogbuild" LOG_FILE="',##.TESTSOURCE,'build_dws.dlf"'))
     :Repeat
         ⎕DL 1
     :Until a.HasExited  ⍝ wait until job has finished

     :If ~⎕NEXISTS dws   ⍝ and quit if ws still not found
         r←'Running "',##.TESTSOURCE,'build_dws.aplf" did not build "',dws,'". Check file ',##.TESTSOURCE,'build_dws.log'
         →0
     :EndIf
 :EndIf

 #.⎕CY dws

 :If 0=⎕NC'Fail' ⍝ Running v16.0 or earlier
     ⎕FX'msg Fail value' 'msg ⎕SIGNAL (1∊value)/777'
 :EndIf

 :If isDTest162←1.62≤{2⊃⎕VFI(2>+\⍵='.')/⍵}2⊃(1⊃⎕RSI).Version   ⍝ v1.62 added the ability to distinguish Info/Warning/Errors with Log
     WARN←{('Type' 'W')Log ⍵}
 :Else
     WARN←{Log'*** Warning: ',⍵}
 :EndIf
 {}#.isolate.Config'runtime' 1
 {}#.isolate.Config'onerror' 'signal'
 {}#.isolate.Config'processors' 4
 {}#.isolate.Config'workspace'dws

 r←''
