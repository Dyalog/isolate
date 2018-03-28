 TestAWS n;iss;procs;z;data;start;cmd;iAWS

 start←⎕AI[3]
 :If '16'≢2↑2⊃'.'⎕WG'APLVersion'
     'Use v16.0 for this test'⎕SIGNAL 11
 :EndIf

 iAWS←⎕NEW AWS
 'Current IP is: ',iAWS.SetMyIp

 iAWS.user←'ubuntu'             ⍝ User name to log in to
 iAWS.keyfolder←'C:\Users\mkrom\Documents\SSH\' ⍝ Where the key files are
 iAWS.keypair←'AWS-JSONServer'  ⍝ Name of an AWS key pair
 iAWS.region←'eu-west-1'        ⍝ Ireland
 iAWS.image←'ami-4e612f37'      ⍝ Ubuntu 16.04 with Dyalog APL and updated isolate workspace
 iAWS.type←'t1.micro'           ⍝ instance-type
 iAWS.security←'Isolate ssh RIDE' ⍝ Ports to open


 ⎕←iAWS.(↑{⍵(⍎⍵)}¨⎕NL-2)            ⍝ Display all public fields

 1 iAWS.RunInstances n

 ⎕←'Starting Isolate Servers...'
 ⎕←cmd←'isolate=isolate Port=7052 AutoShut=1 AllowRemote="IP=',iAWS.myIP,'" dyalog /home/ubuntu/isolate'

 procs←iAWS.Launch n cmd

 ⎕←'Connecting to Isolate Servers:'
 {}iAWS.AddServers procs

 ⎕←'Create isolates and execute uname -a in each:'
 iss←ø¨n⍴⊂''
 ⍪iss.⎕SH⊂'uname -a'

 z←⎕AI[3]
 ⎕←'Using isolates to averate each row of a ',(⍕n),' by 10,000 matrix'
 data←?n 10000⍴0 ⍝ create "big data"
 ⎕←'Transferring data...'
 iss.data←↓data
 ⎕←'Computing averages in parallel'
 ⎕←3⍕iss.((+⌿÷≢)data)
 ⎕←'Total runtime: ',(⍕⎕AI[3]-z),' milliseconds including data transfer'

 ⎕EX'iss'

 ⎕←'Shutting down'
 z←isolate.RemoveServer¨procs.Address ⋄ {}⎕TSYNC procs.TID

 ⎕←procs[1].Output

EXIT:
 1 iAWS.Terminate''

 ⎕←'Test complete, total elapsed time = ',(1⍕0.001×⎕AI[3]-start),' seconds'
