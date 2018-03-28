 r←Reset kill;iso;clt;ok;local;count;z;close
 r←''
 close←{0::'' ⋄ DRC.Close ⍵} ⍝ try to close, ignore all errors

 :If 2=⎕NC'session.assoc.iso'
     r,←(⍕≢session.assoc.iso),' isolates, '
     :For iso :In session.assoc.iso ⍝ For each known isolate
         {}close'Iso',⍕iso
     :EndFor
 :EndIf

 :If 2=⎕NC'session.procs'
     r,←(⍕≢session.procs),' processes, '
     :For clt :In session.procs[;4] ⍝ For each process
         {}close clt
     :EndFor

     count←0
     :If 0≠≢local←session.((procs[;1]≠0)/procs[;1]) ⍝ local processes

         :While ~ok←∧/local.HasExited
             ⎕DL session.retry_interval×count←count+1
         :Until count>session.retry_limit

         :If ~ok
             :If 'server'≡options.status
                 r←r,' (service processes killed), ' ⋄ z←local.Kill
             :Else
                 r←r,' (service processes have not died), '
             :EndIf
         :EndIf
     :EndIf

 :EndIf

 :If 2=⎕NC'session.listeningtid'
     ⎕TKILL session.listeningtid
     r,←'callback listener, '
 :EndIf

 :If 0≠≢r ⋄ r←'Reset: ',¯2↓r
 :Else ⋄ r←'Nothing found to reset'
 :EndIf
 ⎕EX'session'
