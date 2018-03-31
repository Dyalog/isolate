 r←setup dummy
⍝ Setup for isolate tests - reset any settings to defaults

 :If 0=⎕NC 'Fail' ⍝ Running v16.0 or earlier
     ⎕FX 'msg Fail value' 'msg ⎕SIGNAL (1∊value)/777'
 :EndIf

 {}#.isolate.Config 'runtime' 1
 {}#.isolate.Config 'onerror' 'signal'
 {}#.isolate.Config 'processors' 4

 r←''
