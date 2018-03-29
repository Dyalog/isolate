 r←setup_runtime dummy
 ⍝ Setup for runtime tests

 :If 0=⎕NC 'Fail' ⍝ Running v16.0 or earlier
     ⎕FX 'msg Fail value' 'msg ⎕SIGNAL (1∊value)/777'
 :EndIf

 runtime←1
 r←''
