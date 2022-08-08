(local -folder (-> ...
                   (: :match "(.-)[^%.]+$"))) 
(fn lrequire [name] (require (.. -folder name)))

(import-macros {: match-signal } :signal-m)
(local talkback (lrequire :talkback)) 
(fn subscribe [src next close]
  (local state {:tb (fn []) :closed false})
  (src (fn [tb-signal]
         (match-signal
           tb-signal
           (fn [tb] 
             (tset state :tb tb)
             (tb talkback.pull)) 
              
           (fn [data] 
             (if (not state.closed) 
               (do
                (next data) 
                (state.tb talkback.pull)))) 
           (do
             (tset state :closed true) 
             ((or close #nil)))))) 
  (fn unscribescribe []
    (if (not state.close) 
        (do (tset state :closed true) 
            (state.tb talkback.close))))) 

{ : subscribe} 
