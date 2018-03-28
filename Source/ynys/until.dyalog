 until←{⍺←⊢ ⋄ f←⍺⍺ ⋄ t←⍵⍵
     ⍵≡⍺ ⍵:f⍣(t⊣)⍵
     ⍺{ ⍝ keep recursion local
         (⍺-1)∘∇⍣((⍺>1)>t z)⊢z←f ⍵
     }⍵
⍝ ⍺     [max]
⍝ ⍺⍺    monadic fn on arg - may be composed: (const∘function)
⍝ ⍵⍵    monadic test on arg or subsequent results
⍝ ⍵     arg
⍝       apply fn [up to max times] until test result
⍝ ←     last application of fn
⍝ e.g.
⍝       10 +∘1 until (≥∘5) 0
⍝ 5
⍝       10 +∘1 until (≥∘15) 0
⍝ 10
⍝       +∘1 until (≥∘5) 0
⍝ 5
⍝       +∘1 until (≥∘15) 0
⍝ 15
 }
