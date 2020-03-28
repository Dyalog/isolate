 r←setup dummy
⍝ Setup for isolate tests - reset any settings to defaults
 :If 0=#.⎕NC'isolate'
     :If 2=(1⊃⎕RSI).⎕NC'quiet'  ⍝ we usually run this through ]DTest
     :AndIf 0=(1⊃⎕RSI).quiet       ⍝ check if quiet-flag is set
         Log'Did not find #.isolate, now attempting to build (and save) the workspace'
     :EndIf
     ⎕SE.UCMD'DBuild ',(∊1 ⎕NPARTS(1⊃⎕NPARTS ##.TESTSOURCE),'../isolate.dyalogbuild'),' -save=1',(1⊃⎕RSI).quiet/' -quiet'   ⍝ if isolate not present, build it and save it (we need it when launching isolates...)
 :EndIf

 :If 0=⎕NC'Fail' ⍝ Running v16.0 or earlier
     ⎕FX'msg Fail value' 'msg ⎕SIGNAL (1∊value)/777'
 :EndIf

 {}#.isolate.Config'runtime' 1
 {}#.isolate.Config'onerror' 'signal'
 {}#.isolate.Config'processors' 4

 r←''
