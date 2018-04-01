:Class AWS

    ⍝ Tool for launching AWS images

    ⍝ Assumes AWS Command Line interface is installed and configured
    ⍝ See https://docs.aws.amazon.com/cli/latest/userguide/installing.html

    :Field Public user      ← ''    ⍝ User name to log in to
    :Field Public keyfolder ← ''    ⍝ Where the key files are
    :Field Public keypair   ← ''    ⍝ Name of an AWS key pair
    :Field Public region    ← ''    ⍝ e.g. eu-west-1 for Ireland
    :Field Public image     ← ''    ⍝ e.g. ami-4e612f37ami-xxxxxxx
    :Field Public type      ← ''    ⍝ instance-type, e.g. t1.micro
    :Field Public security  ← ''    ⍝ Security profiles to attach  

    :Field Public myIP      ← ''    ⍝ current IP address (if SetMyIp has been called)
    :Field Public AWSver    ← ''    ⍝ AWS-CLI version info

    ∇ make;z
     ⍝ Create an instance and verify that AWS-CLI is available
     
      :Access Public
      :Implements Constructor
     
      :If ∨/'aws-cli'⍷z←∊⎕SH'aws --version 2>&1'
          AWSver←z
      :Else
          'Amazon Web Service Command Line Interface does not seem to be available'⎕SIGNAL 12
      :EndIf
    ∇

    ∇ {r}←SetMyIp;z
    ⍝ Set my public IP address using https://api.ipify.org
    ⍝ NB will load #.HttpCommand if not present
     
      :Access Public
     
      r←''
      :Trap 0
          :If 0=⎕NC '#.HttpCommand'
              ⎕SE.SALT.Load 'HttpCommand -target=#'
          :EndIf
          z←#.HttpCommand.Get 'https://api.ipify.org?format=json'
          :If 0=z.rc
          :AndIf 200=z.HttpStatus
              r←myIP←(⎕JSON z.Data).ip
          :EndIf
      :EndTrap
     
    ∇

    ∇ r←CurrentState img;ns;filters
     ⍝ Return matrix of instance-id, image-id, state, public-ip
     ⍝ Right argument can be '' to filter using default image, * to not filter, or a specific image id
     
      :Access Public
     
      ⍝ Decide whether to filter on an image
      :If (,img)≡,'*' ⋄ filters←''
      :Else ⋄ filters←' --filters Name=image-id,Values=',img,(0=≢img)/image
      :EndIf
     
      ns←JSONcmd'aws ec2 describe-instances --region ',region,filters,' --output json'
      r←StateInfo ns.Reservations.Instances
    ∇

    ∇ r←{wait}Terminate img;state;running;filter;ns;instances;done;n;cmd
     ⍝ Return matrix of instance-id, imake-id, state, public-ip
     ⍝ Right argument can be : '' to filter using default image,
     ⍝                       : '*' to terminate all images
     ⍝                       : simple char vec to terminate all instances of a specific image-id
     ⍝                       : vec-of-vecs to terminate specific instance-ids
     
      :Access Public
     
      :If 0=⎕NC'wait' ⋄ wait←0 ⋄ :EndIf     
      
      :If 2=≢img ⍝ vector of specific instance-ids
          state←CurrentState '*'
          state←(state[;1]∊img)⌿state
      :Else
          img←img,(0=≢img)/image     ⍝ '' = default image
          state←CurrentState image
      :EndIf
     
      :If 0≠≢running←⍸state[;3]∊⊂'running'
          filter←' --instance-ids ',⍕state[running;1]
     
          ns←JSONcmd'aws ec2 terminate-instances --region ',region,filter,' --output json'
          r←↑ns.TerminatingInstances.(InstanceId''PreviousState.Name'')
     
          n←≢instances←r[;1]
          →wait↓0
     
          :Repeat
              r←(r[;1]∊instances)⌿r
              :If ~done←n≤+/r[;3]∊'terminated' 'shutting-down'
                  ⎕←(,'ZI2,<:>,ZI2,<:>,ZI2,< >'⎕FMT 1 3⍴3↑3↓⎕TS),,⍕{⍺,≢⍵}⌸r[;3]
                  ⎕DL 3
                  r←CurrentState''
              :EndIf
          :Until done
      :EndIf
    ∇

    ∇ r←{wait}RunInstances n;cmd;z;done;instances;addr
     ⍝ Start n instances of the current image
     
      :Access Public
     
      :If 0=⎕NC'wait' ⋄ wait←0 ⋄ :EndIf
     
      cmd←'aws ec2 run-instances --region ',region,' --image-id ',image
      cmd,←' --count ',(⍕n),' --instance-type ',type
      cmd,←' --key-name ',keypair
      cmd,←' --security-groups ',security,' --output=json'
      ⎕←cmd
      r←JSONcmd cmd
     
      r←StateInfo,⊂r.Instances
      instances←r[;1]
      →wait↓0
     
      :Repeat
          r←(r[;1]∊instances)⌿r
          :If ~done←n≤+/r[;3]∊⊂'running'
              ⎕←(,'ZI2,<.>,ZI2,<.>,ZI2,< >'⎕FMT 1 3⍴3↑3↓⎕TS),,⍕{⍺,≢⍵}⌸r[;3]
              ⎕DL 3
              r←CurrentState''
          :EndIf
      :Until done
    ∇

    ∇ r←StateInfo is
    ⍝ Extract interesting State Information from an AWS "Instances" structure
     
      r←↑⊃,/is.(InstanceId ImageId State.Name({0::'' ⋄ PublicIpAddress}⍬))
    ∇


    ∇ r←Launch(n cmd);p;running;i;z;cmd;solo;host;state
    ⍝ Launch n processes using available instances
     
      :Access Public
     
      state←CurrentState image
      r←⍬
     
       ⍝ Check we have enough running instances
      :If n>≢running←⍸state[;3]∊⊂'running'
          p←≢⍸state[;3]∊⊂'pending'
          ('Only ',(⍕≢running),' running instances',(p≠0)/'(',(⍕p),' pending)')⎕SIGNAL 11
      :EndIf
     
      solo←1 ⍝ Only allow one dyalog process on the machine
     
      :For i :In running
          host←⊃state[i;4]
          z←⎕NEW RemoteProcess(host user keypair cmd solo)
          r,←z
      :EndFor
    ∇

    ∇ r←JSONcmd cmd;z
    ⍝ Run a shell command which is supposed to return JSON
     
      z←∊⎕SH cmd,' 2>&1'
      :Trap 0
          r←⎕JSON z
      :Else
          z ⎕SIGNAL 11
      :EndTrap
    ∇

    :Class RemoteProcess

        :Field Public TID←¯1
        :Field Public uname←''
        :Field Public Address←''
        :Field Public Process←⎕NULL
        :Field Public Command←⎕NULL
        :Field Public Output←⎕NULL

        (CR LF)←⎕UCS 13 10
        QSH←{CR@(=∘LF)⎕UCS 2⊃⍺.Exec ⍵} ⍝ Unix Command, replacing LF by CR

        ∇ r←Running
          :Access Public
          r←TID∊⎕TNUMS
        ∇

        ∇ Start(host user key cmd solo);host;sess;public;private;z;ok
          :Access Public
          :Implements Constructor
         
          :If 0=⎕NC'#.SSH'
              ⎕SE.SALT.Load'c:\devt\aplssh\SSH -target=#'
          :AndIf 0=⎕NC'#.SSH'
              'aplssh needs to be loaded into #'⎕SIGNAL 6
          :EndIf
         
          public←##.keyfolder,key,'.pub'
          private←##.keyfolder,key,'.pem'
         
          :Repeat
              :Trap 701 801 ⍝ Sometimes the first SSH attempt fails
                  Process←⎕NEW #.SSH.Session(host 22)
                  Command←⎕NEW #.SSH.Session(host 22)
                  Process.Userauth_Publickey user public private''
                  Command.Userauth_Publickey user public private''
                  ok←1
              :Else
                  ⎕←'   Error ',⎕DMX.Message,' connecting to ',host,' - retrying'
                  ⎕DL 2
                  ok←0
              :EndTrap
          :Until ok
         
          :If solo
          :AndIf 0≠≢Dyalogs
              ∘∘∘ ⍝ already busy
          :EndIf
         
          TID←RunProcess&cmd
          Address←host
        ∇

        ∇ r←RunProcess cmd
        ⍝ Run process and collect output
          r←Output←Process QSH cmd
        ∇

        ∇ r←Dyalogs
          :Access Public
        ⍝ return ps output for running Dyalog processes
          :Access Public
         
          r←Command QSH'ps -ef|grep dyalog|grep -v grep'
        ∇

        ∇ r←SH cmd
        ⍝ Run shell command on the "Command" SSH connection
          :Access Public
          r←Command QSH cmd
        ∇

    :EndClass


:EndClass
