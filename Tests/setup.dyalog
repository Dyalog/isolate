 r←setup dummy;do
⍝ Setup for isolate tests - reset any settings to defaults
 :If 0=#.⎕NC'isolate'
     :If 2=(1⊃⎕RSI).⎕NC'quiet'  ⍝ we usually run this through ]DTest
     :AndIf 0=(1⊃⎕RSI).quiet       ⍝ check if quiet-flag is set
         Log'Did not find #.isolate, now attempting to build (and save) the workspace'
     :EndIf
     ⎕←r←'Ending this run to launch ]DBuild. Will automatically resume afterwards!'
     do←{key←{2 ⎕NQ'⎕SE' 'Keypress'⍵} ⋄ key¨⍵,⊂'ER'}
     do ']DBuild ',(∊1 ⎕NPARTS(1⊃⎕NPARTS ##.TESTSOURCE),'../isolate.dyalogbuild'),' -clear ',((1⊃⎕RSI).quiet/' -quiet')
    do ')save'
    do ']',⎕SE.cmd
    →0
 :EndIf

 :If 0=⎕NC'Fail' ⍝ Running v16.0 or earlier
     ⎕FX'msg Fail value' 'msg ⎕SIGNAL (1∊value)/777'
 :EndIf

 {}#.isolate.Config'runtime' 1
 {}#.isolate.Config'onerror' 'signal'
 {}#.isolate.Config'processors' 4

 r←''
