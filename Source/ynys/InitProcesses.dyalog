 r←ss InitProcesses op;z;count;limit;ok;maxws;ws;rt;iso;ports;pids;pclts;procs;m
 (count limit)←0 3
 maxws←' MAXWS=',⍕op.maxws
 ws←op.workspace
 :If (⊂rt←op.runtime)∊0 1      ⍝ if rt is boolean
     rt←rt∧op.onerror≢'debug' ⍝ force runtime←0 if onerror≡'debug'
 :EndIf
 iso←('isolate=isolate onerror=',(⍕op.onerror),' isoid=',(⍕ss.callback),maxws)
 iso,←' protocol=',op.protocol,' quiet=1'
 :If ws∨.≠' ' ⋄ ws←1⌽'""',checkWs addWSpath ws ⋄ :EndIf ⍝ if no path ('\/')
 ports←ss.homeport+1+⍳op.(processors×processes)

 :Repeat
     :If 0∊m←checkPortIsFree¨ports
         ⎕←'*** Warning - isolate port(s) in use: ',(~m)/ports
         ports←ports+1+⍴ports
     :EndIf
 :Until (∧/m)∨(⊃ports)>1+op.homeportmax
 'ISOLATE: Unable to find free ports'⎕SIGNAL(∧/m)↓11

 pids←(1⊃⎕AI)+⍳⍴ports

 :Repeat
     count+←1
     procs←{⎕NEW ##.APLProcess(ws ⍵ rt)}∘{'AutoShut=1 Port=',(⍕⍵),' APLCORENAME=',(⍕⍵),' ',iso}¨ports
     procs.onExit←{'{}#.DRC.Close ''PROC',⍵,''''}¨⍕¨pids ⍝ signal soft shutdown to process

     pclts←pids InitConnections ss.orig ports ss.callback ss.remoteclients

     :If ~ok←~∨/0∊≢¨pclts ⍝ at least one failed
         ⎕←'ISOLATE: Unable to connect to started processes (attempt ',(⍕count),' of ',(⍕limit),')'
         ⎕DL 5 ⋄ {}procs.Kill ⋄ ⎕DL 5
         ports+←1+op.(processors×processes)
     :EndIf
 :Until ok∨count≥limit
 'ISOLATE: Unable to initialise isolate processes'⎕SIGNAL ok↓11
 r←pids,procs,(⊂ss.orig),ports,⍪pclts
