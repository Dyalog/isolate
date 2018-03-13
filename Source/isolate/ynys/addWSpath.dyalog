 addWSpath←{⍺←⊢
     ∨/'/\'∊ws←⍵:⊢ws       ⍝ assume extant path is good
     dir←##.RPCServer.GetEnv'DYALOG'
     sep←⊃'/\'∩dir
     dir,←sep~⊢/dir        ⍝ append sep if needs
     dir,'ws',sep,ws       ⍝ WS folder
⍝ add ...dyalog/ws/   to ws if no path spec'd
 }
