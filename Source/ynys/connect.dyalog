 r←connect(chrid host port data);count
 :If 0=⊃r←DRCClt chrid host port  ⍝ DRCClt will retry
 :AndIf 0=⊃r←DRC.Send chrid data  ⍝ on any
 :AndIf 0=⊃r←DRC.Wait(1⊃r)20000   ⍝ error
 :AndIf 'Timeout'≢3⊃r             ⍝ eventmode timeout
 :Else
     {}DRC.Close chrid
     ('ISOLATE: Connection to ',host,':',(⍕port),' failed: ',,⍕r)qsignal 6
 :EndIf
⍝ connect and send Initial payload
⍝ ⍺     attempts
⍝ ⍵     client-id ip-port data
⍝ data  function and argument
⍝ ←     final return from DRC
