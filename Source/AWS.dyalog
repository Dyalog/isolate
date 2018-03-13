:Class AWS

    ⍝ Experimental tools for running AWS isolate images
    ⍝ Assumes AWS Command Line interface is installed and configured
    ⍝ See https://docs.aws.amazon.com/cli/latest/userguide/installing.html

    ⍝ /// Field defaults for Mortens testing, should be cleared out
    :Field Public user     ← 'ubuntu'           ⍝ User name to log in to 
    :Field Public keyfolder←'C:\Users\mkrom\Documents\SSH\' ⍝ Where the key files are         
    :Field Public keypair  ← 'AWS-JSONServer'   ⍝ Name of an AWS key pair
    :Field Public region   ← 'eu-west-1'        ⍝ Ireland
    :Field Public image    ← 'ami-4e612f37'     ⍝ Ubuntu 16.04 with Dyalog APL and updated isolate workspace
    :Field Public type     ← 't1.micro'         ⍝ instance-type
    :Field Public security ← 'Isolate ssh RIDE' ⍝ Ports to open
    :Field Public aplcmd   ← 'isolate=isolate Port=7052 AutoShut=1 dyalog isolate'
    :Field Public myIP     ← ''
    :Field Public AWSver   ← '' 
    :Field Public servers  ← ⍬      

    ∇ make;z      
     ⍝ Create instance and verify that AWS-CLI is available

      :Access Public
      :Implements Constructor
      
       :If ∨/'aws-cli'⍷z←∊⎕SH 'aws --version 2>&1'
           AWSver←z
       :Else
           'Amazon Web Service Command Line Interface does not seem to be available' ⎕SIGNAL 12
       :EndIf     
    ∇

    ∇ r←SetMyIp;z
    ⍝ Set my public IP address using https://api.ipify.org
    ⍝ NB will load #.HttpCommand if not present
     
      :Access Public
     
      r←''
      :Trap 0
          :If 0=⎕NC'#.HttpCommand'
              ⎕SE.SALT.Load'HttpCommand -target=#'
          :EndIf
          z←#.HttpCommand.Get'https://api.ipify.org?format=json'
          :If 0=z.rc
          :AndIf 200=z.HttpStatus
              r←myIP←(⎕JSON z.Data).ip
          :EndIf
      :EndTrap
     
    ∇

    ∇ r←CurrentState img;ns;filters
     ⍝ Return matrix of instance-id, imake-id, state, public-ip
     ⍝ Right argument can be '' to filter using default image, * to not filter, or a specific image id
     
      :Access Public
     
      ⍝ Decide whether to filter on an image
      :If (,img)≡,'*' ⋄ filters←''
      :Else ⋄ filters←' --filters Name=image-id,Values=',img,(0=≢img)/image
      :EndIf
     
      :Trap 0
          ns←⎕SH'aws ec2 describe-instances --region ',region,filters,' --output json'
          r←StateInfo (⎕JSON ∊ns).Reservations.Instances
      :Else
          'Unable to determine instance state'⎕SIGNAL 11
      :EndTrap
    ∇

    ∇ r←Terminate img;state;running;filter;ns
     ⍝ Return matrix of instance-id, imake-id, state, public-ip
     ⍝ Right argument can be '' to filter using default image, * to not filter, or a specific image id
     
      :Access Public
      
      img←img,(0=≢img)/image

      state←CurrentState image
      running←⍸state[;3]∊⊂'running'   
      filter←' --instance-ids ',⍕state[running;1]
           
      :Trap 0
          ns←⎕SH'aws ec2 terminate-instances --region ',region,filter,' --output json'
          r←StateInfo ,⊂(⎕JSON ∊ns).Instances
      :Else
          ∘∘∘
          'Unable to determine instance state'⎕SIGNAL 11
      :EndTrap
    ∇

    ∇ r←RunInstances n;cmd;z         
     ⍝ Start n instances of our image     

     :Access Public

      cmd←'aws ec2 run-instances --region ',region,' --image-id ',image
      cmd,←' --count ',(⍕n),' --instance-type ',type
      cmd,←' --key-name ',keypair
      cmd,←' --security-groups ',security,' --output=json'     
      z←⎕SH cmd                                           
      r←StateInfo ,⊂(⎕JSON ∊z).Instances
    ∇                                 
    
    ∇r←StateInfo is
    ⍝ Extract interesting State Information from an AWS "Instances" structure

     r←↑⊃,/is.(InstanceId ImageId State.Name({0::'' ⋄ PublicIpAddress}⍬))    
    ∇


    ∇r←RunIsolates n;p;running;i;z;cmd;solo;host;state
    ⍝ Start n Isolate Servers using available images      
    
    :Access Public

       state←CurrentState image  
       r←⍬

       ⍝ Check we have enough running instances  
       :If n>≢running←⍸state[;3]∊⊂'running'
           p←≢⍸state[;3]∊⊂'pending'
           ('Only ',(⍕≢running),' running instances',(p≠0)/'(',(⍕p),' pending)') ⎕SIGNAL 11 
       :EndIf                                               
       
       solo←1 ⍝ Only allow one dyalog process on the machine

       :For i :In running            
            ⍝ ride_init←'SERVE::4502' 
            host←⊃state[i;4]
            cmd←'isolate=isolate Port=7052 AutoShut=1 AllowRemote="IP=',myIP,'" dyalog /home/ubuntu/isolate'
            z←⎕NEW RemoteProcess (host user keypair cmd solo)
            r,←z                        
       :EndFor          
    ∇                 
    
    ∇ r←AddServers procs;p
    :Access Public
    
    :For p :In procs
        r←#.isolate.AddServer p.Address 7052
    :EndFor    
    ∇

    :Class RemoteProcess

        :Field Public TID←¯1
        :Field Public uname←'' 
        :Field Public Process←⎕NS ''
        :Field Public Command←⎕NS '' 
        :Field Public Address←''

        (CR LF)←⎕UCS 13 10
        QSH←{CR@(=∘LF)⎕UCS 2⊃⍺.Exec ⍵} ⍝ Unix Command, replacing LF by CR

        ∇ r←Running
        :Access Public
          r←TID∊⎕TNUMS
        ∇

        ∇ Start(host user key cmd solo);host;sess;public;private;z
          :Access Public
          :Implements Constructor

          :If 0=⎕NC '#.SSH'   
              ⎕SE.SALT.Load 'c:\devt\aplssh\SSH -target=#'
          :AndIf 0=⎕NC '#.SSH'   
              'aplssh needs to be loaded into #' ⎕SIGNAL 6
          :EndIf
                   
          public←##.keyfolder,key,'.pub'
          private←##.keyfolder,key,'.pem'

          Process←⎕NEW #.SSH.Session(host 22)
          Command←⎕NEW #.SSH.Session(host 22)
         
          Process.Userauth_Publickey user public private''
          Command.Userauth_Publickey user public private''
         
          uname←∊Command QSH 'uname -a' 

          :If solo
          :AndIf 0≠≢Dyalogs
             ∘∘∘ ⍝ already busy
          :EndIf
          
          TID←Process QSH& cmd   
          Address←host
        ∇ 
        
        ∇r←Dyalogs
        ⍝ return ps output for running Dyalog processes
        :Access Public

         r←Command QSH 'ps -ef|grep dyalog|grep -v grep'          
        ∇        

    :EndClass



:EndClass
