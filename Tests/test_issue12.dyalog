 z←test_issue12 dummy;test;double;ports;homeportmax;homeport
 ⍝ test fix for GitHub issue 12 - homeport not being assigned from config

 {}#.isolate.Config'homeport'(homeport←23232)
 {}#.isolate.Config'homeportmax'(homeportmax←23332)
 {}#.isolate.Config'processors' 4

 {}#.isolate.Reset 0

 test←'homeport test'
 double←{⍵+⍵}#.IÏ⍳4
 ⎕DL 0.5
 :Trap 0
     ports←{2 4⊃#.DRC.GetProp(⊃⊃⍵)'PeerAddr'}¨2 2⊃#.DRC.Tree'.'
     'isolate not using Config homeport'Fail 1∧.=(homeport,1+homeportmax)⍸ports
 :Else
     ((⊃⎕DM),' in test_issue12 ')Fail 0
 :EndTrap
 z←''
