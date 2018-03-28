 StartServer←{⍺←⊢
     msg←messages'⍝- ' ⍝
     ~newSession'':(0⊃msg),' ',options.status
     z←Config'status' 'server'
     allowremote←validateRemoteFilters ⍵

     z←allowremote Init 1

     address←##.APLProcess.MyDNSName
     addresses←##.RPCServer.DNSLookup address
     addresses←addresses[⍋↑addresses[;2];0 1]
     addresses←addresses[;0]{⊂⍺ ⍵}⌸0 1↓addresses

     ports←∪session.procs[;3]
     info←(1 2⊃¨⊂msg),⍪address ports
     res←{4<≢⍵:msg[4 5 6 7],⍪address(⊃⍵)(≢⍵)''
         msg[4 5 7],⍪address((⊃⍵)+⍳≢⍵)''}ports
     res←∊⍕¨res
     ⎕←⍪,' ',⍪info(3⊃msg)res
     ⎕←⍪'' 'Full IP address list:' ''
     ⎕←addresses
     1:''

⍝- Session already started as
⍝- Machine Name:
⍝- IP Ports:
⍝- Enter the following in the client session:
⍝-       #.isolate.AddServer '
⍝- ' (
⍝- -⎕IO-⍳
⍝- )
 }
