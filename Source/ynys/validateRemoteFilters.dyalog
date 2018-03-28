 validateRemoteFilters←{
     0=⍴⍵:⍵ ⍝ Validate filters and return nested vector
     z←{1↓¨(','=⍵)⊂⍵}',',⍵~' ' ⍝ Split on comma
     0∊(3↑¨z)∊'ip=' 'IP=':'INVALID FILTERS'⎕SIGNAL 11
     z
 }
