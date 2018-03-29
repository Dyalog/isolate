 r←setup_devt dummy
⍝ Setup for tests using development interpreter

 :If 0=⎕NC 'Fail' ⍝ Running v16.0 or earlier
     ⎕FX 'msg Fail value' 'msg ⎕SIGNAL (1∊value)/777'
 :EndIf

 runtime←0
 r←''
