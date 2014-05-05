:Namespace TestIso

    (⎕IO ⎕ML)←1 1
    assert←{'Assertion failed'⎕SIGNAL(⍵=0)/11}
    
    ∇ z←Run
      r←⎕NEW ##.R
      ⎕←Basic
      ⎕←DataFrames
      ⎕←Special
      ⎕←Graphics
    ∇

    ∇ z←Basic;co2;size;time;normAPL;z
     ⍝ Take RConnect for a little spin
     
      assert'RConnect initialized'≡r.init    ⍝ Connect
      assert 3≡z←r.x'1+2'                    ⍝ Trivial expression
      assert 5 7 9≡z←r.x'⍵+⍵'(1 2 3)(4 5 6)  ⍝ Pass parameters
      assert'[1] 3'≡r.f'1+2'                 ⍝ Ask R to format the result
      assert(3 4⍴⍳12)≡r.x'matrix(1:12,3,byrow=TRUE)'  ⍝ Return matrix
      assert(,10)≡⍴r.x'rnorm(10)'                     ⍝ rnorm function working?
      size←1000000                           ⍝ Number of elements to try to transfer
      assert(,size)=⍴normAPL←r.x'rnorm(',(⍕size),',100,1)' ⍝ mean=100, sd=1
      time←3⊃⎕AI
      'normR'r.p normAPL                     ⍝ Put 100,000 numbers into an R variable in R
      assert normAPL≡z←r.g'normR'            ⍝ Check bidirectional transfer
      time←(3⊃⎕AI)-time
      ⎕←'Transfer speed = ',(' '~⍨,'CI12'⎕FMT(2×⎕SIZE'normAPL')÷1000÷time),' bytes/sec'
      assert('class'('summaryDefault' 'table')'names')≡3⍴z←(r.x'summary(normR)').attributes
      assert'[Min.1stQu.MedianMean3rdQu.Max.]'≡(z←⍕r.x'summary(normR)')[1;]~' '
      co2←r.x'co2'                           ⍝ Retrieve a TSP object
      assert'class' 'ts' 'tsp'≡z←3⍴co2.attributes
      assert 1959 1997.91666667 12≡z←⊃co2.attr[⊂'tsp']
      z←'Basic Tests Completed'
    ∇
    
    ∇ z←DataFrames;vil;data;names;mydf
      ⍝ Test dataframes are read- and writeable
     
      data←18 19 20,⍪76.1 77 78.1
      r.x'age <- 18:20' ⍝ Generate ages in R
      r.x'height <- ⍵'(data[;2]) ⍝ heights from APL
      vil←r.x'village <- data.frame(age=age,height=height)'
      assert vil.Value≡data
      assert(3 2)'data.frame'(1 2 3)('age' 'height')≡vil.attr['dim' 'class' 'row.names' 'names']
      vil.Value←data+1
      'vil'r.p vil
      assert(r.g'vil').Value≡data+1
      names←'names'('xx' 'square')
      mydf←⎕NEW ##.Rdataframe(((⍳12)∘.*1 2)names)
      assert names[2]≡mydf.attr[⊂'names']
      z←'DataFrame Tests Completed'
    ∇

    ∇ z←Special;nr;cl;an;ns;body;add
     ⍝ Test the non-Data classes
     
     ⍝ Rexpr
      assert(3J¯1 4J¯1*0.5)≡r.x'eval(⍵)'(⎕NEW ##.Rexpr(,⊂'sqrt(2+1:2-1i)'))
     
     ⍝ Rname
      'abc'r.p 1 4 3 5
      an←r.g'as.name(''abc'')'
      assert'abc'≡an.Value
      assert 1 4 3 5≡z←r.x'eval(⍵)'an
      z←'Special Class tests passed'
     
     ⍝ Rcall
      r.x ⍬'cl <- call("round", 10.5)'
      cl←r.g'cl'
      assert'round' 10.5≡z←(cl.Value[1].Value)(cl.Value[2])
      assert 10≡z←r.x'eval(⍵)'cl
      cl.Value[2]←⊂○1 2 3 ⍝ Replace the value with a vector
      assert 3 6 9≡z←r.x'eval(⍵)'cl
     
      ⍝ Rfunc
      assert ##.Rfunc≡⊃⊃⎕CLASS nr←r.x'norm'
      assert'function'≡8↑nr.Value
     
      body←'function(arg1, arg2)',(⎕UCS 13),'arg1+arg2'
      add←⎕NEW ##.Rfunc(,⊂body)
      'rconnect_test_add'r.p add
      assert 7=z←r.x'rconnect_test_add(3,4)'
      z←r.x'rm(rconnect_test_add)'
     
      ⍝ Renvr
      r.x'P1<-list2env(list(Name="Widget",Price=42))'
      r.x'P2<-list2env(list(Name="Thingy",Price=99))'
      r.x'Catalog<-list2env(list(P1=P1,P2=P2))'
      cat←r.g'Catalog' ⍝ retrieve it into APL
      assert'P1' 'P2'≡cat.Value.⎕NL-9
      assert 42 99≡cat.Value.(P1 P2).Value.Price
      assert(⊂⊂'Widget')≡(⌷cat).(⌷P1).Name ⍝ Value is the default property
     
      ns←⎕NS'' ⍝ Manufacture environment in APL
      ns.(Name Price)←'Dims' 88 ⍝ A Danish widget
      'P3'r.p ⎕NEW ##.Renvr ns
      assert'Dims' 88≡z←(r.g'P3').Value.(Name Price)
     
      z←'Special Classes Tested'
    ∇
     
    ∇ z←Graphics;x
      ⍝ Graphics
      x←¯10 10{⍺[1]++\0,⍵⍴(|-/⍺)÷⍵}50
      z←x∘.{{10×(1○⍵)÷⍵}((⍺*2)+⍵*2)*0.5}x
      r.x'persp(⍵,⍵,⍵,theta=30,phi=30,expand=0.5,xlab="X",ylab="X",zlab="Z")'x x z
      z←'Graphics Test Completed'
    ∇

:EndNamespace