 getSet←{⍺←⊢

     0∊⍴⍵:{(~⍵[;0]∊'debug' 'status')⌿⍵}options.({⍵,⍪⍎⍕⍵}⎕NL-2 9)
     one←1=≡⍵
     two←one<(,2)≡⍴⍵
     sig11←⎕SIGNAL∘11
     msg←'Argument should be '''', name or (name value)'
     one⍱two:sig11 msg
     (nam new)←⊂⍣one⊢⍵
     ''≢0⍴nam:sig11 msg
     nam←minuscule nam
     ~(⊂nam)∊options.⎕NL-2 9:sig11'Unknown parameter: ',nam
     old←options.⍎nam
     one:old

⍝ then two
     and←{⍺⍺⊣⍵:⍵⍵⊣⍵ ⋄ 0}
     (range type)←(domains types).⍎⊂nam
     (s b i r a)←'SBIRA'=type
     msg←nam,' should be a',⍕s b i r/'string' 'boolean' 'integer' 'ref'

     ok←a ⍝ Any array
     ok←ok∨b and(⊢≡1=⊢)new
     ok←ok∨i and{0=1↑0⍴⍵}and(⊢=⌊)new
     ok←ok∨s and{''≡0⍴⍵}new
     ok←ok∨r and{9=⎕NC'⍵'}new
     ~ok:sig11 msg
     ok←ok∧((1=⍴)∨(⊂new)∊⊢)range
     ~ok:sig11⍕nam,' should be one of:',range

     (ws db li)←'workspace' 'debug' 'listen'∊⊂nam ⍝ special
     0::(⊃⎕DMX.DM)⎕SIGNAL ⎕DMX.EN                         ⍝
     z←checkWs⍣(ws∧new≢'')⊢new                            ⍝
     z←{⎕THIS.(trapErr←(⍵↓0)∘⊣) ⋄ 0}⍣db⊢new       ⍝
     z←localServer⍣li⊢new                         ⍝ cases
     old⊣nam options.{⍎⍺,'←⍵'}new

⍝    }⍵
⍝ ⍺ target space
⍝ ⍵ '' | name | name value
⍝ ← (⍵:'') all names and values
⍝   (⍵:name) value
⍝   (⍵:name value) value re-assigned
⍝ called by both Config and setDefaults
 }
