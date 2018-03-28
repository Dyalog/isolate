 r←Stats dummy;n;stats;proc;z
 :If 9=⎕NC'session'
     :If 0≠n←≢session.procs
         stats←⍬
         :For proc :In session.procs[;4]
             :If 0=⊃z←DRC.Send proc('ß' '')
             :AndIf 0=⊃z←DRC.Wait 1⊃z
             :AndIf 0=⊃z←3⊃z
                 stats,←z[1]
             :Else
                 stats,←⊂⍬
             :EndIf
         :EndFor
         r←session.procs[;2 3]
         r[(0,2≡/r[;0])/⍳1↑⍴r;0]←⊂''
         r,←↑stats
         r[;2]←↓'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 0 ¯1↓↑r[;2]
         r←({⍵,[¯0.5](≢¨⍵)⍴¨'-'}'Host' 'Port' 'Start' 'Cmds' 'Errs' 'CPU')⍪r
     :Else
         r←'[no servers defined]'
     :EndIf
 :Else
     r←'[not initialised]'
 :EndIf
