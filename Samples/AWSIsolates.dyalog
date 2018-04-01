 AWSIsolates n;iss;procs;z;data;start;cmd;iAWS;wait;p;instances
 ⍝ Start n instances of an Ubuntu 16.04 server running Dyalog  16.0 and use them as isolate servers

 start←⎕AI[3]
 wait←1                           ⍝ constant: do not change this value

 :If 16<2⊃⎕VFI 4↑2⊃'.'⎕WG'APLVersion' ⍝ /// To avoid crashing with v17.0 arrays sent down sockets
     'v16.0 or earlier is required for this demo; AWS images are running v16.0'⎕SIGNAL 11
 :EndIf

 iAWS←⎕NEW AWS

⍝ ↓↓↓ Modify these settings to suit your own situation
 iAWS.user←'ubuntu'               ⍝ User name to log in to
 iAWS.keyfolder←'C:\Users\mkrom\Documents\SSH\' ⍝ Where the key files are
 iAWS.keypair←'AWS-JSONServer'    ⍝ Name of an AWS key pair
 iAWS.region←'eu-west-1'          ⍝ Ireland
 iAWS.image←'ami-ce366ab7'        ⍝ Ubuntu 16.04 with Dyalog APL 16.0 and updated isolate workspace
 iAWS.type←'t1.micro'             ⍝ instance-type
 iAWS.security←'Isolate ssh RIDE' ⍝ Ports to open
 ⎕←iAWS.(↑{⍵(⍎⍵)}¨⎕NL-2)          ⍝ Display all public fields

 ⎕←'Starting ',(⍕n),' instances of Amazon Machine Image ',iAWS.image,' in region ',iAWS.region
 ⎕←'   Current IP is: ',iAWS.SetMyIp

 ⎕←instances←wait iAWS.RunInstances n

 ⎕←'' ⋄ ⎕←'Starting Isolate Servers...'
 ⎕←'   ',cmd←'isolate=isolate Port=7052 AutoShut=1 AllowRemote="IP=',iAWS.myIP,'" dyalog /home/ubuntu/isolate'
 procs←iAWS.Launch n cmd

 ⎕←'' ⋄ ⎕←'Connecting to Isolate Servers:'
 :For p :In procs
     z←#.isolate.AddServer p.Address 7052
 :EndFor

 ⎕←'' ⋄ ⎕←'Create isolates and execute uname -a in each:'
 iss←isolate.New¨n⍴⊂''
 ⎕←⍪iss.⎕SH⊂'uname -a'

 z←⎕AI[3]
 ⎕←'' ⋄ ⎕←'Using isolates to averate each row of a ',(⍕n),' by 10,000 matrix'
 data←?n 10000⍴0 ⍝ create "big data"
 ⎕←'Transferring data...'
 iss.data←↓data
 ⎕←'Computing averages in parallel'
 ⎕←3⍕iss.((+⌿÷≢)data)
 ⎕←'Total runtime for parallel computation: ',(⍕⎕AI[3]-z),' ms including data transfer'

 ⎕EX'iss' ⍝ dispose of isolates

 ⎕←'' ⋄ ⎕←'Shutting down isolate servers'
 ⍝ Isolate servers were started with AutoShut=1; when we remove the master socket they will shut down
 z←#.isolate.RemoveServer¨procs.Address ⋄ {}⎕TSYNC procs.TID

 ⎕←procs[1].Output ⍝ SSH session output from one of the processes

EXIT:
 ⎕←'' ⋄ ⎕←'Terminating AWS instances'
 wait iAWS.Terminate instances[;1]

 ⎕←'' ⋄ ⎕←'Test complete, total elapsed time = ',(1⍕0.001×⎕AI[3]-start),' seconds'
