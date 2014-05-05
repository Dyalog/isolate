:namespace ynys  
⍝ Version edited by Morten
⍝ ## ←→ #.isolate

    (⎕IO ⎕ML)←0 1

      AddServer←{⍺←⊢
          msg←messages'⍝- ' ⍝
          'server'≡Config'status':0⊃msg
          ''⍬≢0/¨⍵:1⊃msg
          (addr ports)←⍵
          {1∊∊∘∊⍨⍵⊣⎕ML←0}addr ports:2⊃msg
          z←Config'status' 'client'
          z←Init''
          ss←session
          id←(⍳≢ports)+1+0⌈⌈/⊣/ss.procs
          ss.procs⍪←id,0,(⊂addr),⍪ports
          1:1
⍝ see notes
⍝- Session already started as server
⍝- Argument must be 'ip-address' (ip-ports)
⍝- IP-address nor IP-ports can be empty
      }

      Config←{⍺←⊢
          newSession'':setDefaults ⍵  ⍝ else Init has already run
          trapErr''::signal''
          res←options getset ⍵
          1=≡⍵:⊢res
          res⊣setOption/⍵
     
⍝ set or query single option
⍝ ⍵         '' | name | name value
⍝ name      one of params defined in setDefaults
⍝ value     new value for param
⍝ ←         ⍵:''            : table of all names and values
⍝           ⍵:name          : value
⍝           ⍵:name value    : old value having set new in param
      }

      Init←{⍺←⊢
          ⎕THIS.⎕IO←0
          new←newSession''
          ~new:⊢0                                 ⍝ 0 - already started
          (⍎⍕↓⎕NL 9).⎕IO←0
          here.iSpace←here←⎕THIS
          z←here.(proxyClone←⎕NS'').⎕FX¨proxySpace.(⎕CR¨↓⎕NL 3)
          ss←here.session←⎕NS''
          z←setDefaults''
          op←options
          ##.DRC←here.DRC←getDRC op.drc
          z←DRC.Init ⍬
          here.(signal←⎕SIGNAL/∘{(0⊃⎕DM)⎕EN})
          ss.orig←whoami''
          listen←(ss.homeport←7051)∘localServer   ⍝ ⌽⊖'ISOL'
          ss.listen←10 listen until⊢⍣op.listen⊢0  ⍝ "calls back"?
     
          ss.nextid←2⊃⎕AI                         ⍝ isolate id
          z←⎕TPUT ss.callback←1+(2*15)|+/⎕AI      ⍝ queue for calls back
          z←⎕TPUT ss.assockey←1+ss.callback       ⍝ queue for assoc and procs
     
          ((ws rt)iso)←op.(workspace runtime)'-isolate=isolate'
          ws←1⌽'""',addWSpath ws~'"'   ⍝ if no path ('\/')
          ports←ss.homeport+1+⍳op.(processors×processes)
     
          procs←{⎕NEW ##.APLProcess(ws ⍵ rt)}∘{'-Port=',⍕⍵,iso}¨ports
          ss.procs←((1⊃⎕AI)+⍳⍴procs),procs,(⊂ss.orig),⍪ports
          ss.assoc←dix'proc iso busy inuse err msg'(6⍴⍬ ⍬)
     
          z←'debug'setOption op.debug
     
          ss.started←sessionStart''               ⍝ last thing so we know
          1:⊢1                                    ⍝ 1 - newly started
⍝ Init if new ss
⍝ ⍵ ?
⍝ ← 1 | 0 - 1=started, 0=already
      }

      New←{⍺←⊢
          z←Init 0
          trapErr''::signal''
          shape←⍺⊣⍬ ⍝ number of isolates (shape of array) - default ⍬ (scalar)
          caller←callerSpace''
          source←caller argType ⍵
          ids←shape isolates source
          proxy←1/caller.⎕NS¨shape⍴proxyClone  ⍝ 1/ ensure non-scalar iso array.
          proxy.iSpace←iSpace
          proxy.(iD iCarus)←{⍵,suicide.New'cleanup'⍵}¨ids
          z←proxy.⎕DF⊂(⍕caller),'.[isolate]'
          z←1(700⌶)¨proxy
          1:shape⍴proxy
⍝ simulate isolate primitive: '¤'
⍝ see notes
      }

      OS←{⍺←⊢
          ⍵{⍺≡(⍴⍺)↑⍵}⊃#.⎕WG'APLVersion'
⍝ ⍵ 'Win' 'Lin' 'AIX' &.
      }

      StartServer←{⍺←⊢
          msg←messages'⍝- ' ⍝
          ~newSession'':(0⊃msg),' ',options.status
          z←Config'status' 'server'
          z←Init''
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

      addWSpath←{⍺←⊢
          ∨/'/\'∊ws←⍵:⊢ws       ⍝ assume extant path is good
          dir←2 ⎕NQ'.' 'GetEnvironment' 'dyalog'
          sep←⊃'/\'∩dir
          dir,←sep~⊢/dir        ⍝ append sep if needs
          dir,'WS',sep,ws       ⍝ WS folder
⍝ add ...dyalog/WS/   to ws if no path spec'd
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
          ⍬⍴((0,⎕RSI)~0,⎕THIS,##,⍵),#
⍝ caller excluding this space and the main isolate method-space above it.
⍝ none of the code above is redundant. 2014-01-09
      }

      cleanup←{⍺←⊢
          trapErr''::signal''
          (chrid port numid)←⍵.(chrid port numid)
          ⎕←⍪'.'/⍨options.debug
          (ns←⎕NS proxyClone).(iD iSpace)←⍵ iSpace    ⍝ recreate temp proxy
          rem←{session.assoc.(iso proc busy inuse err msg⌿⍨←⊂iso≠⍵)}
          11::rem numid                               ⍝ DRC reported errors
          z←ns.iSend{⍵(1('{#.⎕EX''',⍵,'''}')0)}chrid  ⍝ expunge remote namespace
          z←DRC.Close chrid
          rem numid                                   ⍝ remove numid from table
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

      decode←{⍺←⊢
          where←⍺
          home←where=#  ⍝ would be #.IsoNNNNN for outward call
          x←where.⍎
          (a b c d e)←5↑⍵
          tok←{⎕TGET session.callback}⍣home⊢0  ⍝ one at a time please!
          res←{0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN⊣{⎕TPUT session.callback}⍣home⊢0
              (a0 a1 a2 a3 a4 a5)←a=0 1 2 3 4 5
              a0:x b
              a1:(x b)c
              a2:b(x c)d
              a3:c⊢b{x ⍺,'←⍵'}c
              (i j)←c d+where.⎕IO
              a4:⍎'i(j where.{⊢⍺⌷[⍺⍺]',b,'})0'
              a5:⍎'i(j where.{⊢(⍺⌷[⍺⍺]',b,')←⍵})e'
          }0
          tok←{⎕TPUT session.callback}⍣home⊢0  ⍝ next please!
          res
⍝ ⍺ target space
⍝ ⍵ encoded list
⍝   decode list and execute requisite syntax in target.
⍝ see #.isolate.notes
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

      easy←{⍺←⊢
          expose ⎕THIS(↓##.⎕NL 3 4)
⍝ expose public functions in root
      }

      encode←{⍺←⊢
          la←(⍵≡⍺ ⍵)↓⊂⍺⊣0  ⍝ enclosed if supplied
          ra←(⊢⍴⍨1~⍨⍴)3↓⍵  ⍝  - empty if not
          (x nc s)←3⍴⍵
          pargs←{⍺←⊢       ⍝ analyse [PropertyArguments]
              ra←⍵
              9≠⎕NC'ra':ra                  ⍝ not a space
              nms←'Indexers' 'IndexersSpecified' 'IndexOrigin' 'NewValue'
              3>+/nms/⍨←∧\2=⌊ra.⎕NC nms:ra  ⍝ not a [PropertyArgs]
              n←ra.⍎¨nms
              (0⊃n)←(-2⊃n)+(0,1⊃n)/0,0⊃n     ⍝ 0+indices sans ⎕NULLs
              (1⊃n)←{⍵/⍳⍴⍵}1⊃n               ⍝ 0+axes
              ((⍴n)↑1 1 0)/n
          }
          args←la,(⊂x),pargs ra
          code←nc{6|0(3 2)(3 3)(2 2)(2 3)(2 4)⍳⊂⍺,⍵}⍴args
          code,args
⍝ called in ##.proxyClone.iEvaluate - here because its inverse has to be
⍝ ⍺ larg to iEvaluate - larg to isolate.dyad
⍝ ⍵ rarg to iEvaluate - name class syntax [rarg | PropertyArguments]
⍝   creates list that encodes syntax and includes arguments
⍝ see #.isolate.notes
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

      execute←{⍺←⊢
          (name data)←⍵
          space←#.⍎name
          space decode data
⍝ this is the function called by RPCServer.Process
⍝ ⍵     name data
⍝ data  list created by encode below.
⍝ ←     result or assignment of decoded ⍵
      }

      expose←{⍺←⊢
          (src snm)←⍵
          (tgt tnm)←⍺⊣#             ⍝ dflt target  - #
          tnm←snm∘⊣⍣(tgt≡tnm)⊢tnm   ⍝ dflt tnames  - snames
          ss←⍕src
          trap←'⋄0::(⊃⍬⍴⎕dm)⎕signal⎕en⋄'
          fix←{
              (aa ww)←2↑(0 2⊃src.⎕AT ⍵)⍴'⍺⍺' '⍵⍵'
⍝         tgt.⎕FX(⍺,'←{⍺←⊢')trap('⍵≡⍺⍵:',aa,ss,'.',⍵,ww,'⊢⍵')('⍺(',aa,ss,'.',⍵,ww,')⍵')'}'
              tgt.⎕FX,⊂⍺,'←{⍺←⊢',trap,'⍵≡⍺⍵:',aa,ss,'.',⍵,ww,'⊢⍵⋄⍺(',aa,ss,'.',⍵,ww,')⍵}'
          }
          z←tnm fix¨snm
          1:1
⍝ expose public functions and operators elsewhere
⍝ ⍵         (src) (snms)
⍝ ⍺         [tgt  [tnms] ]
⍝ src       ref containing fns to run
⍝ snms      names of fns & ops therein
⍝ tgt       ref to contain fns to call - dflt #
⍝ tnms      corresponding names in tgt - dflt snms
⍝ tgt.tnm←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍺(   #.src.snm   )⍵} ⍝ function
⍝ tgt.tnm←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍺(⍺⍺ #.src.snm   )⍵} ⍝ adverb
⍝ tgt.tnm←{⍺←⊢ ⋄ 0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN ⋄ ⍺(⍺⍺ #.src.snm ⍵⍵)⍵} ⍝ conjunction
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
   
      getDefaultWS←{
          ∨/⍵⍷⎕WSID:⎕WSID
          ⍵ ⍝ ⍵ is normally 'isolate'
⍝ use exact current ws if looks like an isolate development ws
      }

      getDRC←{⍺←⊢
          ⍵≠#:⍵                          ⍝ if not # it must exist
          9=#.⎕NC'DRC':#.DRC             ⍝ in # already?
          ws←addWSpath'conga'            ⍝ dyalog WS
          0::⊢#.DRC                      ⍝ this is result
          z←{}'DRC'#.⎕CY ws              ⍝ ⎕CY no result
⍝
      }

      getset←{⍺←⊢
          ⊢⍺.{
              0∊⍴⍵:1↓{⍵,⍪⍎¨⍵}'0',⎕NL-2.1 9.1 9.2
              one←1=≡⍵
              two←one<2=≢⍵
              nam←⊃⍣two⊢⍵
              ~1∊2.1 9.1 9.2=⎕NC⊂nam:('Unknown parameter: ',nam)⎕SIGNAL 11
              old←⍎nam
              one:old
              two:old⊣{⍎⍺,'←⍵'}/⍵
              ⎕SIGNAL 11
          }⍵
⍝ ⍺ target space
⍝ ⍵ '' | name | name value
⍝ ← (⍵:'') all names and values
⍝   (⍵:name) value
⍝   (⍵:name value) value re-assigned
⍝ called by both Config and setDefaults
      }

      isoStart←{⍺←⊢
     
          iso←'isolate'
          parm←2 ⎕NQ'.' 'GetEnvironment'iso
          parm≢iso:shy←1
     
⍝     0::{
⍝         'R'∊⊃⊢/'#'⎕WG'APLVersion':{
⍝             Caption←'Isolate Startup Failure'
⍝             Text←⎕DM
⍝             ⎕DQ'Msg'⎕WC'MsgBox'Caption Text'Error'
⍝         }''
⍝         (⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
⍝     }⍬
     
          f00←{
              'R'∊⊃⊢/'#'⎕WG'APLVersion':{
                  Caption←'Isolate Startup Failure'
                  Text←⎕DM
                  ⎕DQ'Msg'⎕WC'MsgBox'Caption Text'Error'
              }''
              (⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
          }
          ⎕TRAP←0 'C' 'f00⍬'
     
          ##.DRC←⎕THIS.DRC←getDRC #
          ##.RPCServer.Boot
⍝ start as process if loaded with "isolate=isolate" in commandline
      }

      isolates←{⍺←⊢
          ss←session
          num←×/shape←⍺     ⍝ new isos required
          source←⊂⍵         ⍝ no-op if ns else enclose wsid
          receive←⊂(⍕⎕THIS),'.receive'
          numid←(-2×⍳num)+ss.nextid←ss.nextid+2×num
⍝            2× ↑ as alternates used to call back to orig
          tgt←'#.'∘,¨chrid←('Iso',⍕)¨numid
     
⍝ ss.procs contains all proc ids; assoc.(busy/proc) only those with busy isos
          z←⎕TGET ss.assockey         ⍝ see Init
          procs←{(num distrib ¯1+⊢/⍵)⌿⊣/⍵},∘≢⌸(⊣/ss.procs),ss.assoc.(busy/proc)
          ss.assoc.(iso proc inuse busy err msg),←num⍴¨numid procs 1 1 0 0
          z←⎕TPUT ss.assockey
     
          (host port)←↓⍉¯2↑⍤1⊢{(⊂(⊣/⍵)⍳procs)⌷⍵}ss.procs  ⍝ notes
          data←↓host,(⊂ss.orig),chrid,numid,tgt,ss.homeport,⍪port
          ids←{dix'host orig chrid numid tgt home port'⍵}¨data
          z←20 connect¨↓chrid,host,port,⍪↓receive,⍪↓source,ss.listen,⍪ids
          shape⍴ids
⍝ Create DRC client for each isolate.
⍝ Create id spaces to send and return for corresponding proxies.
      }

      ll←{⍺←⊢
          z←Init 0
          trapErr''::signal''
          s←⍺⍺ fnSpace'f'
     
          i←New s
          ⍵≡⍺ ⍵:i.f ⍵    ⍝ monad
          ⍺ i.f ⍵        ⍝ dyad
     
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
          i←1/s New n    ⍝ non-scalar
          ⍵≡⍺ ⍵:s⍴i.f ⍵  ⍝ monad
          s⍴⍺ i.f ⍵      ⍝ dyad
     
⍝ parallel each
⍝ ⍺     [larg]
⍝ ⍺⍺    fn to apply to or between corresponding items of [⍺] and/or ⍵
⍝ ⍵     rarg
⍝ ←     results (which may be futures) of running ⍺⍺ in each
⍝       of one or more ephemeral isolates
      }

      llKey←{⍺←⊢                                    ⍝ key operator
          z←Init 0
          trapErr''::signal''
          ⍵≡⍺ ⍵:⍵ ∇(callerSpace'').⍳≢⍵
     
          j←⍋i←{(∪⍳⊢)↓⍣(≢1↓⍴⍵)⊢⍵}⍺
          (⊂⍤¯1⊢((⍳⍴i)=i⍳i)⌿⍺)⍺⍺ llEach(2≠/¯1,i[j])⊂[0](⊂j)⌷⍵
     
⍝ parallel key : ⍺ ⍺⍺ llkey ⍵
⍝ ⍺     [larg] - array (≢⍺) ≡ ≢⍵
⍝       ⍺⍺ llKey ⍵ ←→ ⍵ ⍺⍺ llKey ⍳≢⍵
⍝ ⍺⍺    fn to apply between each unique major cell of ⍺ and
⍝       the corresponding subarray of ⍵ ; or to the latter.
⍝ ⍵     rarg - array
⍝ ←     futures array - results of each application of ⍺⍺
⍝ to emulate primitive key completely it should mix (↑) the results.
⍝   This CANNOT BE DONE here as it would dereference the futures.
⍝ Phil Last ⍝ 2007-06-22 22:57
      }

      llOuter←{⍺←'VALENCE ERROR'⎕SIGNAL 6
          z←Init 0
          trapErr''::signal''
          (⍉(⌽s)⍴⍉⍺)⍺⍺ llEach ⍵⍴⍨s←(⍴⍺),⍴⍵
     
⍝     s←,⍴a←∪,⍺
⍝     s,←⍴w←∪,⍵
⍝     r←(⍉(⌽s)⍴⍉a)⍺⍺ llEach s⍴w
⍝     1:r[a⍳⍺;w⍳⍵]
     
⍝ parallel outer product
⍝ ⍺  array
⍝ ⍺⍺ fn to apply between items of ⍺ and ⍵
⍝ ⍵  array
⍝ ←  aray of futures from ⍺⍺ applied between
⍝    each pair of items selected from ⍺ and ⍵
      }

      llRank←{⍺←⊢
          z←Init 0
          trapErr''::signal''
          mlr←⌽3⍴⌽⍵⍵,⍬
          m←⍵≡⍺ ⍵
          l r←-1↓r⌊|l+r×0>l←(⊂⍒m×⍳3)⌷mlr⌊r←3⍴(⍴⍴⍵),⍴⍴⍺⊣0
          w←⊂[r↑⍳⍴⍴⍵]⍵
          m:⍺⍺ llEach w              ⍝ monad
          (⊂[l↑⍳⍴⍴⍺]⍺)⍺⍺ llEach w    ⍝ dyad
⍝ parallel rank
⍝ ⍺     [larg]
⍝ ⍺⍺    fn to apply to or between corresponding cells of [⍺] and/or ⍵
⍝ ⍵⍵    ranks (monadic, left, right) of cells of [⍺] and/or ⍵
⍝           to or between which to apply ⍺⍺
⍝ ⍵     rarg
⍝ ←     results or futures from running ⍺⍺ in each of one
⍝           or more ephemeral isolates
⍝ to emulate primitive rank completely it should mix (↑) the results.
⍝   This CANNOT BE DONE here as it dereferences the futures.
⍝ Phil Last ⍝ 2007-06-22 22:57
      }

      localServer←{⍺←⊢
          0=rc←⊃1 1 ##.RPCServer.Run'ISO'{(⍺,⍕⍵)⍵}session.homeport:1
          10048=rc:⊢0⊣session.homeport+←⍺
⍝ 10048 WinSock Error attempt to use listening socket already in use.
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
          {(,⍵)/⍨,⌽∨\⌽⍵≠' '}(⎕UCS 13),'⍝ '{(0,⍴,⍺)↓⍵⌿⍨>/⍺⍷⍵}⎕CR⊃⎕SI
⍝ Implementation notes
⍝
⍝ All contained in a single ns-tree - #.isolate - but aim to be relocatable as:
⍝
⍝       '#.isolate' #.myns.⎕CY 'isolate'
⍝
⍝ The isolate proxy returned by New is a container space created by ⎕NS in the caller having had 1∘(700⌶) applied to it.
⍝ It contains the special functions: "iSyntax" & "iEvaluate", additional function iSend and a number of namespaces.
⍝
⍝ Data spaces:
⍝
⍝ session - created and populated by Init, it contains all constants & variables except those in:
⍝ options - created and populated by setDefaults, it contains all user options. Maintained by Config.
⍝
⍝ Tables:
⍝
⍝ session.procs
⍝       stores process instances and contact details in four columns:
⍝           proc-id; proc-inst(0); host-addr; port-no
⍝ proc-id   integer incremented from zero when a process is started or made available.
⍝ proc-inst instance of APLProcess if local or 0 placeholder if remote
⍝ host-addr IP-address of machine where is process
⍝ port-no   port-number on which process listening; incremented from first available multiple of 7051
⍝
⍝ session.assoc
⍝       associates isolates with particular processes in two columns:
⍝             isolate-id; proc-id
⍝ isolate-id  integer incremented from "random" seed; also in iD namespace in proxy and sent to isolate; names remote space as: 'IsoNNNN'
⍝ proc-id     as session.procs
⍝
⍝
⍝ Functions:
⍝ --
⍝ StartServer                                             r←StartServer ⍵
⍝ Run an isolate server on one machine to be used by one or more others.
⍝ This must be the first use of the isolate namespace in the session.
⍝   Output should be similar to:
⍝ ,------------------------------------------------------------------------,
⍝ |      isolate.StartServer''                                             |
⍝ |Server 'ISO7051', listening on port 7051                                |
⍝ | Handler thread started: 1                                              |
⍝ | Thread 1 is now handing server 'ISO7051'.                              |
⍝ |                                                                        |
⍝ | IP Address:  192.168.0.2                                               |
⍝ | IP Ports:    7052 7053 7054 7055                                       |
⍝ |                                                                        |
⍝ |Enter the following in another session, in one or more another machines:|
⍝ |                                                                        |
⍝ |      #.isolate.AddServer '192.168.0.2' (7052-⎕IO-⍳4)                   |
⍝ '------------------------------------------------------------------------'
⍝
⍝ AddServer                                                r← AddServer ⍵
⍝ use isolate server started in another machine
⍝ ⍵         address ports
⍝ address   ip-address of host where isolates will reside.
⍝ ports     ports listening for isolate creation and execution.
⍝   The argument will be given as output from the session in the server machine when started with:
⍝       isolate.StartServer''
⍝ Multiple servers can be started in different machines and used by one or vice versa depending on resources available.
⍝ isolates can be used as usual with New, llEach &c. but expressions will be evaluated in the other machine.
⍝
⍝ New                                                      r←New ⍵
⍝ models isolate primitive: ¤
⍝ ⍵         source
⍝ source    code ∧/∨ data to be copied to isolate.
⍝           ref or namelist expected to be qualified relative to caller.
⍝ caller    space from which this fn was called.
⍝           when this is primitive both source & caller will be a matter of course.
⍝ ←         proxy
⍝ proxy     visible component of isolate.
⍝           anonymous space child of caller.
⍝           contains copies of iSyntax & iEvaluate, and refs - iSource to source, iCaller to the caller, iSpace to this space, iCarus - an instance of the "suicide" class and iD - containing the isolate id, the DRC client id, the port and the remote process id.
⍝
⍝ Config                                                r← Config ⍵
⍝ query or set configuration options.
⍝ ⍵         '' | name | name value
⍝ name      one of params defined in setDefaults
⍝ value     new value for param
⍝ ←         ⍵:''            : table of all names and values
⍝           ⍵:name          : value
⍝           ⍵:name value    : old value having set new in param
⍝ Config should normally be run before any isolate processes are created to ensure non-default values are honoured.
⍝ Once any isolates have been created all but "debug" have been used and will e ignored.
⍝ e.g.
⍝ ,----------------------,
⍝ |      isolate.Config''|
⍝ | debug             0  |
⍝ | drc               #  |
⍝ | listen            0  |
⍝ | processes         1  |
⍝ | processors        4  |
⍝ | runtime           0  |
⍝ | status       client  |
⍝ | workspace   isolate  |
⍝ '----------------------'
     
⍝ --
⍝ Operators:
⍝ The results of these operators should be equivalent to that modelled except insofar as asynchronous execution makes the order of creation of side-effects unpredictable.
⍝ --
⍝ ll                                                    r←⍺ (⍺⍺ ll) ⍵
⍝ parallel - models ⍺ ⍺⍺ || ⍵
⍝ ⍺     optional left argument to ⍺⍺
⍝ ⍺⍺    function to run in an ephemeral isolate.
⍝ ⍵     right arg to ⍺⍺
⍝ ←     future - result of ⍺⍺ executed in isolate.
⍝
⍝ llEach                                                r←⍺ (⍺⍺ llEach) ⍵
⍝ parallel each - models ⍺ ⍺⍺ || ¨ ⍵
⍝ ⍺     optional array itemwise compatible with ⍵; it's items are in the left domain of ⍺⍺.
⍝ ⍺⍺    function presumed to be ambivalent or dyadic if ⍺ is supplied or monadic if not.
⍝ ⍵     array whose items are in the right domain of ⍺⍺.
⍝ ←     array of futures with shape ←→ ⍴⍺⊢¨⍵ or ⍴⍵
⍝
⍝ llOuter                                              r←⍺ (⍺⍺ llOuter) ⍵
⍝ parallel outer product - models ⍺ ∘.(⍺⍺ ||) ⍵
⍝ ⍺     array whose items are in the left domain of ⍺⍺.
⍝ ⍺⍺    dyadic function applied between all possible pairs of items of ⍺ and ⍵
⍝ ⍵     array whose items are in the right domain of ⍺⍺.
⍝ ←     array of futures with shape ←→ (⍴⍺),⍴⍵
⍝
⍝ llKey                                               r←⍺ (⍺⍺ llKey) ⍵
⍝ parallel key - models ⍺ (⊂ ⍺⍺) || key ⍵
⍝ ⍺     optional array ; if present:  ≢⍺ ←→ ≢⍵ ; else:  ⍺⍺ llKey ⍵ ←→ ⍵ ⍺⍺ llKey ⍳≢⍵
⍝ ⍺⍺    ambivalent function applied between each unique major cell of a and the corresponding subarray of ⍵
⍝ ⍵     array
⍝ ←     array of futures with shape as the number of unique keys each item being a single result of ⍺⍺.
⍝ To emulate primitive key completely it should mix (↑) the results. This is not done here as it would dereference the futures.
⍝
⍝ llRank                                             r←⍺ (⍺⍺ llRank ⍵⍵) ⍵
⍝ parallel rank - models ⍺ (⊂ ⍺⍺) || rank ⍵⍵ ⊢ ⍵
⍝ ⍺     optional array framewise compatible with ⍵; it's cells as defined by ⍵⍵ are in the left domain of ⍺⍺.
⍝ ⍺⍺    function presumed to be ambivalent or dyadic if ⍺ is supplied or monadic if not.
⍝ ⍵⍵    integer scalar or 1, 2 or 3 item vector defining the ranks of the cells to or between which function ⍺⍺ will be applied.
⍝ ⍵     array whose cells as defined by ⍵⍵ are in the right domain of ⍺⍺
⍝ ←     array of futures with shape determined by combination of ⍵⍵ and the shapes of ⍺ amd/or ⍵
⍝ ⍺⍺ is applied between corresponding cells of ⍺ and ⍵ or to the cells of ⍵.
⍝ To emulate primitive rank completely it should mix (↑) the results. This is not done here as it would dereference the futures.
⍝ -----------------------------------------------------------------
⍝ Internals
⍝
⍝ iSyntax - copied to proxy
⍝ return name class and syntax code of supplied name
⍝
⍝ ⍵         simple name, word or "()" or "{}" delimited expression, adjascent to the dot in iso.whatever
⍝ ←         class, syntax
⍝ class, syntax of name in isolate.
⍝           3 nilad if '(...)'
⍝           3 ambiv if '{...}'
⍝           2       if 2={x←⍎⍵ ⋄ ⎕nc'x'}'⎕...'
⍝           3 ambiv if 2={x←⍎⍵ ⋄ ⎕nc'x'}'⎕...'
⍝           3 ambiv if ∊',⊢-⊂⍴⊃≡+!=⍳⊣↓↑|⍪⍕⍎∊⌽~×≠>⌊∨?⌷<≢⌈≥⍷⍉∪÷⍒⊥∧⍋⊖*○⍲⍱⍟⌹⊤≤∩'
⍝           0 error if 0>⎕nc'...'
⍝           otherwise send to isolate to ask for ⎕NC and ⎕AT
⍝
⍝ --------------------------------------------------------------------------
⍝ iEvaluate - copied to proxy
⍝ execute expression supplied to isolate
⍝
⍝ ⍺    | ⍵ - n is the syntax code supplied by "syntax"
⍝      |
⍝      | 2 n arrayname
⍝      | 2 n arrayname newvalue
⍝      | 2 n arrayname (PropertyArguments : Indexers IndexersSpecified)
⍝      | 2 n arrayname (PropertyArguments : Indexers IndexersSpecified NewValue)
⍝      | 3 n niladname
⍝      | 3 n (expression)
⍝      | 3 n {monad} rarg
⍝ larg | 3 n {dyad} rarg
⍝      | 3 n monadname rarg
⍝ larg | 3 n dyadname rarg
⍝
⍝ RPCServer only permits a monadic fname and rarg to an existing function in the remote ws so we give it 'execute' with nested vector rarg as:
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
⍝ process it is passed back as ⎕EN ⎕DM that is signalled .
⍝ --------------------------------
⍝ Configuration options
⍝ (from the setDefaults private function:
⍝ ,------------------------------------------------------------------------------,
⍝ |   options.debug←0                           ⍝ cut back on error              |
⍝ |   options.drc←#                             ⍝ copy into # if # and missing   |
⍝ |   options.workspace←'isolate'               ⍝ load current ws for remotes?   |
⍝ |   options.listen←0                          ⍝ can isolate call back to ws    |
⍝ |   options.processors←processors 4           ⍝ no. processors                 |
⍝ |   options.processes←1                       ⍝ per processor                  |
⍝ |   options.runtime←'R'∊3⊃'.'⎕WG'APLVersion'  ⍝ use runtime version unless devt|
⍝ |   options.status←'client'                   ⍝ set as 'server' by StartServer |
⍝ '------------------------------------------------------------------------------'
⍝ debug:
⍝ All public fns and ops set an error guard as:
⍝      trapErr''::signal''
⍝ If options.debug is 0 (the default) then trapErr'' returns 0 so all errors are trapped and signalled back to the session.
⍝ If 1 then trapErr'' is ⍬, there is no trap and errors are signalled at the point of error.
⍝
⍝ drc:
⍝ If drc is # (the default) we check to see if #.DRC exists and copy if not. Otherwise drc must be a ref to the extant DRC namespace.
⍝
⍝ workspace:
⍝ This is the workspace to be ⎕LOADed by APLProcess (default "isolate") that must contain the isolate namespace and call 'isolate.ynys.isoStart ⍬' in its ⎕LX. It should be in one of the folders defined in [Options]-[Configure...]-[Workspace] in the session menubar or be specified with a full path.
⍝
⍝ listen:
⍝ Whether the isolates will be enabled to call back to the active ws to request further data &c. (default 0.)
⍝ When enabled an "instance" of RPCServer is created locally to receive requests from the isolates.
⍝ Such requests are issued to the "parent" of the remote isolate accessed as ##. which is enabled as an isolate in its own right.
⍝
⍝ processors:
⍝ The number of prosessors in the machine. Currently available from Windows but default 4 elsewhere.
⍝
⍝ processes:
⍝ The number of processes that will be started per prosessor in the machine. (default 1.)
⍝
⍝ runtime:
⍝ Whether the runtime equivalent of the active interpreter should be started for the slave processes. If the active interpreter (the default) is runtime then runtime anyway.
⍝
⍝ status:
⍝ Set by StartServer and AddServer.
⍝
⍝
      }

      processors←{⍺←⊢
          (1111⌶⊢⊢)1111⌶1
⍝ uh? aargh!
⍝ At its first invocation 1111⌶ returns the number of processors
⍝   available having set the stored value to ⍵.
⍝ Subsequent calls return the immediately previously stored value.
⍝ The above arbitrarily sets 1, getting & resetting the previous.
      }

      prof←{⍺←⊢ ⋄ ⎕IO←0
          z←⎕PROFILE'clear'
          z←⎕PROFILE'start'
          r←⍺ ⍺⍺⍣⍵⍵⊢⍵
          z←⎕PROFILE'stop' ⋄ e←⍬⍴⎕LC
          p←e↓⎕PROFILE'data'
          p[;3 4]{⌊0.5+100×⍺÷⍵}←0 4⌷p
          p[;]←p[⍒p[;3];]
          n←{⍺,~∘' '⍕,'[',(⍪⍵),']'}/2↑⍤1⊢p
          p←4↑⍤1⊢n,0 2↓p
          p⍪⍨←'operation[]' 'called' 'exclusive %' 'inclusive %'
          r p
⍝ ⍺     [larg]
⍝ ⍺⍺    fn
⍝ ⍵⍵    rop to ⍣ (fn or int)
⍝ ⍵     rarg
⍝ ←     res prof
⍝ res   result of: ⍺ ⍺⍺⍣⍵⍵⊢⍵
⍝ prof  ⎕profile wherein
⍝       cols[0,1] joined as fnname[lineno]
⍝       times converted to % so ⍺⍺ takes 100 overall
⍝       last two cols missing
      }

      receive←{⍺←⊢
          (source listen id)←⍵                           ⍝ this all happens remotely
          name←id.chrid
          root←⎕NS''
          z←{root.⎕FX¨proxySpace.(⎕CR¨↓⎕NL 3)}⍣listen⊢1  ⍝ prepare for calls back
          root.iSpace←⎕THIS
          id.(port←home)
          id.(chrid←'Iso',⍕1+numid)
          id.tgt←,'#'
          root.iD←id
          iso←root.⎕NS(⍴⍴source)⊃source''                ⍝ clone of source
          z←iso.{6::0 ⋄ z←{}⎕CY ⍵}⍣(≡source)⊢source      ⍝ or copy if ws
          z←iso.{6::0 ⋄ z←{}(↑'⎕io' '⎕ml')⎕CY ⍵}⍣(≡source)⊢source
          z←name{#.⍎⍺,'←⍵'}iso                           ⍝ name it in root
          z←#.DRC.Clt⍣listen⊢id.(chrid orig port)        ⍝ orig=host if local
          1⊣1(700⌶)root                                  ⍝ DOMAIN ERROR if no iSyntax
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
          new←0=here.⎕NC⊂'options'             ⍝ set defaults only once
          z←{here.options←⎕NS''
              options.debug←0                  ⍝ cut back on error
              options.drc←#                    ⍝ copy into # if # and missing
              options.workspace←getDefaultWS'isolate' ⍝ load current ws for remotes?
              options.listen←0                 ⍝ can isolate call back to ws
              options.processors←processors ⍬  ⍝ no. processors (fn ignores ⍵)
              options.processes←1              ⍝ per processor
              options.runtime←0                ⍝ use runtime version
              options.status←'client'          ⍝ set as 'server' by StartServer
              1:1
          }⍣new⊢0
          0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
          ⊢options getset ⍵
⍝ called by Config before Init runs and by Init when it does.
⍝ set default options and permit user changes
⍝ but leave Init to apply them.
      }

      setOption←{⍺←⊢
     
          ⍺≡'debug':{        ⍝ set trap function on or off
              ⎕THIS.(trapErr←(⍵↓0)∘⊣)
              ⍵
          }⍵
     
⍝     ⍺≡'workspace':{                 ⍝ ensure quoted if needs
⍝         (⊢/≥∨/)', "'∊⍵:⍵            ⍝ quoted or no commas or spaces
⍝         options getset ⍺('"',⍵,'"') ⍝ quote
⍝     }⍵
     
          ⍵
     
⍝ any options requiring immediate action.
⍝ by the time this runs the var in options named as ⍺
⍝   has ready been set to ⍵ in Config
⍝   so this only covers the special cases.
      }

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

      whoami←{⍺←⊢
          (W wc wa L lc la A ac aa)←messages'⍝- '
          (adr cfg)←(W L A⍳⊂3⍴⊃#.⎕WG'APLVersion')⊃(wa wc)(la lc)(aa ac)
          ⊃{(⍵≠' ')⊂⍵⊣⎕ML←3}(1↓⍳∘':'↓⊢)⊃{⍵⌿⍨∨/adr⍷minuscule↑⍵}⎕CMD cfg
⍝- Win
⍝- ipconfig
⍝- ipv4 address
     
⍝- Lin
⍝- /sbin/ifconfig
⍝- inet addr
     
⍝- AIX
⍝- ifconfig
⍝- inet addr
      }

      win←{⍺←⊢
          'W'=2⊃#.⎕WG'APLVersion'
          'Windows'{⍺≡(⍴⍺)↑⍵}⊃⍬⍴#.⎕WG'APLVersion'
⍝
      }

      ynys←{⍺←⊢
⍝ ynys - Welsh - island - cognate with insular, isolate &c.
⍝ and beginning with "y" it's at the bottom of autocomplete
      }

   
    :namespace proxySpace
   ⍝ ## ←→ #.isolate.ynys
   
        (⎕IO ⎕ML)←0 1
   
          iEvaluate←{⍺←⊢
              data←⍺ iSpace.encode ⍵
              home←2∊⎕NC'iSpace.session.started'
              z←{
                  ⊢iSpace.session.assoc.(busy∨←iso=⍵)  ⍝ thread safe global assign on
              }⍣home⊢iD.numid
              0::(⊃⎕DM)⎕SIGNAL ⎕EN                   ⍝ signal here leaves busy on
              res←iSend iD.tgt data                    ⍝ the biz
              z←{
                  ⊢iSpace.session.assoc.(busy∧←iso≠⍵)  ⍝ thread safe global assign off
              }⍣home⊢iD.numid
              1:res
   ⍝ execute expression supplied to isolate
   ⍝ see notes
          }
   
          iSend←{data←⍵
              send←((⍕iSpace),'.execute')data              ⍝ RPCServer runs this
              res←iSpace.DRC.Send iD.chrid send
              0≠0⊃res:(⍕res)⎕SIGNAL 11
              wait←{
                  (r n e d)←res←4↑iSpace.DRC.Wait 1⊃⍵
                  r=100:⊢⍵⊣⎕DL 0.1
                  r≠0:(⍕res)⎕SIGNAL 11
                  e≡'Progress':⊢⍵
                  e≡'Receive':⊢1 d
                  .uh?
              }
              (en res)←1⊃wait⍣(⊃⊣)2⍴res
              ko←~ok←en=0
              home←2∊⎕NC'iSpace.session.started'
              ~home:⊢{(⊃⍬⍴⍵)⎕SIGNAL en}⍣ko⊢res             ⍝ do I want to signal remotely
         
              assoc←iSpace.session.assoc
              last←1≥+/assoc.busy                          ⍝ last man standing
         
              ok>last:⊢res                                 ⍝ ok!!!
         
              ok:{                                         ⍝ last and ok
                  ok←0∊⍴⊃(en dm)←assoc.((err≠0)∘/¨err msg) ⍝ no stacked errors
                  ok:⊢res
         
                  assoc.((1/err)←(1/msg)←(1/busy)←0)       ⍝ clear record
                  (⊃dm)⎕SIGNAL⊃en                          ⍝ signal first stacked error
              }res
                                                     ⍝ error trapped via RPCServer
              (pre msg)←'Isolate: ' 'Call back to session not enabled'
         
              dm←pre,⊃{(1∊'##'⍷⍵)⊃⍺ msg}/2↑res
         
              last:dm ⎕SIGNAL en
   ⍝ we're not the last so we stack error and return anything to avoid a value error
              assoc.(err msg)←iD.numid assoc.{t⊣((iso⍳⍺)⊃¨t)←⍵⊣t←err msg}en dm
              1:0
         
         
   ⍝ called from both iEvaluate and iSyntax and also from
   ⍝ ##.cleanup to get rid of isolate from remote process
          }
   
          iSyntax←{⍺←⊢
              c←⊣/⍵
              '('=c:⊢3 32                            ⍝ if '(expr)' ⍝ 1 0 0 0 0 0
              '{'=c:⊢3 52                            ⍝ if '{defn}' ⍝ 1 1 0 1 0 0
              '⎕'=c:⊢{x←⍎⍵ ⋄ c←⎕NC'x' ⋄ (2 3⍳c)⊃(2 0)(3 52)(0 0)}⍵ ⍝ assumes ⎕FNS ambi
                                               ⍝ ↑ reject ops & nss
              f←',⊢-⊂⍴⊃≡+!=⍳⊣↓↑|⍪⍕⍎∊⌽~×≠>⌊∨?⌷<≢⌈≥⍷⍉∪÷⍒⊥∧⍋⊖*○⍲⍱⍟⌹⊤≤∩'
         
              c∊f:⊢3 52
              0>⎕NC ⍵:⊢0 0                           ⍝ primitive operators
              expr←'((2⍴⎕nc∘⊂,⎕at),''',⍵,''')'       ⍝ then what is it?
              (nc at)←iSend iD.tgt(0 expr)           ⍝ from the horse's mouth
              nc∊3.2 3.3:⊢3 52                       ⍝ 3,32+16+4 res ambi omega
              c←⌊nc                                  ⍝ class
              c∊0 2:⊢2 0                             ⍝ undef, var
              (r fv ov)←at                           ⍝ result, valence
              w←∨/(a d w)←fv=¯2 2 1                  ⍝ (ambi, dyad, omega)
              r←c,2⊥r a d w 0 0                      ⍝ class, encoded syntax
              1:⊢r
   ⍝ return nameclass and syntax for supplied name (string)
   ⍝ see notes
          }
   
    :endnamespace ⍝ proxySpace
   
    :namespace qv
        ##.(⎕io ⎕ml)←0 1
    :endnamespace
   
    :Class suicide
        ∇ inst←New data;whence
          :Access public shared
          whence←⍬⍴⎕RSI
          inst←whence.⎕NEW ⎕THIS
          inst.(whence data)←whence data
        ∇
   
        ∇ coroner
          :Implements destructor
          (fn arg)←data
          (whence.⍎fn)arg
        ∇
   ⍝ set a destructor on an ordinary container space.
   ⍝ When the space into which the instance is set,
   ⍝ e.g. 'this' in:
   ⍝       this.close←suicide.New name arg
   ⍝ is destroyed, the function named as the first of
   ⍝ two items in New's argument, that must be in the
   ⍝ space that called 'New', is called with the second
   ⍝ item of that same arg and can be made to release
   ⍝ resources even though space - 'this' has gone.
   ⍝ Phil Last ⍝ 2013-06-29 10:31
    :EndClass
:endnamespace ⍝ ynys