 r←DRCClt args;count
      ⍝ Create a DRC Client, looping a bit

 {}DRC.Close⊃args ⍝ Paranoia, the bug is somewhere else, sorry!
 count←0
 :While 0≠⊃r←DRC.Clt args ⍝ Cannot connect
     :Select ⊃r
     :Case 1106
         ('ISOLATE: Unable to resolve or parse hostname: ',⍕args)⎕SIGNAL 11
     :CaseList 61 111 1111 10061 ⍝ Connection Refused is 61 on macOS, 10061 under Windows
         {}⎕DL session.retry_interval×count+←1 ⍝ longer wait each time
     :Else
         ('ISOLATE: Unable to connect to isolate process: ',⍕args)⎕SIGNAL 11
     :EndSelect
 :Until count≥session.retry_limit
