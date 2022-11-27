 isolates←{⍺←⊢
     ss←session
     source←⍵                    ⍝ ns or wsid
     receive←'#.isolate.ynys.receive'
     numid←ss.nextid←ss.nextid+2
     tgt←'#.',chrid←'Iso',⍕numid

⍝ ss.procs contains all proc ids; assoc.(busy/proc) only those with busy isos
     max←options.isolates
     ass←ss.assoc
     z←⎕TGET ss.assockey         ⍝ see Init
     procs←⊣/ss.procs
     load←¯1+{≢⍵}⌸procs,ass.proc         ⍝ isolate load
     busy←¯1+{≢⍵}⌸procs,ass.(busy/proc)  ⍝ busy isolates
     ok←options.isolates>load
     ~∨/ok:'ISOLATE ERROR: All processes are in use'⎕SIGNAL 11⊣⎕TPUT ss.assockey
     use←(load=⌊/load)/⍳⍴load ⍝ procs with same load
     proc←procs⊃⍨use←use[⊃⍋busy[use]]     ⍝ pick one with fewest busy isolates
     ass.(iso busy proc),←numid 0,proc
     z←⎕TPUT ss.assockey
     (host port)←ss.procs[procs⍳proc;2 3]
     data←host ss.orig chrid numid tgt ss.homeport port
     id←dix'host orig chrid numid tgt home port'data
     z←connect chrid host port,⊂receive(source options.listen id)
     id
⍝ Create DRC client for isolate.
⍝ Create id space to send and return for corresponding proxy.
 }
