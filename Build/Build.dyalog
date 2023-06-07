 Build;file;ver;src;t;version;rev;path;root;buildver;date;db;glyph;nr;name;warn
⍝ As part of running isolate.dbuild, tweak the workspace a bit:
⍝    Build cover-functions in #.isolate
⍝    Insert isolate.Version to include GIT last commit date

 version←'1.3' ⍝ base version
 db←⊃⎕RSI ⍝ Ref to DyalogBuild environment
 root←db.path  
 warn←''

 ⍝ Build cover functions with typeable names in #.isolate
 :For glyph name :In ('II' 'll')('IIÐ' 'llKey')('IIö' 'llRank')('IÏ' 'llEach')('o_II' 'llOuter')
     :If 0∊⍴nr←#.⎕NR glyph
         11 ⎕SIGNAL⍨'isolate Build: Could not find #.',glyph
     :EndIf
     nr[1]←⊂name,'←'((¯1∘+⍳⍨)↓⊢)1⊃nr
     :If 0=1↑0⍴#.isolate.⎕FX nr
         11 ⎕SIGNAL⍨'Unable to define cover function #.isolate.',name
     :EndIf
 :EndFor
 :Trap 0
     :If 0≠⍴date←⍕{0::'' ⋄ ⊃⎕CMD'git -C "',⍵,'" log -1 --format=%ci'}root
     :OrIf 0≠⍴date←⍕{0::'' ⋄ ⊃⎕CMD'cd "',⍵,'" && svn info | sed -n "s/^Last Changed Date: \\(.*\\) (.*/\\1/p"'}root
         date←' (',date,')'
     :Else
        ⍝ MBaas: signalling an error means build-failure -> only do that when we build for production, but be tolerant when we build for tests
         :If 2=db.⎕NC'prod'
         :AndIf db.prod
         :andif 'DTEST'≢2⎕nq#'GetEnvironment' 'BUILDINFO'
             'isolate Build: Unable to get GIT last commit date - isolate. Version not set!'⎕SIGNAL 11
         :Else
             warn←'isolate Build: Unable to get GIT last commit date ! '  
             date←''
         :EndIf
     :EndIf
 :Else
     warn'isolate Build: trapped error getting last commit date:',(⎕JSON ⎕OPT'Compact' 0)⎕DMX
     date←''
 :EndTrap

 ver←version,date ⍝ Join base version and git last commit date
 isolate.Version←'Version ',ver,' built at ',,'ZI4,<->,ZI2,<->,ZI2,< >,ZI2,<:>,ZI2,<:>,ZI2'⎕FMT 1 6⍴⎕TS
 ('Type' 'W')db.Log warn
 ('Type' 'I')db.Log'isolate.Version set to: ',isolate.Version
