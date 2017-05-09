:namespace ynys
⍝ ## ←→ #.isolate

(⎕IO ⎕ML)←0 0

 AddServer←{⍺←⊢
     msg←messages'⍝- ' ⍝
     'server'≡Options'serverstatus':0⊃msg
     ''⍬≢0/¨⍵:1⊃msg
     addr ports←⍵
     {⎕ML←0 ⋄ 1∊∊∘∊⍨⍵}addr ports:2⊃msg
     z←Options'serverstatus' 'client'
     z←Init''
     ss←session
     id←(⍳⍴ports)+1+0⌈⌈/⊣/ss.procs
     ss.procs⍪←id,0,(⊂addr),⍪ports
     1:1
⍝ see notes
⍝- Session already started as server
⍝- Argument must be 'ip-address' (ip-ports)
⍝- IP-address nor IP-ports can be empty
 }

 Init←{⍺←⊢
     ⎕THIS.(⎕IO ⎕ML)←0
     new←newSession''
     ~new:⊢0 ⍝ already started
     (⍎⍕↓⎕NL 9).(⎕IO ⎕ML)←0
     here.iSpace←here←⎕THIS
     ss←here.session←⎕NS''
     z←setDefaults''
     op←options
     here.(signal←⎕SIGNAL/∘{(0⊃⎕DM)⎕EN})
     (dws dyalog)←'.dws' '.dyalog'
     ss.path←path←'\'{⍵,⍺~⊢/⍵}{⍵,'.'/⍨0∊⍴⍵}op.folder
     ss.orig←whoami''

     here.DRC←{⍵≠#:⍵                        ⍝ must exist
         9=⎕NC'#.DRC':#.DRC
         6::#.DRC ⋄ z←{}'DRC'#.⎕CY'conga'   ⍝ ⎕CY no result
     }op.drcref

     z←⎕SE.SALT.Load path,'APLProcess',dyalog
     z←⎕SE.SALT.Load path,'RPCServer',dyalog
     z←DRC.Init ⍬

     ss.homeport←7051                        ⍝ ⌽⊖'ISOL' ←→ 11×641
     hark←ss.homeport∘{
         0=rc←⊃RPCServer.Run'ISO'{(⍺,⍕⍵)⍵}ss.homeport:1
         10048=rc:⊢0⊣ss.homeport+←⍺
     }
     ss.listening←10 hark until⊢⍣op.listen⊢0  ⍝ now or never

     ss.win←'Windows'{⍺≡(⍴⍺)↑⍵}⊃⍬⍴#.⎕WG'APLVersion'
     ss.nextid←2⊃⎕AI
     (ss op).processors←processors⍣ss.win⊢op.processors

     ws←'"',ss.path,'RPCServer.dws"'
     load←' -Load=RPCIsolate'
     ports←ss.homeport+1+⍳ss.processors×op.processes
     procs←{⎕NEW APLProcess(ws ⍵)}∘{'-Port=',(⍕⍵),load}¨ports
     ss.procs←((1⊃⎕AI)+⍳⍴procs),procs,(⊂ss.orig),⍪ports ⍝ procid inst host port
     ss.assoc←0 2⍴0                                     ⍝ isoid procid
     z←'debug'setOption op.debug

     ss.started←sessionStart''     ⍝ last thing so we know
     1:⊢1 ⍝ newly started
⍝ Init if new session
⍝ ⍵ ?
⍝ ← 1 | 0 - 1=started, 0=already
 }

 Install←{⍺←⊢
     msg←⎕XSI∘{{⍵/⍨'⍝-'∘≡¨2⍴¨⍵}⎕NR⊃⊣/⍺}
     ~∨/'solate'⍷⎕WSID:⊢0⊃msg''
     path←{⍵/⍨⌽∨\⌽⍵∊'\/'}⎕WSID
     ~newSession'':⊢1⊃msg''
     0::(⎕IO⊃⎕DM)⎕SIGNAL ⎕EN
     z←{6::0 ⋄ {}'isolate'⎕SE.⎕CY ⎕WSID}''
     z←⎕SE.isolate.Options'folder'path
     z←{6::0 ⋄ {}'DRC'⎕SE.isolate.⎕CY'conga'}''
     z←⎕SE.isolate.(Options'drcref'DRC)
     z←⎕EX ##{(⍺.⎕DF ⍵)⊢⍕⍺}##.⎕DF ⎕NULL
     z←⎕SE.isolate.Init''
     1:⊢⎕SE.isolate
⍝ copies self to ⎕SE
⍝- Install must be run from "isolate" workspace
⍝- Isolates are already installed in this session
 }

 New←{⍺←⊢
     z←Init 0
     trapErr''::signal''
     shape←⍺⊣⍬ ⍝ number of isolates (shape of array) - default ⍬ (scalar)
     caller←callerSpace''
     source←caller argType ⍵
     ids←shape isolates source
     proxy←1/caller.⎕NS¨shape⍴proxySpace  ⍝ 1/ ensure non-scalar iso array.
     proxy.iSpace←iSpace
     proxy.(iD iCarus)←{⍵,suicide.New'cleanup'⍵}¨ids
     z←proxy.⎕DF⊂(⍕caller),'.[isolate]'
     z←1(700⌶)¨proxy
     1:shape⍴proxy
⍝ simulate isolate primitive: '¤'
⍝ see notes
 }

 Options←{⍺←⊢
     newSession'':setDefaults ⍵  ⍝ else Init has already run
     trapErr''::signal''
     res←options getset ⍵
     2=⍴⍵:⊢res←⊃setOption/⍵
     res
⍝ set or query single option
 }

 RunAsServer←{⍺←⊢
     msg←messages'⍝- ' ⍝
     ~newSession'':(0⊃msg),' ',options.serverstatus
     z←Options'serverstatus' 'server'
⍝     z←Options'keepalive' 1
     z←Init''
⍝     z←⍴(processors'')New'' ⍝ create and neglect one isolate per processor
     address ports←(session.orig)(∪⊢/session.procs) ⍝ notes
     info←(1 2⊃¨⊂msg),⍪address ports
     res←⊃,/⍕¨,(4 5 6 7⊃¨⊂msg),⍪address(⊃ports)(⍴ports)''
     ⎕←⍪,' ',⍪info(3⊃msg)res
     1:''

⍝ see notes
⍝- Session already started as
⍝- IP Address:
⍝- IP Ports:
⍝- Enter the following in another session, in one or more other machines:
⍝-       #.isolate.AddServer '
⍝- ' (
⍝- -⎕IO-⍳
⍝- )
 }

 Test←{⍺←⊢
     z←Init 0
     trapErr''::signal''

     test←#.⎕NS''       ⍝ test source is child of #
     test.(dfn←{⍺←⊢ ⋄ ⍺'dfn'⍵⊣'⍝ dfn'})
     f←{
         r←tnil      ⍝ tnil
         r←'tnil'
         r←tmon w    ⍝ tmon
         r←'tmon'w
         r←a tdya w  ⍝ tdya
         r←a'tdya'w
         r←{a}tfn w  ⍝ tfn
         r←⎕FX,⊂'r←a r' ⋄ r←a'tfn'w
     }
     z←test.⎕FX¨↓4 2⍴1↓⎕NR'f'
     caller←#.⎕NS''     ⍝ caller space is child of #

     testfn←caller.{
         S←#.⎕NS ⍺                  ⍝ source space
         z←'subns'S.⎕NS S           ⍝   add nested clone
         I←⍵.New S                  ⍝ isolate is child of caller and clone of source
                                    ⍝ NB. S remains an ordinary space throughout
         T←⍳~⍵.options.debug
         res←''
         res,←⊂0,{T::⎕EN ⋄ (S.tnil≡I.tnil)}0                            ⍝ tnil
         ⍝ correct syntax (all are forks)
         res,←⊂1,{T::⎕EN ⋄ (S.tmon≡I.tmon)'rarg'}0                      ⍝ tmon
         res,←⊂2,{T::⎕EN ⋄ 'larg'(S.tdya≡I.tdya)'rarg'}0                ⍝ tdya
         res,←⊂3,{T::⎕EN ⋄ (S.tfn≡I.tfn)'rarg'}0                        ⍝ tfn monad
         res,←⊂4,{T::⎕EN ⋄ 'larg'(S.tfn≡I.tfn)'rarg'}0                  ⍝ tfn dyad
         res,←⊂5,{T::⎕EN ⋄ (S.dfn≡I.dfn)'rarg'}0                        ⍝ dfn monad
         res,←⊂6,{T::⎕EN ⋄ 'larg'(S.dfn≡I.dfn)'rarg'}0                  ⍝ dfn dyad
         res,←⊂7,{T::⎕EN ⋄ (S.{'infix'⍵}≡I.{'infix'⍵})'rarg'}0          ⍝ infix monad
         res,←⊂8,{T::⎕EN ⋄ 'larg'(S.{⍺'infix'⍵}≡I.{⍺'infix'⍵})'rarg'}0  ⍝ infix dyad
         ⍝ incorrect syntax (valence) error
         res,←⊂9,{T::⎕EN ⋄ 2::1 ⋄ 0⊣'larg'I.tmon'rarg'}0                ⍝ tmon valence
         res,←⊂10,{T::⎕EN ⋄ 2::1 ⋄ 0⊣I.tdya'rarg'}0                     ⍝ tdya valence
         ⍝ new assignments
         res,←⊂11,{T::⎕EN ⋄ (S.scalar←⍵)≡(I.scalar←⍵)}5                 ⍝ scalar assign
         res,←⊂12,{T::⎕EN ⋄ (S.vector←⍵)≡(I.vector←⍵)}9?9               ⍝ vector assign
         res,←⊂13,{T::⎕EN ⋄ (S.string←⍵)≡(I.string←⍵)}'literal'         ⍝ string assign
         res,←⊂14,{T::⎕EN ⋄ (S.array←⍵)≡(I.array←⍵)}⍳9 9                ⍝ array assign
         ⍝ overwriting
         res,←⊂15,{T::⎕EN ⋄ (S.scalar←⍵)≡(I.scalar←⍵)}6                 ⍝ re-assign scalar
         res,←⊂16,{T::⎕EN ⋄ (S.vector←⍵)≡(I.vector←⍵)}19?19             ⍝ re-assign vector
         res,←⊂17,{T::⎕EN ⋄ (S.string←⍵)≡(I.string←⍵)}'longer literal'  ⍝ re-assign string
         res,←⊂18,{T::⎕EN ⋄ (S.array←⍵)≡(I.array←⍵)}⍳19 19              ⍝ re-assign array
         res,←⊂19,{T::⎕EN ⋄ 1≡S.(⎕THIS)≠I.(⎕THIS)}0                     ⍝ (expression)
         ⍝ indexing
         res,←⊂20,{T::⎕EN ⋄ S.(⎕IO←0)≡I.(⎕IO←0)}0                       ⍝ ensure
         res,←⊂21,{T::⎕EN ⋄ S.(⎕IO)≡I.(⎕IO)}0                           ⍝ ensure
         res,←⊂22,{T::⎕EN ⋄ S.vector[⍵]≡I.vector[⍵]}1 3 5               ⍝ get
         res,←⊂23,{T::⎕EN ⋄ S.array[⍵;⍵]≡I.array[⍵;⍵]}1 3 5             ⍝ both axes
         res,←⊂24,{T::⎕EN ⋄ S.array[;⍵]≡I.array[;⍵]}1 3 5               ⍝ elide axis
         res,←⊂25,{T::⎕EN ⋄ S.array[⍵;]≡I.array[⍵;]}1 3 5               ⍝ other axis
         res,←⊂26,{T::⎕EN ⋄ I.(⎕IO)≡I.(⎕IO←1)}0                         ⍝ switch origin
         res,←⊂27,{T::⎕EN ⋄ S.array[⍵;]≡I.array[⍵;]}1 3 5               ⍝ still same
         res,←⊂28,{T::⎕EN ⋄ ~S.(array[1 3 5;])≡I.(array[1 3 5;])}0      ⍝ differ internally
         ⍝ indexed assignment
         res,←⊂29,{T::⎕EN ⋄ '-'≡I.string[S.string⍳' ']←'-'}0            ⍝ ' ' → '-'
         res,←⊂30,{T::⎕EN ⋄ I.(~' '∊string)}0
         res,←⊂31,{T::⎕EN ⋄ ⍵≡I.array[⍵;1]←⍵}1 2 3
         res,←⊂32,{T::⎕EN ⋄ ⍵≡I.array[2;⍵]←⍵}1 2 3
         res,←⊂33,{T::⎕EN ⋄ ⍵≡I.{-#.⎕NL-9}⍵}1 2 3
         res
     }

     res←test testfn ⎕THIS
     res

⍝ ⍵    ?
⍝ try: p←{⎕IO←0 ⋄ ∧/1=⍵∨1+⍳⌊⍵*÷2}
⍝ see notes
 }

 and←{⍺←⊢
     ⍺⍺ ⍵:⍵⍵ ⍵
     0
⍝ left to right checking
⍝ only try ⍵⍵ if ⍺⍺ true
 }

 argType←{⍺←⊢
     trapErr''::signal''
     (0∊⍴)⍵:⍺.⎕NS''                                         ⍝ empty
     (0=≡)and{9=⎕NC'⍵'}⍵:⍵                                  ⍝ ns
     (1=≡)and(''≡0⍴⊢)⍵:{                                    ⍝ ws
         z←⎕NS''
         11::'WS NOT FOUND'⎕SIGNAL 11
         6::⍵         ⍝ value error implies copy ok
         z←{}z.⎕CY ⍵  ⍝ force value error → return ⍵
     }⍵
     (2=≡)and(''≡0⍴⊃)⍵:⍺.⎕NS↑⍵                              ⍝ nl
     ⎕SIGNAL 11
⍝ ⍺ caller
⍝ ⍵ arg to new - empty | space | namelist | string
⍝ ← :
⍝      arg | res
⍝      --- + ---
⍝    empty | empty ns
⍝    space | clone ns
⍝     list | ns containing named fns
⍝   string | validated wsid
 }

 callerSpace←{⍺←⊢
     ⍬⍴((0,⎕RSI)~0,⎕THIS,##,#,⍵),#
⍝ caller excluding this space and the main isolate method-space above it.
⍝ none of the code above is redundant. 2014-01-09
 }

 cleanup←{⍺←⊢
     (chrid port numid)←⍵.(chrid port numid)
     ⎕←⍪'.'/⍨options.debug
     (ns←⎕NS proxySpace).(iD iSpace)←⍵ iSpace   ⍝ recreate temp proxy
     z←ns.iSend{⍵(1('{#.⎕EX''',⍵,'''}')0)}chrid ⍝ expunge remote namespace
     z←DRC.Close chrid

     session.assoc{⍺⌿⍨⍵≠⊣/⍺}←numid              ⍝ remove numid from table
     1:
⍝ called by destructor of suicide class when isolate proxy disappears.
⍝ ⍵     space: chrid port mumid
⍝ numid unique numeric identifier for isolate
⍝ chrid identifies DRC client and isolate space in remote process
⍝ port  on which process is listening
 }

 connect←{⍺←⊢
     count←⍺
     (chrid host port data)←⍵
     close←{⎕DL 0.2⊣DRC.Close ⍵}
     rpt←{⍝ 0=⍬⍴⍵:⍵  ⍝ count or subsequent res - see below
         0≠⍬⍴res←DRC.Clt chrid host port:res⊣close chrid      ⍝ close
         0≠⍬⍴res←DRC.Send chrid data:res⊣close chrid          ⍝ on any
         0≠⍬⍴res←DRC.Wait 1⊃res:res⊣close chrid               ⍝ error
         res                                                ⍝ ok
     }
     count rpt until(0=⊣/)1
⍝ connect and send Initial payload
⍝ ⍺     attempts
⍝ ⍵     client-id ip-port data
⍝ data  function and argument
⍝ ←     final return from DRC
 }

 dateNo←{⍺←⊢
     ⊢2 ⎕NQ'.' 'DateToIDN'⍵
⍝
 }

 derv←{⍺←⊢
     ⍕{
         ⊃,/{
             0=≡⍵:⍵
             0∊⍴⍵:((''⍬ ⍵)⍳⊂⍵)⊃'''''' '⍬'⍵
⍝             1=≡⍵:'(',,∘')'⊃,/(⊂(' ',,⍵)⍳,⍵)⌷(⊂''' '' '),,⍵
             1=≡⍵:'(',,∘')'⊃,/,⍵
             ⊃,/'(',,∘')'∇¨⍵
         }⍵
     }⎕CR(f←⍺⍺)/'f'
⍝ ⍺⍺    derv
⍝ ←     executable text-string representation of ⍺⍺
⍝ sometimes adds too many parens but would need MUCH more analysis not to
⍝ handles scalar nums, ' ', '' & ⍬ but not arrays in general
⍝ e.g.
⍝       sec ← (⊢⊣)/∘⍳∘(15E5∘×)
⍝       sec derv 0
⍝ ((((⊢⊣)/)∘⍳)∘( 1500000 ∘×))
 }

 distrib←{⍺←⊢
     rd←{⊃(⌊0.5+⍵×⍺÷+/⍵){⍺⍺+⍵{(×⍵)×(⍳⍴⍺)∊(⍒|⍺)⍴⍨|⍵}⍺-+/⍺⍺}/⍺ ⍵}
     x←⍺-m←⍺⌊+/z←(⌈/-⊢)⍵
     (x rd 1⊣¨⍵)+m rd z
⍝ distribute
⍝ ⍺ scalar number to be allocated
⍝ ⍵ current allocation per bucket
⍝ ← allocation of new - shape = ⍴⍵ ; sum = ⍺
 }

 dix←{⍺←⊢
     r←(⍺⊣#).⎕NS''
     r⊣r.{⍎⍕'(',⍺,')←⍵'}/⍵
⍝ dictionary
⍝ [⍺]       container space for dictionary - dflt: #
⍝ ⍵         names values
⍝ names     ' '-del'd or nested list
⍝ values    conformable with names
⍝ e.g.      pt←(dix'⎕ml'3).⊂
 }

 errs←{⍺←⊢
     f←{
         1 'WS FULL'
         2 'SYNTAX ERROR'
         3 'INDEX ERROR'
         4 'RANK ERROR'
         5 'LENGTH ERROR'
         6 'VALUE ERROR'
         7 'FORMAT ERROR'
         10 'LIMIT ERROR'
         11 'DOMAIN ERROR'
         12 'HOLD ERROR'
         13 'OPTION ERROR'
         16 'NONCE ERROR'
         18 'FILE TIE ERROR'
         19 'FILE ACCESS ERROR'
         20 'FILE INDEX ERROR'
         21 'FILE FULL'
         22 'FILE NAME ERROR'
         23 'FILE DAMAGED'
         24 'FILE TIED'
         25 'FILE TIED REMOTELY'
         26 'FILE SYSTEM ERROR'
         28 'FILE SYSTEM NOT AVAILABLE'
         30 'FILE SYSTEM TIES USED UP'
         31 'FILE TIE QUOTA USED UP'
         32 'FILE NAME QUOTA USED UP'
         34 'FILE SYSTEM NO SPACE'
         35 'FILE ACCESS ERROR - CONVERTING FILE'
         38 'FILE COMPONENT DAMAGED'
         52 'FIELD CONTENTS RANK ERROR'
         53 'FIELD CONTENTS TOO MANY COLUMNS'
         54 'FIELD POSITION ERROR'
         55 'FIELD SIZE ERROR'
         56 'FIELD CONTENTS/TYPE MISMATCH'
         57 'FIELD TYPE/BEHAVIOUR UNRECOGNISED'
         58 'FIELD ATTRIBUTES RANK ERROR'
         59 'FIELD ATTRIBUTES LENGTH ERROR'
         60 'FULL-SCREEN ERROR'
         61 'KEY CODE UNRECOGNISED'
         62 'KEY CODE RANK ERROR'
         63 'KEY CODE TYPE ERROR'
         70 'FORMAT FILE ACCESS ERROR'
         71 'FORMAT FILE ERROR'
         72 'NO PIPES'
         76 'PROCESSOR TABLE FULL'
         84 'TRAP ERROR'
         90 'EXCEPTION'
         92 'TRANSLATION ERROR'
         99 'INTERNAL ERROR'
         1003 'INTERRUPT'
         1005 'EOF INTERRUPT'
         1006 'TIMEOUT'
         1007 'RESIZE'
         1008 'DEADLOCK'
     }
     ↑⍎¨1↓¯1↓⎕NR'f'
⍝
 }

 f01←{⍺←⊢
     op←{}
     z←⎕FX,⊂'op←{',⍵,'←⍺⍺ ⋄ ⍵.⎕NS''',⍵,'''}'
     ⍺⍺ op callerSpace''
⍝ possible alternative to fnSpace
 }

 fnSpace←{⍺←⊢

     trapErr''::signal''
     s←(callerSpace'').⎕NS''
     N←,⍵
     f←⍺⍺
     c←⎕CR'f'
     q←'#'≡⊃⊃c    ⍝ qualified
     c←⊃∘⌽⍣q⊢c    ⍝ remove qualification
     d←'{'≡⍬⍴c    ⍝ anon dfn
     t←1=≢⍴c      ⍝ tacit derv
     n←s.⎕FX{,↓⍣(1=≡⍵){N,'←',1↓,'⋄',⍵}⍣d⊢⍵}c
     ⍝ name anon dfn as N
     z←s.⎕FX(,↓N,'←{⍺←⊢ ⋄ ⍺',n,'⍵}')/⍨~(⊂n)∊N 0 1
     ⍝ if not N then N calls it
     z←s.⍎⍣t⊢N,'←',f derv⍣t⊢0
     1:s
⍝ ⍺⍺ fn
⍝ ⍵  required name for fn in space
⍝ ←  space child of caller containing fn as ⍵
⍝    for use by ephemeral isolates in llEach &c.

     trapErr''::signal''
     op←{}
     z←⎕FX,⊂'op←{⍵.',⍵,'←⍺⍺ ⋄ ⍵}'
     1:⍺⍺ op(callerSpace'').⎕NS''
⍝ possible alternative algorithm 2014-03-09
⍝ so far I can't find the reason I thought I needed
⍝ all the other stuff as this seems to do it ok.

 }

 getset←{⍺←⊢
     ⊢⍺.{vs←1∊2.1 9.1 9.2=⎕NC∘⊂
         0∊⍴⍵:1↓{⍵,⍪⍎¨⍵}'0',⎕NL-2.1 9.1 9.2
         1=≡⍵:⍎⍣(vs ⍵)⊢⍵
         2=⍴⍵:{⍎⍣z⊢(z←vs ⍺)/⍺,'←⍵'}/⍵
         ⎕SIGNAL 11
     }⍵
⍝ ⍺ target space
⍝ ⍵ '' | name | name value
⍝ called by both Options and setDefaults
 }

 isolates←{⍺←⊢
     ss←session
     num←×/shape←⍺     ⍝ new isos required
     source←⊂⍵         ⍝ no-op if ns else enclose wsid
     receive←⊂'#.RPCIsolate.receive'
     numid←(-2×⍳num)+ss.nextid←ss.nextid+2×num
⍝            2× ↑ as alternates used to call back to orig
     tgt←'#.'∘,¨chrid←('Iso',⍕)¨numid
     new←ss.assoc⍪←numid,⍪{(num distrib ¯1+⊢/⍵)⌿⊣/⍵},∘≢⌸(⊣/ss.procs),⊢/ss.assoc
     (host port)←↓⍉¯2↑⍤1⊢{(⊂(⊣/⍵)⍳⊢/new)⌷⍵}ss.procs ⍝ notes
     data←↓host,(⊂ss.orig),chrid,numid,tgt,ss.homeport,⍪port
     ids←{dix'host orig chrid numid tgt home port'⍵}¨data
     z←20 connect¨↓chrid,host,port,⍪↓receive,⍪↓source,proxySpace,⍪ids
     shape⍴ids
⍝ Start processes if needed. Create DRC client for each isolate.
⍝ Create id spaces to send and return for corresponding proxies.
 }

 ll←{⍺←⊢
     z←Init 0
     trapErr''::signal''
     s←⍺⍺ fnSpace'f'
     i←1⍴New s
     r←⊃⍺ i.f ⍵
     r
⍝ parallel
⍝ ⍺     [larg]
⍝ ⍺⍺    [fn to apply to or between [⍺] and or ⍵
⍝ ⍵     rarg
⍝ ←     result of running ⍺⍺ in a parallel process.
 }

 llEach←{⍺←⊢
     z←Init 0
     trapErr''::signal''
     n←⍺⍺ fnSpace'f'
     s←⍴⍺⊢¨⍵
     i←1/s New n  ⍝     non-scalar
     r←s⍴⍺ i.f ⍵
     r
⍝ parallel each
⍝ ⍺     [larg]
⍝ ⍺⍺    fn to apply to or between corresponding items of [⍺] and/or ⍵
⍝ ⍵     rarg
⍝ ←     results (which may be futures) of running ⍺⍺ in each
⍝       of one or more ephemeral isolates
 }

 llOuter←{⍺←'VALENCE ERROR'⎕SIGNAL 6
     z←Init 0
     trapErr''::signal''
     s←,⍴a←∪,⍺
     s,←⍴w←∪,⍵
     r←(⍉(⌽s)⍴⍉a)⍺⍺ llEach s⍴w
     1:r[a⍳⍺;w⍳⍵]
⍝ parallel outer product
⍝ ⍺  array
⍝ ⍺⍺ fn to apply between items of ⍺ and ⍵
⍝ ⍵  array
⍝ ←  assembly of results or futures from ⍺⍺ applied between
⍝    each unique ⍺-⍵ pair in a separate ephemeral isolate.
 }

 llRank←{⍺←⊢
     z←Init 0
     trapErr''::signal''
     mlr←⌽3⍴⌽⍵⍵,⍬
     m←⍵≡⍺ ⍵
     l r←-1↓r⌊|l+r×0>l←(⊂⍒m×⍳3)⌷mlr⌊r←3⍴(⍴⍴⍵),⍴⍴⍺⊣0
⍝ asm←{↑⍵⍴¨⍨↓1+⌽↑¯1+⌽∘⍴¨⍵} ⍝ redundant?
     w←⊂[r↑⍳⍴⍴⍵]⍵
     m:⍺⍺ llEach w
     (⊂[l↑⍳⍴⍴⍺]⍺)⍺⍺ llEach w
⍝ parallel rank
⍝ ⍺     [larg]
⍝ ⍺⍺    fn to apply to or between corresponding cells of [⍺] and/or ⍵
⍝ ⍵⍵    ranks (monadic, left, right) of cells of [⍺] and/or ⍵
⍝           to or between which to apply ⍺⍺
⍝ ⍵     rarg
⍝ ←     results or futures from running ⍺⍺ in each of one
⍝           or more ephemeral isolates
⍝ to emulate rank (⍤) completely it should mix (↑) the results.
⍝   This CANNOT BE DONE here as it dereferences the futures.
⍝ Phil Last ⍝ 2007-06-22 22:57
 }

 messages←{⍺←⊢
     {(+/∨\' '≠⌽⍵)↑¨↓⍵}⍵{(0,⍴,⍺)↓⍵⌿⍨>/⍺⍷⍵}⎕CR⊃1↓⎕XSI
⍝ attached to caller
 }

 minuscule←{⍺←⊢
     ('abcdefghijklmnopqrstuvwxyz',,⍵)[(⎕A,,⍵)⍳⍵]
⍝
 }

 newSession←{⍺←⊢
     0=⎕NC'session.started':1
     0.0001<|session.started-sessionStart''
⍝ The session is new if session.started is missing.
⍝ It needs to be restarted if session.started differs from the actual
⍝ start of the session by more than 8.64 seconds (1/10000 of a day)
⍝ that indicates that the ws was saved with the session space intact
 }

 notes←{⍺←⊢
⍝ Implementation notes
⍝
⍝ All contained in a single ns-tree - #.isolate - but aim to be relocatable as:
⍝
⍝       '#.isolate' #.myns.⎕CY 'isolate'
⍝
⍝   with the proviso that (atw 2013-10-18) scripts RPCIsolate, RPCServer and
⍝   APLProcess (all .dyalog) are in the folder given by {⍵/⍨⌽∨\⌽⍵∊'/\'}⎕WSID.
⍝ The isolate proxy returned by New is a container space created by ⎕NS having had
⍝   1∘(700⌶) applied to it.
⍝ The special functions are here named "syntax" and "execute" but are renamed and
⍝   copied to the proxy as required by 700⌶; pro-tem "iSyntax" & "iEvaluate".
⍝ There is a problem with other items in the proxy apart from refs. Functions or
⍝   arrays, global in the proxy, even if created before the call to 700⌶ cause a
⍝   recursive call to "syntax". The problem doesn't arise if they are within one
⍝   of the refs, whether the refs are internal (eg. iD) or point to external spaces
⍝   (eg. iCaller, iSpace).
⍝--------------------------------------------------
⍝ Tables:
⍝ -------
⍝
⍝ session.procs
⍝       stores process instances and contact
⍝       four columns:
⍝       proc-id inst(0) host-addr port-no
⍝ proc-id   next available integer when a process is started or made available
⍝ proc-inst instance of APLProcess if local or 0 placeholder if remote
⍝ host-addr IP-address of machine where is process
⍝ port-no   port-number of DRC listening
⍝
⍝ session.assoc
⍝       associates isolates with particular processes
⍝       two columns:
⍝       isolate-id proc-id
⍝ isolate-id    also within isolate.iD and names remote space as: 'IsoNNNN
⍝ proc-id       as session.procs
⍝---------------------------------------------------------
⍝ Data spaces:
⍝ ------------
⍝ session - created and populated by Init
⍝           contains all constants & variables except:
⍝ options - created and populated by setDefaults
⍝           contains all user options. Maintained by Options and setOption.
⍝--------------------------------------------------------------------
⍝ Functions:
⍝ ----------
⍝ New
⍝ simulate isolate primitive: '¤'
⍝
⍝ ⍵         source
⍝ source    code ∧/∨ data to be copied to isolate.
⍝           ref or namelist expected to be qualified relative to caller.
⍝ caller    space from which this fn was called.
⍝           when this is primitive both source & caller will be a matter of course.
⍝ ←         proxy
⍝ proxy     visible component of isolate.
⍝           anonymous space child of caller.
⍝           contains copies of "syntax" & "execute" as iSyntax & iEvaluate, and
⍝           refs - iSource to source, iCaller to the caller, iSpace to this space,
⍝           iCarus - an instance of the "suicide" class and iD - containing the DRC
⍝           id, port and the remote process id.
⍝ source    anonymous clone of the source, child of caller.
⍝           hidden component of isolate inaccessible except from proxy.
⍝           source of nameclass and syntax for "syntax"
⍝---------------------------------------------------------------------
⍝ Test
⍝ test all syntax and calling sequences
⍝
⍝ ⍵     value for Stop
⍝       Creates caller space to run tests in and test space as code source.
⍝ ←     vector of pairs of (test number)(result) where result should be
⍝       boolean 1=ok or ⎕EN for an error. (what about WS FULL)
⍝
⍝       Most tests compare the same operation applied to a clone of
⍝       the source ns and the remote process.
⍝------------------------------------------------------------------
⍝ Stop
⍝ stop at point of error in Test
⍝
⍝ ⍵     0 | 1 | other
⍝       0       causes erros to be trapped and ⎕EN returned for the test.
⍝       1       causes errors in test to halt execution.
⍝       other   no-op
⍝ ←     previous value or current for no-op
⍝------------------------------------------------------------------
⍝ syntax - copied as iSyntax to proxy
⍝ return name class and syntax code of supplied name
⍝
⍝ ⍵         simple name
⍝ ←         class, syntax
⍝ class     ⎕NC of name in source space.
⍝           We can only know the nameclass and syntax of the items as they
⍝           existed prior to being transferred to the remote process.
⍝ syntax    2⊥1= result ambivalent dyadic rarg 0 0
⍝---------------------------------------------------------------------------
⍝ execute - copied as iEvaluate to proxy
⍝ this is the biz
⍝ execute expression supplied to isolate
⍝
⍝ ⍺    | ⍵ - n is the syntax code supplied by "syntax"
⍝      |
⍝      | 2 n arrayname
⍝      | 2 n arrayname newvalue
⍝      | 2 n arrayname (PropertyArguments : Indexers IndexersSpecified)
⍝      | 2 n arrayname (PropertyArguments : Indexers IndexersSpecified
⍝      |                NewValue)
⍝      | 3 n niladname
⍝      | 3 n (expression)
⍝      | 3 n {monad} rarg
⍝ larg | 3 n {dyad} rarg
⍝      | 3 n monadname rarg
⍝ larg | 3 n dyadname rarg
⍝
⍝ RPCServer only permits a monadic fname and rarg to an existing function in
⍝ the remote ws so we give it '#.','RPCIsolate.execute' with nested vector
⍝   rarg as:
⍝ a | b      | c       | d    | e
⍝ 0 | array  |         |      |
⍝ 0 | nilad  |         |      |
⍝ 0 | (expr) |         |      |
⍝ 1 | monad  | rarg    |      |
⍝ 2 | larg   | dyad    | rarg |
⍝ 3 | array  | value   |      |
⍝ 4 | array  | indices | axes |
⍝ 5 | array  | indices | axes | value
⍝
⍝ If the expression causes an error that is trapped in the remote
⍝ process it is passed back as ⎕EN ⎕DM. execute converts the ⎕DM
⍝ into a CR delimited string and signals a ⎕EN error.
⍝-----------------------------------------------------------------
⍝ RunAsServer - run an isolate server on one machine
⍝               to be used by one or more others.
⍝
⍝ this must be the first use of the isolate namespace in the session.
⍝
⍝ output should be similar to:
⍝
⍝       isolate.RunAsServer''
⍝ Server 'ISO7051', listening on port 7051
⍝  Handler thread started: 1
⍝  Thread 1 is now handing server 'ISO7051'.
⍝
⍝  IP Address:  192.168.0.2
⍝  IP Ports:    7052 7053 7054 7055
⍝
⍝ Enter the following in another session, in one or more another machines:
⍝
⍝       #.isolate.AddServer '192.168.0.2' (7052-⎕IO-⍳4)
⍝
⍝------------------------------------
⍝ AddServer - use isolate server started in another machine
⍝
⍝       isolate.AddServer ipaddress (ipports)
⍝
⍝ the argument will be given as output from the session
⍝   in the server machine when started with:
⍝
⍝       isolate.RunAsServer''
⍝
⍝ Multiple servers can be started in different machines and used by one or
⍝   vice versa depending how many processors each machine has.
⍝
⍝ isolates can be used as usual with New, llEach &c. but expressions will be
⍝   evaluated in the other machine.
 }

 plStart←{⍺←⊢

     z←#.⎕FX{'å←{⍺←⊢' '0::2⊢(0⊃⎕dm)⎕signal⎕en'('⍺ ⍺⍺ ',⍵,'.llOuter ⍵')'}'}⍕##
     z←#.⎕FX{'ë←{⍺←⊢' '0::7⊢(0⊃⎕dm)⎕signal⎕en'('⍺ ⍺⍺ ',⍵,'.llEach ⍵')'}'}⍕##
     z←#.⎕FX{'ö←{⍺←⊢' '0::9⊢(0⊃⎕dm)⎕signal⎕en'('⍺ ⍺⍺ ',⍵,'.llRank ⍵⍵⊢⍵')'}'}⍕##

     z←#.⎕FX{'ø←{⍺←⊢' '0::10⊢(0⊃⎕dm)⎕signal⎕en'('⍺ ',⍵,'.New ⍵')'}'}⍕##

     #.yy←⎕THIS

⍝    ä å æ è é ê ë ð ö ø ü þ
     z←'äåæèéêëðöøüþ'⎕PFKEY¨13+⍳12                     ⍝ SF1-SF12 diacritics

     0=#.⎕NC'acre':⊢1

     #.(ut cb)←#.acre.acre.(UT CB)
     ⎕←#.ut.bx'Beware - 64 bit Version 14'

     pf←#.ut.pf

     z←'<ED>←{⍺←⊢<ER><ER>⍝<ER> }<UC>'pf 2              ⍝ F2 ed←{⍺←⊢ ⋄ ⍝ ...
     z←'⎕nl¨⍳11'pf 3                                   ⍝ F3 items

     z←'''cutback''⎕signal 1'pf 5                      ⍝ F5 cutback
     z←'⎕xsi,⎕lc,⍪⎕lc⊃∘{⍵↑⍨1⌈≢⍵}∘⎕nr¨⎕xsi'pf 6         ⍝ F6 state
     z←'→⎕lc'pf 7                                      ⍝ F7 restart

     1:⊢1

 }

 prepareWS←{⍺←⊢
     ~newSession'':'reload ws first'

     inst←⍵ ⍝ #.acre_Isolate
     dat←inst.Data''
     cb←dat._Class
     ut←cb.UT
     fo←cb.FO
     folder←¯1↓path←dat.codepath
     (lib proj)←ut.pn folder
     desk←⊃ut.pn ¯1↓lib            ⍝ parent of project library
     target←desk,proj
     space←2↓dat.spacepath
     z←{0::0 ⋄ fo.DeleteFolder ut.ep⊂target}0
     z←{0::0 ⋄ fo.DeleteFile ut.ep⊂target,'.zip'}0
     z←fo.CopyFolder ut.ep folder target
     (nss cls)←{(ut.nt ⍵)(⍎¨⍵ ut.li 9.4)}dat._Space
     src←(#.ut.js¨nss),⎕SRC¨cls
     nms←(target,'\')∘,¨(ut.nn∘ut.df¨nss,cls),¨⊂'.dyalog'
     z←src{(⎕UCS'UTF-8'⎕UCS 2⌽⊃,/ut.(⊂CR LF),¨⍺)#.ut.wf ⍵}¨nms
     par←ut.df¨(nss,cls).##
     dat←ut←cb←fo←0
     nss[]←cls[]←0
     inst←inst.Close''
     z←#.(⎕EX ⎕NL⍳10) ⍝ !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     z←{{(⍎⍺).⎕FIX ⍵}/⍺}/⌽0,(⊂⍋≢¨par)⌷par{⍺ ⍵}¨src
     #.⎕WSID←target,'\',proj
     #.(⎕LX ⎕IO ⎕ML)←'' 1 1
     ↑')RESET' ')SAVE'
⍝ Convert from acre project with ns-tree containing individual
⍝ fns & ops to flat write-once ns-scripts filed & ⎕FIXed in situ.
 }

 processors←{⍺←⊢
     ⎕USING←''
     System.Environment.ProcessorCount
⍝
 }

 sessionStart←{⍺←⊢
     24 60 60 1000{(dateNo ⍵)-(⍺-⍺⍺⊥3↓⍵)÷×/⍺⍺}/(2⊃⎕AI)⎕TS
⍝ diff twixt ⎕ts and ⎕ai
⍝ ← number of days and the decimal part thereof after the start of the last
⍝   day of the penultimate year of the nineteenth century: 1899-12-31 00.00
⍝ immune to system clock change as both rely on that.
 }

 setDefaults←{⍺←⊢
     here←⎕THIS
     new←0=here.⎕NC⊂'options'     ⍝ set defaults only once
     z←{here.options←⎕NS''
         options.debug←0          ⍝ cut back on error
         options.drcref←#         ⍝ copy into # if # and missing
                                  ⍝ if not # then where it is
         options.folder←{⍵/⍨⌽∨\⌽⍵∊'/\'}⎕WSID
         options.listen←1         ⍝ can isolate call back to ws
         options.processes←1      ⍝ processes per processor
         options.processors←4     ⍝ windows will correct this
         options.serverstatus←'client'
         1:1
     }⍣new⊢0
     0::⎕SIGNAL ⎕EN
     ⊢options getset ⍵
⍝ called by Options before Init runs and by Init when it does.
⍝ set default options and permit user changes
⍝ but leave Init to apply them.
 }

 setOption←{⍺←⊢

     ⍺≡'debug':{        ⍝ set trap function on or off
         ⎕THIS.(trapErr←(⍵↓0)∘⊣)
         ⍵
     }⍵

     ⍺≡'processors':{   ⍝ we don't know how to tell except in windows
         ~session.win:⊢session.processors←⍵    ⍝ ~win: set in session
         options.processors←session.processors ⍝ win: reset as session
         'Immutable in Windows'⎕SIGNAL 11
     }⍵
     ⍵

⍝ by the time this runs the var in options named as ⍺
⍝   has ready been set to ⍵ in Options
⍝   so this only covers the special cases.
 }

 until←{⍺←⊢ ⋄ f←⍺⍺ ⋄ t←⍵⍵
     ⍵≡⍺ ⍵:f⍣(t⊣)⍵
     ⍺{ ⍝ keep recursion local
         (⍺-1)∘∇⍣((⍺>1)>t z)⊢z←f ⍵
     }⍵
⍝ ⍺     [max]
⍝ ⍺⍺    monadic fn on arg
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

 whoami←{⍺←⊢
     ~∘' '{(1+⍵⍳':')↓⍵}⊃{⍵⌿⍨∨/'ipv4 address'⍷minuscule↑⍵}⎕CMD'ipconfig'
⍝
 }

:endnamespace
