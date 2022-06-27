(import-macros {: match-signal } :signal-m)

(fn make-src [state push]
  `(fn [src#] 
    (local {:make-start make-start# 
            :make-end make-end#} (require :signal)) 
    (local s# (require :signal))
    (fn [sink#] 
      ,state 
      (src# (fn [signal#] 
              (match signal# 
                {:type s#.signal.start :data tb#} (sink# (make-start# tb#)) 
                {:type s#.signal.push :data data#} (,push sink# data#.data data#.talkback) 
                {:type s#.signal.end } (sink# (make-end#)))))))) 
                
{ : make-src}                               
