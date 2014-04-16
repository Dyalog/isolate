:namespace isolate
⍝ ## ←→ #

(⎕IO ⎕ML)←0 0

 AddServer←{⍺←⊢
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     ⍺ ynys.AddServer ⍵
⍝
 }

 Init←{⍺←⊢
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     ⍺ ynys.Init ⍵
⍝
 }

 Install←{⍺←⊢
     0::(⊃⊣/⎕DM)⎕SIGNAL ⎕EN
     ⍺ ynys.Install ⍵
⍝
 }

 New←{⍺←⊢
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     ⍺ ynys.New ⍵
⍝ ynys - Welsh - island - cognate with insular, isolate &c.
⍝ and beginning with "y" it's at the bottom of autocomplete
 }

 Options←{⍺←⊢
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     ⍺ ynys.Options ⍵
⍝
 }

 RunAsServer←{⍺←⊢
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     ⍺ ynys.RunAsServer ⍵
⍝
 }

 ll←{⍺←⊢
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     ⍺(⍺⍺ ynys.ll)⍵
⍝
 }

 llEach←{⍺←⊢
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     ⍺(⍺⍺ ynys.llEach)⍵
⍝
 }

 llOuter←{⍺←⊢
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     ⍺(⍺⍺ ynys.llOuter)⍵
⍝
 }

 llRank←{⍺←⊢
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     ⍺(⍺⍺ ynys.llRank ⍵⍵)⍵
⍝
 }

:endnamespace
