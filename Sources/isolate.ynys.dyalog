:namespace ynys
⍝ ## ←→ #.isolate

    (⎕IO ⎕ML)←0 1      

    tracelog←{⎕←((1⊃⎕SI),'[',(⍕1⊃⎕LC),']') ⍵} 
    ⍝tracelog←{}        ⍝ uncomment this line to disable logging

    retry_limit←20      ⍝ How many retries 
    retry_interval←0.25 ⍝ Length of first wait (increases with interval each wait)
  
      AddServer←{⍺←⊢
          msg←messages'⍝- '
          'server'≡Config'status':0⊃msg
          ''⍬≢0/¨⍵:1⊃msg
          (addr ports)←⍵
          {1∊∊∘∊⍨⍵⊣⎕ML←0}addr ports:2⊃msg
          z←Config'status' 'client'
          z←Init''
          ss←session.
          id←(⍳≢ports)+1+0⌈⌈/⊣/ss.procs
          ss.procs⍪←id,0,(⊂addr),⍪ports
          1:1
⍝- Session already started as server
⍝- Argument must be 'ip-address' (ip-ports)
⍝- IP-address nor IP-ports can be empty
      }
      
    ∇ r←DRCClt args;count
      ⍝ Create a DRC Client, looping a bit
     
      count←0
      :While 0≠⊃r←DRC.Clt args ⍝ Cannot connect
          :If 1111=⊃r
              {}⎕DL retry_interval×count+←1 ⍝ longer wait each time
          :Else
              ('Unable to connect to isolate process: ',⍕args)⎕SIGNAL 11
          :EndIf
      :Until count≥retry_limit
    ∇

      Config←{⍺←⊢
          newSession'':{              ⍝ else Init has already run
              0::(⊃⎕DM)⎕SIGNAL ⎕EN
              setDefaults ⍵
          }⍵
          trapErr''::signal''
          getSet ⍵
     
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
          here.iSpace←here←⎕THIS
          z←here.(proxyClone←⎕NS'').⎕FX¨proxySpace.(⎕CR¨↓⎕NL 3)
          z←here.proxyClone.⎕FX iSpace.⎕CR'tracelog'
          ss←here.session←⎕NS''
          z←setDefaults''
          op←options
          z←getSet'debug'op.debug                 ⍝ on or off
          trapErr''::signal''
          ##.DRC←here.DRC←getDRC op.drc
          z←DRC.Init ⍬
          here.(signal←⎕SIGNAL/∘{(0⊃⎕DM)⎕EN})
          ss.orig←whoami''
          ss.homeport←7051
          ss.listen←localServer op.listen   ⍝ ⌽⊖'ISOL'
 ⍝         ss.listen←10 listen until⊢⍣op.listen⊢0  ⍝ "calls back"?
          ss.errors←0⍴,⊂0 0('' '')                 ⍝ ⎕EN ⎕DM for latest group
          ss.nextid←2⊃⎕AI                         ⍝ isolate id
          z←⎕TPUT ss.callback←1+(2*15)|+/⎕AI      ⍝ queue for calls back
          z←⎕TPUT ss.assockey←1+ss.callback       ⍝ queue for assoc and procs
     
          ((ws rt)iso)←op.(workspace runtime)'-isolate=isolate'
          ws←1⌽'""',checkWs addWSpath ws          ⍝ if no path ('\/')
          ports←ss.homeport+1+⍳op.(processors×processes)
     
          procs←{⎕NEW ##.APLProcess(ws ⍵ rt)}∘{'-AutoShut=1 -Port=',⍕⍵,iso}¨ports
          pids←(1⊃⎕AI)+⍳⍴procs
          procs.onExit←{'{}#.DRC.Close ''PROC',⍵,''''}¨⍕¨pids
          pclts←pids{0≠⊃z←DRCClt('PROC',⍕⍺)ss.orig ⍵:'' ⋄ 1⊃z}¨ports
          0∊≢¨pclts:'UNABLE TO CONNECT TO NEW PROCESSES'⎕SIGNAL 6
          ss.procs←pids,procs,(⊂ss.orig),ports,⍪pclts
          ss.assoc←dix'proc iso busy seq'(4⍴⍬ ⍬)
          ss.assoc.(group←{seq⊃⍨iso⍳⍵})           ⍝ ephemeral group id
     
          ss.started←sessionStart''               ⍝ last thing so we know
          1:⊢1                                    ⍝ 1 - newly started
⍝ Init if new ss
⍝ ⍵ ?
⍝ ← 1 | 0 - 1=started, 0=already
      }

      InternalState←{⍺←⊢
          newSession'':⍳0 0
          {⍵.({⍵,⍪⍎⍕⍵}↓⎕NL 2)}⍣('namespace'≢minuscule ⍵)⊢session.assoc
⍝
      }

      LastError←{⍺←⊢
          newSession'':0 2⍴0
          0∊⍴session.errors:0 2⍴0
          errors←↑¨↑session.errors←{⍺/⍨⍵=⊢/⍵}∘(⊣/↑)⍨session.errors
     ⍝ ↑ all in same group as 2-cols ⎕EN ⎕DM
          session.errors←0⍴session.errors
          {(≢⍵),1↓⍺}⌸errors
⍝
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
      }

      StartServer←{⍺←⊢
          msg←messages'⍝- ' ⍝
          ~newSession'':(0⊃msg),' ',options.status
          z←Config'status' 'server'
          z←Init''
          address ports←(session.orig)(∪⊢/session.procs)
          info←(1 2⊃¨⊂msg),⍪address ports
          res←⊃,/⍕¨,(4 5 6 7⊃¨⊂msg),⍪address(⊃ports)(⍴ports)''
          ⎕←⍪,' ',⍪info(3⊃msg)res
          1:''
     
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
          ⍺⍺⊣⍵:⍵⍵⊣⍵
          0
⍝ left to right checking
⍝ try ⍵⍵ only if ⍺⍺ true
      }

      argType←{⍺←⊢
          trapErr''::signal''
          (0∊⍴)⍵:⍺.⎕NS''                                         ⍝ empty
          (0=≡)and{9=⎕NC'⍵'}⍵:⍵                                  ⍝ ns
          (1=≡)and(''≡0⍴⊢)⍵:checkWs ⍵
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

      checkWs←{⍺←⊢
                                   ⍝ ⍵ IS a string
          z←⎕NS''
          0::'WS NOT FOUND'⎕SIGNAL ⎕EN  ⍝ any error bar Value
          6::⍵                          ⍝ value error implies copy ok
          z←{}'⎕IO'z.⎕CY ⍵              ⍝ force value error → return ⍵
⍝
      }

      cleanup←{⍺←⊢
          trapErr''::signal''
          (chrid port numid)←⍵.(chrid port numid)
          ⎕←⍪'.'/⍨options.debug
          (ns←⎕NS proxyClone).(iD iSpace)←⍵ iSpace    ⍝ recreate temp proxy
          rem←{session.assoc.(iso proc busy seq⌿⍨←⊂iso≠⍵)}
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

    ∇ r←connect(chrid host port data);count
      :If 0=⊃r←DRCClt chrid host port ⍝ DRCClt will retry
      :AndIf 0=⊃r←DRC.Send chrid data       ⍝ on any
      :AndIf 0=⊃r←DRC.Wait 1⊃r              ⍝ error
      :Else ⋄ {}DRC.Close chrid
      :EndIf
⍝ connect and send Initial payload
⍝ ⍺     attempts
⍝ ⍵     client-id ip-port data
⍝ data  function and argument
⍝ ←     final return from DRC
    ∇

      dateNo←{⍺←⊢
          ⊢2 ⎕NQ'.' 'DateToIDN'⍵
⍝
      }

    ∇ res←where decode(a b c d e);home;x;tok;j;i
      home←where=#  ⍝ would be #.IsoNNNNN for outward call
      x←where.⍎
      tok←{⎕TGET session.callback}⍣home⊢0  ⍝ one at a time please!
      :Trap 0
          :Select a
          :Case 0 ⋄ res←0(x b)
          :Case 1 ⋄ res←0((x b)c)
          :Case 2 ⋄ res←0(b(x c)d)
          :Case 3 ⋄ res←0(c⊢b{x ⍺,'←⍵'}c)
          :CaseList 4 5
              (i j)←c d+where.⎕IO
              :If a=4 ⋄ res←0(⍎'i(j where.{⊢⍺⌷[⍺⍺]',b,'})0')
              :Else ⋄ res←0(⍎'i(j where.{⊢(⍺⌷[⍺⍺]',b,')←⍵})e')
              :EndIf
          :EndSelect
      :Else
          res←⎕EN ⎕DM
      :EndTrap
     
      tok←{⎕TPUT session.callback}⍣home⊢0  ⍝ next please!
⍝ ⍺ target space
⍝ ⍵ encoded list
⍝   decode list and execute requisite syntax in target.
⍝   return (0 value) if OK, (⎕EN ⎕DM) on failure
    ∇

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
      }

    ∇ r←execute(name data);z;n
      space←#.⍎name
      tracelog space name
      :Trap 0
          r←space decode 5↑data
      :Else
          ⎕TRAP←0 'S' ⋄ ∘ ⍝ WTF???!!!
      :EndTrap
      tracelog r
      :If 0=⎕NC'session' ⍝ In the isolate
          tracelog'in the isolate session'
          :Trap 6
              z←≡r ⍝ Materialize r to provoke VALUE ERROR
          :Else
              tracelog'got the value error!'
              :If 2=⎕NC n←name,'error'
                  r←⍎n ⋄ ⎕EX n
              :Else
                  r←6('VALUE ERROR: Callback failed'(1⊃data)'^')
              :EndIf
          :EndTrap
      :EndIf
⍝ this is the function called by RPCServer.Process
⍝ ⍵     name data
⍝ data  list created by encode below.
⍝ ←     result or assignment of decoded ⍵
    ∇

      expose←{⍺←⊢
          (src snm)←⍵
          (tgt tnm)←⍺⊣#             ⍝ dflt target  - #
          tnm←snm∘⊣⍣(tgt≡tnm)⊢tnm   ⍝ dflt tnames  - snames
          ss←⍕src
          trap←'⋄0::(⊃⍬⍴⎕dm)⎕signal⎕en⋄'
          fix←{op←4=src.⎕NC ⍵
              (aa ww)←2↑(0 2⊃src.⎕AT ⍵)⍴'⍺⍺' '⍵⍵'
⍝         tgt.⎕FX(⍺,'←{⍺←⊢')trap('⍵≡⍺⍵:',aa,ss,'.',⍵,ww,'⊢⍵')('⍺(',aa,ss,'.',⍵,ww,')⍵')'}'
              tgt.⎕FX,⊂⍺,'←{⍺←⊢',trap,(op/'⍵≡⍺⍵:',aa,ss,'.',⍵,ww,'⊢⍵⋄'),'⍺(',aa,ss,'.',⍵,ww,')⍵}'
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
⍝ tgt.tnm←{⍺←⊢⋄0::(⊃⍬⍴⎕DM)⎕SIGNAL⎕EN⋄                      ⍺(  #.src.snm  )⍵} ⍝ function
⍝ tgt.tnm←{⍺←⊢⋄0::(⊃⍬⍴⎕DM)⎕SIGNAL⎕EN⋄ ⍵≡⍺⍵:⍺⍺#.src.snm  ⊢⍵⋄⍺(⍺⍺#.src.snm  )⍵} ⍝ adverb
⍝ tgt.tnm←{⍺←⊢⋄0::(⊃⍬⍴⎕DM)⎕SIGNAL⎕EN⋄ ⍵≡⍺⍵:⍺⍺#.src.snm⍵⍵⊢⍵⋄⍺(⍺⍺#.src.snm⍵⍵)⍵} ⍝ conjunction
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

      getSet←{⍺←⊢
     
          0∊⍴⍵:options.({⍵,⍪⍎⍕⍵}↓⎕NL 2 9)
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
          s b i r←'SBIR'=type
          msg←nam,' should be a',⍕s b i r/'string' 'boolean' 'integer' 'ref'
          ok←b and(⊢≡1=⊢)new
          ok←ok∨i and(0≡∊)and(⊢=⌊)new
          ok←ok∨s and{''≡0⍴⍵}new
          ok←ok∨r and{9=⎕NC'⍵'}new
          ~ok:sig11 msg
          ok←ok∧((1=⍴)∨(⊂new)∊⊢)range
          ~ok:sig11⍕nam,' should be one of:',range
     
          (ws db li)←'workspace' 'debug' 'listen'∊⊂nam ⍝ special
          0::(⊃⎕DM)⎕SIGNAL ⎕EN                         ⍝
          z←checkWs⍣ws⊢new                             ⍝
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

      isoGroup←{⍺←⊢
          ≥/0 1∊{9∊⎕NC'⍵'}¨iso←,⍵:
          0∊was←0(700⌶)¨iso:{}was(700⌶)¨iso
          z←1(700⌶)¨iso⊣ids←iso.iD.numid
          (session.nextid grp)←2+session.nextid
          ⊢ids session.assoc.{((iso∊⍺)/seq)←⍵}grp
     
⍝ ⍵ array of isolates
⍝   group all in new unique group
⍝ ← group id
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
          ⍝ ⎕TRAP←0 'C' 'f00⍬'
          ⎕TRAP←0 'S' ⍝ /// Debugging
     
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
          ss.assoc.(iso proc busy seq),←num⍴¨numid procs 1(⌊/numid)
          z←⎕TPUT ss.assockey   ⍝ ↑ all have same "seq" see "group←{" in Init
     
          (host port)←↓⍉{⍵[⍵[;0]⍳procs;2 3]}ss.procs
          data←↓host,(⊂ss.orig),chrid,numid,tgt,ss.homeport,⍪port
          ids←{dix'host orig chrid numid tgt home port'⍵}¨data
          z←connect¨↓chrid,host,port,⍪↓receive,⍪↓source,ss.listen,⍪ids
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

    ∇ r←localServer r;srv;rc;z
      →(0=⎕NC'session.homeport')⍴0
      :If r=0
      :AndIf r←DRC.Exists srv←'ISO',⍕session.homeport ⍝ Server exists
          {}DRC.Close srv ⍝ Left over - object there but no thread
          ⎕TKILL session.listeningtid
          ⎕EX'session.listeningtid'
      :Else
     
          :If r←DRC.Exists srv←'ISO',⍕session.homeport ⍝ Server exists
              :If r←2=⎕NC'session.listeningtid'
              :AndIf r←session.listeningtid∊⎕TNUMS
              :Else
                  {}DRC.Close srv ⍝ Left over - object there but no thread
              :EndIf
          :EndIf
     
          :If ~r ⍝ Already got a listening server
              :If r←0=rc←⊃z←1 1 ##.RPCServer.Run srv session.homeport
                  session.listeningtid←1⊃z
              :ElseIf 10048=rc ⍝ Socket already in use
                  ('Unable to create listener on port ',⍕session.homeport)⎕SIGNAL 11
              :EndIf
          :EndIf
      :EndIf
    ∇

      messages←{⍺←⊢
          {(+/∨\' '≠⌽⍵)↑¨↓⍵}⍵{(0,⍴,⍺)↓⍵⌿⍨>/⍺⍷⍵}⎕CR⊃1↓⎕XSI
⍝ attached to caller
      }

      minuscule←{⍺←⊢
          ('abcdefghijklmnopqrstuvwxyz',,⍵)[(⎕A,,⍵)⍳⍵]
⍝
      }

      newSession←{⍺←⊢
          0∊⎕NC'session.started':1
          0.0001<|session.started-sessionStart''
⍝ The session is new if session.started is missing.
⍝ It needs to be restarted if session.started differs from the actual
⍝ start of the session by more than 8.64 seconds (1/10000 of a day)
⍝ that indicates that the ws was saved with the session space intact
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

      publicMethods←{⍺←⊢
          messages'⍝- '
⍝- AddServer
⍝- Config
⍝- InternalState
⍝- LastError
⍝- New
⍝- StartServer
⍝- ll
⍝- llEach
⍝- llKey
⍝- llOuter
⍝- llRank
     
⍝ add more after prefix '⍝- '
      }

      receive←{⍺←⊢
          (source listen id)←⍵                           ⍝ this all happens remotely
          name←id.chrid
          root←⎕NS''
          z←{root.⎕FX¨proxySpace.(⎕CR¨⎕NL ¯3),⊂⎕CR'tracelog'}⍣listen⊢1  ⍝ prepare for calls back
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
         
    ∇ r←Reset mode;iso;clt;ok
      :If 2=⎕NC'session.assoc.iso'
          r←(⍕≢session.assoc.iso),' isolates, '
          :For iso :In session.assoc.iso ⍝ For each known isolate
              {}DRC.Close'Iso',⍕iso
          :EndFor
     
          r,←(⍕≢session.procs),' processes reset'
          :For clt :In session.procs[;4] ⍝ For each process
              {}DRC.Close clt
          :EndFor
     
          count←0
          :While ~ok←∧/session.procs[;1].HasExited
              ⎕DL retry_interval×count←count+1
          :Until count>retry_limit
          r←r,(~ok)/' (service processes have not died)'
     
          :If 2=⎕NC'session.listeningtid'
              ⎕TKILL session.listeningtid
          :EndIf
      :Else
          r←'nothing to reset'
      :EndIf
      ⎕EX'session'
    ∇

      sessionStart←{⍺←⊢
          24 60 60 1000{(dateNo ⍵)-(⍺-⍺⍺⊥3↓⍵)÷×/⍺⍺}/(2⊃⎕AI)⎕TS
⍝ diff twixt ⎕ts and ⎕ai
⍝ ← number of days and the decimal part thereof after the start of the last
⍝   day of the penultimate year of the nineteenth century: 1899-12-31 00.00
⍝ immune to system clock change as both rely on that.
      }

      setDefaults←{⍺←⊢
          here←⎕THIS
          new←0=here.⎕NC⊂'options'                      ⍝ set defaults only once
          z←{
              spaces←here.(types options domains)←here.⎕NS¨⍬ ⍬ ⍬
              tod←{(2⍴⍵),⊂1↓⍵}                          ⍝ type: Str Bool Int Ref
⍝ ensure all param names are minuscule as arg to Config is converted thus.
⍝        spaces.param← tod 'S' 'Default' 'and' 'the' 'Rest'
              spaces.debug←tod'B' 1                     ⍝ cut back on error
              ⎕←'/// NB debug set to 1'
              spaces.drc←tod'R'#                        ⍝ copy into # if # and missing
              spaces.listen←tod'B' 1                    ⍝ can isolate call back to ws
              ⎕←'/// NB listen set to 1'
              spaces.onerror←tod'S' 'signal' 'debug' 'return'
              spaces.processes←tod'I' 1                 ⍝ per processor
              spaces.processors←tod'I'(processors ⍬)    ⍝ no. processors (fn ignores ⍵)
              spaces.runtime←tod'B' 0                   ⍝ use runtime version
              ⎕←'/// NB runtime set to 0'
              spaces.status←tod'S' 'client' 'server'    ⍝ set as 'server' by StartServer
              spaces.workspace←tod'S'(getDefaultWS'isolate') ⍝ load current ws for remotes?
              1:1
          }⍣new⊢0
          0::(⊃⍬⍴⎕DM)⎕SIGNAL ⎕EN
          ⊢getSet ⍵                                     ⍝ this where Config called prior Init
⍝ called by Config before Init runs and by Init when it does.
⍝ set default options and permit user changes
⍝ but leave Init to apply them.
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

      ynys←{⍺←⊢
⍝ ynys - Welsh - island - cognate with insular, isolate &c.
⍝ and beginning with "y" it's at the bottom of autocomplete
      }

   
    :namespace proxySpace
   ⍝ ## ←→ #.isolate.ynys
   
        (⎕IO ⎕ML)←0 1
   
          iEvaluate←{⍺←⊢
              z←tracelog ⍵
              data←⍺ iSpace.encode ⍵
              ID←iD.numid
              ss←{iSpace.session}⍣home⊢home←2∊⎕NC'iSpace.session.started' ⍝ is this true ?
              z←{ss.assoc.((iso⍳⍵)⊃busy)←1}⍣home⊢ID
   ⍝     0::(⊃⎕DM)⎕SIGNAL ⎕EN            ⍝ signal here leaves busy on
              (rc res)←z←iSend iD.tgt data       ⍝ the biz
              z←tracelog'rc' 'res' 'home',⍪rc res home
              ok←0=rc
              ~home:{rc=0:⍵ ⋄ ⎕SIGNAL rc}⍵                 ⍝ call back? then we're done
   ⍝ I /think/ we might need ⎕SIGNAL on error from ## (~home)
              z←ss.assoc.{((iso⍳⍵)⊃busy)←0}ID
              ok:⊢res                          ⍝ spiffing!
   ⍝ record error and clock out
   ⍝ we have rc and res and presume that res is a ⎕DM
              ⍝(pre msg)←'Isolate: ' 'Call back to session not enabled'
   ⍝ if expression of ⎕DM contains '##' replace error-name with above.
              ⍝(⊃res)←pre,⊃{(1∊'##'⍷⍵)⊃⍺ msg}/2↑res
   ⍝ if 'f[] f' then drop 'f[] '
   ⍝  ...    (1⊃res)←{('f[] f'⍷⍵)↓⍵}↓1⊃res
              ss.errors{(⍺↓⍨63<≢⍺),⍵}←⊂(ss.assoc.group ID)rc res
              1:                               ⍝ VALUE ERROR: Future has no value
   ⍝ execute expression supplied to isolate
          }
   
          iSend←{data←⍵
              send←((⍕iSpace),'.execute')data      ⍝ RPCServer runs this
              ⎕TRAP←0 'C' '→1+⎕lc ⊣ res← ⎕EN, ⎕DM'
              res←iSpace.DRC.Send iD.chrid send
              rc nm ev data←4↑res                  ⍝ dest for trap on DRC.Send
              0≠rc:⊢rc((⍕rc nm)ev)                 ⍝ ret ⎕EN ⎕DM
              wait←{
                  res←(rc nm ev data)←4↑iSpace.DRC.Wait 1⊃⍵
                  rc=100:∇ ⍵⊣⎕DL 0.1
                  rc≠0:⊢res
                  ev≡'Progress':∇ ⍵
                  ev≡'Receive':res
            ⍝ any more?
              }
   ⍝ non-zero apart from 100 from DRC.Wait above
   ⍝  will blow ↓ this with DOMAIN ERROR
              res←wait 2⍴res
              (rc nm ev res)←res                                ⍝ dest for trap on DRC.Wait
   ⍝ if rc is 0 res which will be (0 result)
              rc=0:⊢1⊃res
   ⍝ else return rc and faked ⎕DM
              rc((⍕rc nm)ev)
         
   ⍝ called from iSyntax, iEvaluate and from
   ⍝ ##.cleanup to remove isolate from remote process
          }
   
          iSyntax←{⍺←⊢
              z←tracelog ⍵
              c←⊣/⍵
              '('=c:⊢3 32                            ⍝ if '(expr)' ⍝ 1 0 0 0 0 0
              '{'=c:⊢3 52                            ⍝ if '{defn}' ⍝ 1 1 0 1 0 0
              '#'∊c:⊢0 0                             ⍝ # in anything un-parenthesised is an error
              '⎕'=c:⊢{0::0 0 ⋄ x←⍎⍵ ⋄ c←⎕NC'x' ⋄ (2 3⍳c)⊃(2 0)(3 52)(0 0)}⍵ ⍝ assumes ⎕FNS ambi
                                               ⍝ ↑ reject ops & nss
              f←',⊢-⊂⍴⊃≡+!=⍳⊣↓↑|⍪⍕⍎∊⌽~×≠>⌊∨?⌷<≢⌈≥⍷⍉∪÷⍒⊥∧⍋⊖*○⍲⍱⍟⌹⊤≤∩'
         
              c∊f:⊢3 52
              0>⎕NC ⍵:⊢0 0                           ⍝ primitive operators
              expr←'((2⍴⎕nc∘⊂,⎕at),''',⍵,''')'       ⍝ then what is it?
              (rc res)←iSend iD.tgt(0 expr)          ⍝ from the horse's mouth
              (nc at)←res                            ⍝ ⎕NC ⎕AT - rc?
              nc∊3.2 3.3:⊢3 52                       ⍝ 3,32+16+4 res ambi omega
              c←⌊nc                                  ⍝ class
              c∊0 2:⊢2 0                             ⍝ undef, var
              (r fv ov)←at                           ⍝ result, valence
              w←∨/(a d w)←fv=¯2 2 1                  ⍝ (ambi, dyad, omega)
              r←c,2⊥r a d w 0 0                      ⍝ class, encoded syntax
              1:⊢r
   ⍝ return nameclass and syntax for supplied name (string)
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
          :Trap 0
              (fn arg)←data
              (whence.⍎fn)arg
          :EndTrap
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