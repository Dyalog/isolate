:Namespace RPCServer
    (⎕IO ⎕ML)←1 0

    ∇ r←{folder}Launch(params port);z;folder;ws
    ⍝ Launch RPC Server as an external process
    ⍝ Params should include -Load=
    ⍝ See Boot for additional parameters
    ⍝ RPCServer.dyalog and RPCServer.dws must exist in same folder as current ws
    ⍝ /// Currently Windows only ///
     
      :If 0=⎕NC'folder' ⋄ folder←{(1-⌊/(⌽⍵)⍳'/\')↓⍵}⎕WSID ⋄ :EndIf
      ws←'"',folder,'RPCServer.DWS"'
      params←params,' Port=',⍕port
      r←⎕NEW #.APLProcess(ws params)
    ∇

    ∇ Boot;name;port;certfile;keyfile;sslflags;num;getenv;secure;load;l;folder
    ⍝ Bootstrap an RPC-Server using the following command line parameters
    ⍝ -Port=nnnn
    ⍝ -Load=.dyalog files to load before start
    ⍝ SSL Options
    ⍝ -CertFile=CertFile
    ⍝ -KeyFile=KeyFile
    ⍝ -SSLFlags=flags
    ⍝ /// Could be extended with
    ⍝ -Config=name of a configuration file
    ⍝ -ClientAddr=limit to connections from given site
     
      folder←{(1-⌊/(⌽⍵)⍳'/\')↓⍵}⎕WSID
      getenv←{2 ⎕NQ'.' 'GetEnvironment'⍵}
      num←{⊃2⊃⎕VFI ⍵}
      sslflags←32+64 ⍝ Accept without Validating, RequestClientCertificate
     
      name←'RPCSRV'
      port←num getenv'Port'
     
      :If 0≠⍴load←getenv'Load'
          load←{1↓¨(','=⍵)⊂⍵}',',load
          :For l :In load
              ⎕SE.SALT.Load folder,l,' -target=#'
          :EndFor
      :EndIf
     
      :If secure←0≠⍴certfile←getenv'CertFile'
          keyfile←getenv'KeyFile'
          sslflags←num getenv'SSLFlags'
          z←1 Run name port('CertFile'certfile)('KeyFile'keyfile)('SSLFlags'sslflags)
      :Else
          z←1 Run name port
      :EndIf
     
      :If 0≠1⊃z ⋄ ⎕←z ⋄ ⎕DL 10 ⋄ :EndIf ⍝ /// Pop up? Log?
     
      :While ##.DRC.Exists name
          ⎕DL 10
      :EndWhile
     
      ⎕OFF
    ∇

    ∇ r←End x
      r←done←x ⍝ Will cause server to shut down
    ∇

    ∇ Process(obj data);r
      ⍝ Process a call. data[1] contains function name, data[2] an argument
     
      {}##.DRC.Progress obj('    Thread ',(⍕⎕TID),' started to run: ',,⍕data) ⍝ Send progress report
     
      :Trap 0 ⋄ r←0((⍎1⊃data)(2⊃data))
      :Else ⋄ r←⎕EN ⎕DM
      :EndTrap
     
      {}##.DRC.Respond obj r
    ∇

    ∇ r←{start}Run args;sink;done;data;event;obj;rc;wait;z;cmd;name;port;protocol;srvparams
      ⍝ Run a Simple RPC Server
     
      (name port)←2↑args
      srvparams←2↓args
     
      :If 0=⎕NC'start' ⋄ start←1 ⋄ :EndIf
      {}##.DRC.Init''
     
      :If start
          →(0≠1⊃r←##.DRC.Srv(name''port'Command'),srvparams)⍴0 ⍝ Exit if unable to start server
          'Server ''',name,''', listening on port ',⍕port
          ' Handler thread started: ',⍕0 Run&name port
          ⍝ Above line starts handler on separate thread (which continues from :Else below)
     
      :Else ⍝ Handle the server (in a new thread)
          ' Thread ',(⍕⎕TID),' is now handing server ''',name,'''.'
          done←0 ⍝ Done←1 in function "End"
     
          :While ~done
              :Trap 1002 1003 ⍝ trap weak and strong interrupts - on UNIX kill -2 and kill -3
     
                  rc obj event data←4↑wait←##.DRC.Wait name 3000 ⍝ Time out now and again
     
                  :Select rc
                  :Case 0
                      :Select event
                      :Case 'Error'
                          ⎕←'Error ',(⍕data),' on ',obj
                          :If ~done∨←name≡obj ⍝ Error on the listener itself?
                              {}##.DRC.Close obj ⍝ Close connection in error
                          :EndIf
     
                      :Case 'Receive'
                          :If 2≠⍴data ⍝ Command is expected to be (function name)(argument)
                              {}##.DRC.Respond obj(99999 'Bad command format') ⋄ :Leave
                          :EndIf
     
                          :If 3≠⎕NC cmd←1⊃data ⍝ Command is expected to be a function in this ws
                              {}##.DRC.Respond obj(99999('Illegal command: ',cmd)) ⋄ :Leave
                          :EndIf
     
                          Process&obj data ⍝ Handle each call in new thread
     
                      :Case 'Connect' ⍝ Ignored
     
                      :Else ⍝ Unexpected result? should NEVER happen
                          ⎕←'Unexpected result "',event,'" from object "',name,'" - RPC Server shutting down' ⋄ done←1
     
                      :EndSelect
     
                  :Case 100  ⍝ Time out - Insert code for housekeeping tasks here
     
                  :Case 1010 ⍝ Object Not Found
                      ⎕←'Object ''',name,''' has been closed - RPC Server shutting down' ⋄ done←1
     
                  :Else
                      ⎕←'Error in RPC.Wait: ',⍕wait
                  :EndSelect
              :Else ⍝ got an interrupt
                  ⎕←((1002 1003⍳⎕EN)⊃'Soft' 'Hard' 'Unknown?'),' interrupt received, RPC Server shutting down'
                  done←1
              :EndTrap
          :EndWhile
          ⎕DL 1 ⍝ Give responses time to complete
          {}##.DRC.Close name
          ⎕←'Server ',name,' terminated.'
     
      :EndIf
    ∇

:EndNamespace