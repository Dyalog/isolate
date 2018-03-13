:Class AWS

    ⍝ Experimental tools for running AWS isolate images
    ⍝ Assumes AWS Command Line interface is installed and configured
    ⍝ See https://docs.aws.amazon.com/cli/latest/userguide/installing.html

    ⍝ /// Field defaults for Mortens testing, should be cleared out
    :Field Public keypair  ← 'AWS-JSONServer'   ⍝ Name of an AWS key pair
    :Field Public region   ← 'eu-west-1'        ⍝ Ireland
    :Field Public image    ← 'ami-4e612f37'     ⍝ Ubunto 16.04 with Dyalog APL and updated isolate workspace
    :Field Public type     ← 't1.micro'         ⍝ instance-type
    :Field Public security ← 'Isolate ssh RIDE' ⍝ Ports to open
    :Field Public aplcmd   ← 'isolate=isolate Port=7052 AutoShut=1 dyalog isolate'
    :Field Public myIP     ← ''
    :Field Public AWSver   ← ''

    ∇ make;z      

      :Access Public
      :Implements Constructor
      
       :If ∨/'aws-cli'⍷z←∊⎕SH 'aws --version 2>&1'
           AWSver←z
       :Else
           'Amazon Web Service Command Line Interface does not seem to be installed' ⎕SIGNAL 12
       :EndIf     
    ∇

    ∇ r←SetMyIp;z
    ⍝ Set my public IP address using https://api.ipify.org
    ⍝ NB will load #.HttpCommand if not present
     
      :Access Public
     
      r←''
      :Trap 0
          :If 0=⎕NC'#.HttpCommand'
              ⎕SE.SALT.Load'HttpCommand'
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

    ∇ r←RunInstances n;cmd;z         
     ⍝ Start n instances of our image     

     :Access Public

      cmd←'aws ec2 run-instances --region ',region,' --image-id ',image
      cmd,←' --count ',(⍕n),' --instance-type ',type
      cmd,←' --key-name ',keypair
      cmd,←' --security-groups ',security,' --output=json'     
      z←⎕SH cmd                                           
      r←StateInfo (⎕JSON ∊z).Instances
      ∘∘∘
    ∇                                 
    
    ∇r←StateInfo is
    ⍝ Extract interesting State Information from an AWS "Instances" structure

     r←↑⊃,/is.(InstanceId ImageId State.Name({0::'' ⋄ PublicIpAddress}⍬))    
    ∇


    ∇r←RunIsolates n
    ⍝ Start n Isolate Servers using available images      
    
    :Access Public

       r←CurrentState image
       ∘∘∘  

    ∇

    :Class IsolateServer

        :Field Public TID

        ∇ Start(host user key);CR;LF;host;sess;keyfolder;public;private
          :Access Public
          :Implements Constructor
         
          (CR LF)←⎕UCS 13 10
          Exec←{CR@(=∘LF)⎕UCS 2⊃⍺.Exec ⍵} ⍝ Unix Command, replacing LF by CR
         
          keyfolder←'C:\Users\mkrom\Documents\SSH\'
          sess←⎕NEW SSH.Session(host 22)
         
          public←keyfolder,key,'.pub'
          private←keyfolder,key,'.ppk'
          sess.Userauth_Publickey user public private''
         
          sess Exec'uname -a'
          sess Exec'ps -ef|grep dyalog' ⍝ Paranoia: Any running APL Processes?
         
          ride_init←'SERVE::4502'
          myip←'50.48.70.130' ⍝ My IP address (validated by server)
         
         ⍝ The rest will be automatically set once Isolates support SSH natively (v17)   
         ⍝ AllowRemote=\"IP=::ffff:86.52.128.126\" dyalog isolate"'

          sess Exec'isolate=isolate Port=7052 AutoShut=1 AllowRemote="',myip,'" dyalog isolate'
        ∇         

    :EndClass



:EndClass
