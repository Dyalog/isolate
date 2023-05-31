 r←setup dummy;dws;a
⍝ Setup for isolate tests - reset any settings to defaults
 :If 0=#.⎕NC'isolate'
     'isolate'#.⎕NS''
     ⎕SE.SALT.Load ##.TESTSOURCE,'../Source/isolate/APLProcess -target=#.isolate'
 :EndIf

 :If ~⎕NEXISTS dws←∊(1⊃1 ⎕NPARTS ¯1↓1⊃⎕NPARTS ##.TESTSOURCE),'isolate.dws'
     ('Type' 'I')Log'Could not find ',dws,' -> building it now'

     a←⎕NEW #.isolate.APLProcess(''('RIDE_INIT=serve:*:4511 LOAD=',##.TESTSOURCE,'build_dws.aplf')0 ''(##.TESTSOURCE,'build_dws.log'))
     :Repeat  ⍝ wait until ws is built...
         ⎕DL 1
     :Until a.HasExited
     :If ~⎕NEXISTS dws
         r←'Running "',##.TESTSOURCE,'build_dws.aplf" did not build "',dws,'". Check file ',##.TESTSOURCE,'build_dws.log'
         →0
     :EndIf
     ⎕NDELETE ##.TESTSOURCE,'build_dws.log'
 :EndIf

 #.⎕CY dws

 :If 0=⎕NC'Fail' ⍝ Running v16.0 or earlier
     ⎕FX'msg Fail value' 'msg ⎕SIGNAL (1∊value)/777'
 :EndIf

 {}#.isolate.Config'runtime' 1
 {}#.isolate.Config'onerror' 'signal'
 {}#.isolate.Config'processors' 4
 {}#.isolate.Config'workspace'dws

 r←''
