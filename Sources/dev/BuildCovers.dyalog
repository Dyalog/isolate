 BuildCovers
⍝ Build cover-functions and operators

 II←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.ll⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.ll)⍵}
 IIÐ←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llKey⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llKey)⍵}
 IIö←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llRank ⍵⍵⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llRank ⍵⍵)⍵}
 IÏ←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llEach⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llEach)⍵}
 o_II←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llOuter⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llOuter)⍵}
 ø←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:#.isolate.ynys.New⊢⍵ ⋄ ⍺(#.isolate.ynys.New)⍵}

 :With isolate
     AddServer←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:#.isolate.ynys.AddServer⊢⍵ ⋄ ⍺(#.isolate.ynys.AddServer)⍵}
     Config←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:#.isolate.ynys.Config⊢⍵ ⋄ ⍺(#.isolate.ynys.Config)⍵}
     InternalState←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍺(#.isolate.ynys.InternalState)⍵}
     LastError←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍺(#.isolate.ynys.LastError)⍵}
     New←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:#.isolate.ynys.New⊢⍵ ⋄ ⍺(#.isolate.ynys.New)⍵}
     Reset←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:#.isolate.ynys.Reset⊢⍵ ⋄ ⍺(#.isolate.ynys.Reset)⍵}

     StartServer←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:#.isolate.ynys.StartServer⊢⍵ ⋄ ⍺(#.isolate.ynys.StartServer)⍵}
     ll←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.ll⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.ll)⍵}
     llEach←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llEach⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llEach)⍵}
     llKey←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llKey⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llKey)⍵}
     llOuter←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llOuter⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llOuter)⍵}
     llRank←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llRank ⍵⍵⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llRank ⍵⍵)⍵}
 :EndWith