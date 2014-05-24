 BuildCovers
⍝ Build cover-functions and operators

 II←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.ll⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.ll)⍵}
 IIÐ←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llKey⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llKey)⍵}
 IIö←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llRank ⍵⍵⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llRank ⍵⍵)⍵}
 IÏ←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llEach⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llEach)⍵}
 o_II←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llOuter⊢⍵ ⋄ ⍺(⍺⍺ #.isolate.ynys.llOuter)⍵}
 ø←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:#.isolate.ynys.New⊢⍵ ⋄ ⍺(#.isolate.ynys.New)⍵}

 :With isolate

     New←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:ynys.New⊢⍵ ⋄ ⍺(ynys.New)⍵}
     Reset←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:ynys.Reset⊢⍵ ⋄ ⍺(ynys.Reset)⍵}

     ll←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.ll⊢⍵ ⋄ ⍺(⍺⍺ ynys.ll)⍵}
     llEach←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llEach⊢⍵ ⋄ ⍺(⍺⍺ ynys.llEach)⍵}
     llKey←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llKey⊢⍵ ⋄ ⍺(⍺⍺ ynys.llKey)⍵}
     llOuter←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llOuter⊢⍵ ⋄ ⍺(⍺⍺ ynys.llOuter)⍵}
     llRank←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:⍺⍺ #.isolate.ynys.llRank ⍵⍵⊢⍵ ⋄ ⍺(⍺⍺ ynys.llRank ⍵⍵)⍵}

     AddServer←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:ynys.AddServer⊢⍵ ⋄ ⍺(ynys.AddServer)⍵}
     StartServer←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:#.isolate.ynys.StartServer⊢⍵ ⋄ ⍺(ynys.StartServer)⍵}
     Config←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:ynys.Config⊢⍵ ⋄ ⍺(ynys.Config)⍵}

     Values←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍵≡⍺ ⍵:ynys.Values⊢⍵ ⋄ ⍺(ynys.Values)⍵}
     Available←{0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ynys.Available ⍵}
     Failed←{0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ynys.Failed ⍵}
     Running←{0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ynys.Running ⍵}

 :EndWith