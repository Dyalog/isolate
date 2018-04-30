:Namespace IIPageStats
⍝ Future/Isolate code sample, using #.ll.EachX    
⍝   Report 'al' 
⍝   ... to get a letter frequency count for home pages of newspapers in Alabama

    (⎕IO ⎕ML)←1
    alphabet←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'  
    
    ∇ freq←{nprocs}Report state;pages;html;cap;PF;AI3;iss;HttpCommand
      AI3←⎕AI[3]
     
      :If 0=⎕NC'nprocs' ⋄ nprocs←#.isolate.Config'processors' ⋄ :EndIf ⍝ Default to use all processors
      iss←#.ø¨nprocs⍴⎕THIS ⍝ Make isolates
      
      ⎕SE.SALT.Load 'HttpCommand'
      
      {}iss.{0⊣⎕FIX ⍵}⊂⎕SRC HttpCommand ⍝ Transfer HttpCommand to isolates
      pages←PapersInState state
      cap←'Processing ',(⍕≢pages),' major papers in state "',state,'"'
      freq←('CountPageChars' ''cap #.ll.EachX iss)pages
      freq←⊃+/freq
      freq←(26↑alphabet),⍪+⌿2 26⍴freq
      freq←freq[⍒freq[;2];]
     
      ⎕←'Elapsed seconds for ',state,': ',1⍕⎕AI[3]-AI3
    ∇

    ∇ pages←PapersInState state;text;ignore;txt
     ⍝ Retrieve list of home pages of major newspapers in named state
     ⍝ Thanks to USNPL.com - the US NewsPaper List
     
      text←GetPage'http://www.usnpl.com/',state,'news.php'
     
      ⍝ ↓↓↓ extract the body containing newpaper page links
      txt←(('for address downloads.'⍷text)⍳1)↓text
      txt←(5+('</div>'⍷txt)⍳1)↓txt
      txt←(¯1+('</body>'⍷txt)⍳1)↑txt
     
      pages←('(<a href=")(.*?)(.com/">)'⎕S'\2.com/')txt      ⍝ All href's to a .com
    ∇

    ∇ r←CountPageChars url;text;html
      ⍝ Return letter frequency count for a URL
     
      html←{0::'' ⋄ GetPage ⍵}url
      text←('<.*?>'⎕R'')html     ⍝ Remove all (well, lots of) HTML tags
      text←(text∊alphabet)/text  ⍝ Remove all irrelevant chars
      r←¯1+{≢⍵}⌸alphabet,text    ⍝ Frequency count
    ∇

    ∇ r←GetPage url;headers;rc;z
    ⍝ Get an HTTP page - throw any errors using ⎕SIGNAL

      z←HttpCommand.Get url
      :If 0=z.rc
         r←z.Data
      :Else
         (⍕z.(HttpStatus HttpMessage))⎕SIGNAL 11
      :EndIf
    ∇
  
:EndNamespace 
