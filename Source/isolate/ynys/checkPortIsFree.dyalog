 r←checkPortIsFree n;z
     ⍝ Check that TCP port is currently free
 :If r←0=⊃z←DRC.Srv'' ''n
     z←DRC.Close 1⊃z
 :EndIf
