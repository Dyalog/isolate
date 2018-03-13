 r←RemoveServer server;mask;iso;isos;clt;mask2;local;ok;count
 :If 2=⎕NC'session.procs'
     :If 0=⍴server ⋄ server←whoami'' ⋄ :EndIf
     :If ∨/mask←server∘≡¨session.procs[;2]
         :If 2=⎕NC'session.assoc.proc'
             :If 0≠≢isos←(mask2←session.assoc.proc∊mask/session.procs[;0])/session.assoc.iso
                 :For iso :In isos
                     {}DRC.Close'Iso',⍕iso
                 :EndFor
                 session.assoc.(busy iso proc)/⍨←⊂~mask2
             :EndIf
         :EndIf

         :For clt :In mask/session.procs[;4]
             {}DRC.Close clt
         :EndFor

         :If 0≠≢local←{(⍵≠0)/⍵}mask/session.procs[;1]
             :If 'server'≡options.status
                 local.Kill
             :Else
                 count←0
                 :While ~ok←∧/local.HasExited
                     ⎕DL session.retry_interval×count←count+1
                 :Until count>session.retry_limit
             :EndIf
         :EndIf
         session.procs⌿⍨←~mask
         r←State''
     :Else
         r←'[server "',server,'" not found]'
     :EndIf
 :Else
     r←'[no servers defined]'
 :EndIf
