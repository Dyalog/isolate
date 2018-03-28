 New←{⍺←⊢
     z←Init 1
     trapErr''::signal''
     caller←callerSpace''
     source←caller argType ⍵
     id←⍬ isolates source
     proxy←caller.⎕NS proxyClone
     proxy.(iSpace iD iCarus)←iSpace id,suicide.New'cleanup'id
     z←proxy.⎕DF(⍕caller),'.[isolate]'
     z←1(700⌶)proxy
     1:proxy
⍝ simulate isolate primitive: UCS 164 / sol
 }
