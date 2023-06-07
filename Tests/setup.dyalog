 r←setup dummy;dws;a;nl;tmp;code;isoDir;usf;renamed_setup
⍝ Setup for isolate tests - reset any settings to defaults
 :If 0=#.⎕NC'isolate'
     'isolate'#.⎕NS''
     ⎕SE.SALT.Load ##.TESTSOURCE,'../Source/isolate/APLProcess -target=#.isolate'
 :EndIf
 isoDir←1⊃1 ⎕NPARTS ¯1↓1⊃⎕NPARTS ##.TESTSOURCE
 :If ~⎕NEXISTS dws←isoDir,'isolate.dws'
     ('Type' 'I')Log'Could not find ',dws,' -> building it now'
     nl←⎕UCS 10
     :Repeat
          ⍝ tmp←(739⌶0),'/',(⎕A,⎕D)[?10⍴36],'/StartupSession/'
         tmp←(739⌶0),'/DBuild_isolate_',(⎕A,⎕D)[?10⍴36],'/'
     :Until ~⎕NEXISTS tmp
     3 ⎕MKDIR tmp

     code←1⊃⎕NGET ##.TESTSOURCE,'build_dws.aplf'
     code←'Setup',nl,{(⍵⍳⎕UCS 10)↓⍵}code     ⍝  replace original function header so that our function is niladic "Setup" (don't care about locals as we quit afterwards anyway)
     (⊂code)⎕NPUT tmp,'setup.dyalog'

     ⍝ the following hack is only needed when running locally on a developer's machine which may have a setup fn.
     ⍝ we need to rename the default setup command so that ours is the only one executed
     :If renamed_setup←⎕NEXISTS usf←⎕SE.SALTUtils.USERDIR,'MyUCMDS/setup.dyalog'    
         ⎕nuntie (usf,'.tmp')⎕NRENAME usf ⎕ntie 0
     :EndIf

     ⍝ the parameter BUILDINFO is checked in Build/Build.dyalog and avoids cancellation of build (because we can't query git details in test env)
     a←⎕NEW #.isolate.APLProcess(''('BUILDINFO=DTEST BUILDFILE="',isoDir,'isolate.dyalogbuild" SALT_SourceFolder=',tmp,' LOG_FILE="',##.TESTSOURCE,'build_dws.dlf"'))
     :Repeat
         ⎕DL 1
     :Until a.HasExited  ⍝ wait until job has finished

     ⍝ restore original setup command
     :If renamed_setup
         ⎕nuntie usf ⎕NRENAME (usf,'.tmp') ⎕ntie 0
     :EndIf

     :If ~⎕NEXISTS dws   ⍝ and quit if ws still not found
         r←'Running "',##.TESTSOURCE,'build_dws.aplf" did not build "',dws,'". Check file ',##.TESTSOURCE,'build_dws.log'
         →0
     :EndIf
     3 ⎕NDELETE tmp      ⍝ remove that tmp folder
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
