 TestAWS n;iss;procs;z

 :If '16'≢2↑2⊃'.'⎕WG'APLVersion'
     'Use v16.0 for this test'⎕SIGNAL 11
 :EndIf

 iAWS←⎕NEW AWS
 'Current IP is: ',iAWS.SetMyIp

 ⍝ iAWS.RunInstances n
 ⍝ Wait for them to be running

 ⎕←'Starting Isolate Servers...'
 procs←iAWS.RunIsolates n
 ⎕←'Connecting to Isolate Servers:'
 iAWS.AddServers procs
 iss←isolate.New¨n⍴⊂''
 ⍪iss.⎕SH⊂'uname -a'
 ⎕EX'iss'
 ⎕←'Shutting down'
 z←isolate.RemoveServer¨procs.Address ⋄ ⎕TSYNC procs.TID

 ⍝ iAWS.Terminate ''
 ⍝ Wait for them to stop

 ⎕←'Test complete'
