 {r}←{allowremote}Init local;here;z;ss;op;maxws;ws;rt;iso;ports;pids;pclts;t
 r←⎕THIS.⎕IO←0
 :If 0=⎕NC'allowremote' ⋄ allowremote←⍬ ⋄ :EndIf
 :If newSession''
     here.iSpace←here←⎕THIS
     z←here.(proxyClone←⎕NS'').⎕FX¨proxySpace.(⎕CR¨↓⎕NL 3)
     z←here.proxyClone.⎕FX iSpace.⎕CR'tracelog'
     ss←here.session←⎕NS''
     here.(signal←⎕SIGNAL/∘{(⊃⍬⍴⎕DM)⎕EN})
     z←setDefaults''
     op←options
     z←getSet'debug'op.debug    ⍝ on or off
     :Trap trapErr''
         ##.DRC←here.DRC←getDRC op.drc
         :If ~(⊃z←DRC.Init ⍬)∊0
             ('CONGA INIT FAILED: ',,⍕z)⎕SIGNAL 11
         :EndIf
         z←DRC.SetProp'.' 'Protocol'(op.protocol)
         ss.retry_limit←99      ⍝ How many retries
         ss.retry_interval←0.05 ⍝ Length of first wait (increases with interval each wait)
         ss.orig←whoami''
         ss.homeport←op.homeport
         ss.listen←localServer options.listen   ⍝ ⌽⊖'ISOL'
         ss.nextid←2⊃⎕AI                   ⍝ isolate id
         ss.callback←1+(2*15)|+/⎕AI        ⍝ queue for calls back
         ss.remoteclients←allowremote
         z←⎕TPUT ss.assockey←1+ss.callback ⍝ queue for assoc and procs
         ss.assoc←dix'proc iso busy'(3⍴⍬ ⍬)
         ss.procs←0 5⍴0 ⍬'' 0 ''

         :If 1≡local ⍝ if we're to start local processes
             ss.procs⍪←ss InitProcesses op
         :EndIf

         ss.started←sessionStart''               ⍝ last thing so we know

         :If ss.listen ⍝ set up list of acceptable client addresses
             t←↑{0=⊃p←DRC.GetProp ⍵'peeraddr':2↑1↓1⊃p ⋄ ⍬ ⍬}¨session.procs[;4]
             t[;0]←{⌽(1+⍵⍳':')↓⍵}∘⌽¨t[;0]
             ##.RPCServer.localaddrs←(⊂''),⊣⌸t
         :EndIf
         r←1
     :Else
         signal''
     :EndTrap
 :EndIf
