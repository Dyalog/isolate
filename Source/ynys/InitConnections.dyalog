 r←pids InitConnections(addr ports id remote);i
     ⍝ Establish connections to all new processes
 r←(≢pids)⍴⊂''
 :For i :In ⍳≢pids
     :Trap 0
         (i⊃r)←(i⊃pids)InitConnection addr(i⊃ports)id remote
     :EndTrap
 :EndFor
