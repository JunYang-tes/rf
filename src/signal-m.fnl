
(fn match-signal [signal start push end]
  (local s (require :signal))
  `(match ,signal
     {:type ,s.signal.start :data data#} (,start data#)
     {:type ,s.signal.push :data data# } (,push data#.data data#.talkback) 
     {:type ,s.signal.end} ,end)) 

{: match-signal}                        
