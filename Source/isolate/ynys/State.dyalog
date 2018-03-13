 r←State dummy;counts
     ⍝ Return current process & isolate state

 :If 9=⎕NC'session'
     :If 0≠≢session.procs
         counts←session.assoc.(proc{⍺,(+/⍵),+/~⍵}⌸busy)
         r←session.procs[;2 3]
         r,←{⍵,+/⍵}(counts⍪0)[counts[;0]⍳session.procs[;0];1 2]
         r[(0,2≡/r[;0])/⍳1↑⍴r;0]←⊂''
         r←({⍵,[¯0.5](≢¨⍵)⍴¨'-'}'Host' 'Port' 'Busy' 'Idle' 'Isolates')⍪r
         r←r[;0 1 4 2]
     :Else
         r←'[no servers defined]'
     :EndIf
 :Else
     r←'[not initialised]'
 :EndIf
