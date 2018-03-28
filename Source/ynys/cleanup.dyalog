 cleanup←{⍺←⊢
     trapErr''::signal''
     (chrid port numid)←⍵.(chrid port numid)
     ⎕←⍪'.'/⍨options.debug
     (ns←⎕NS proxyClone).(iD iSpace)←⍵ iSpace    ⍝ recreate temp proxy
     rem←{session.assoc.(iso proc busy⌿⍨←⊂iso≠⍵)}
     11::rem numid                               ⍝ DRC reported errors
     z←ns.iSend{⍵(1('{#.⎕EX''',⍵,'''}')0)}chrid  ⍝ expunge remote namespace
     z←DRC.Close chrid
     rem numid                                   ⍝ remove numid from table
     1:
⍝ called by destructor of suicide class when isolate proxy disappears.
⍝ ⍵     space: chrid port mumid
⍝ numid unique numeric identifier for isolate
⍝ chrid identifies DRC client and isolate space in remote process
⍝ port  on which process is listening
 }
