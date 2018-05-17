 r←Build;file;ver;src;t;version;rev;path;root;buildver;date
⍝ As part of running isolate.dbuild, tweak the workspace a bit:
⍝    Build cover-functions in # and #.isolate (see function "BuildCovers")
⍝    Insert isolate.Version to include GIT last commit date

 r←''
 version←'1.1' ⍝ base version
 root←⌽{(⌊/⍵⍳'/\')↓⍵}⌽⎕WSID

 buildver←'16.0' ⍝ Use v16.0 or later to build
 :If buildver≢(≢buildver)↑2⊃'.'⎕WG'APLVersion'
     ⎕←'*** WARNING - Production builds should be run using Dyalog ',buildver,' ***'
 :EndIf

 :If 0≠⍴date←⍕{0::'' ⋄ ⎕CMD'git -C "',⍵,'" log -1 --format=%cI'}root
 :OrIf 0≠⍴date←⍕{0::'' ⋄ ⎕CMD'svn info --show-item last-changed-date "',⍵,'"'}root
     date←' (',(date~' '),')'
 :Else
     ⎕←'NB: Unable to get GIT last commit date!'
 :EndIf

 ver←version,date ⍝ Join base version and git last commit date
 ⎕←'isolate.Version set to:'
 ⎕←isolate.Version←'Version ',ver,' built at ',,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 1 6⍴⎕TS
