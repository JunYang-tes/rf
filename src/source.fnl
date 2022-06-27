(local types (require :signal))
(local talkback (require :talkback)) 
(local {: make-start
        : make-push
        : make-end } (require :signal))
(local {: subscribe} (require :subscribe))
(import-macros {: match-signal} :signal-m) 
(import-macros {: make-src} :source-m) 

(fn from-array [array]
  (fn [sink]
    (local size (length array)) 
    (local state {:current 1 :closed false}) 
    (sink (types.make-start
            (fn tb [signal] 
              (local ind state.current)
              (match [signal state.closed]
                [talkback.pull false] (if (<= state.current size)
                                          (do 
                                            (tset state :current (+ ind 1)) 
                                            (sink (types.make-push (. array ind) tb))) 
                                          (do (sink (types.make-end)) 
                                              (tset state :closed true))) 
                [talkback.close _] (tset state :closed true))))))) 

(fn zip [...]
  (local streams [...])
  (local size (length streams))
  (fn [sink]
    (local state {:started false :data [] :tbs [] :closed false})
    (fn zip-tb [signal]
      (if (= signal talkback.close) 
        (do (tset state :closed true))) 
      (each [i tb (ipairs state.tbs)]
        (if (< i size)
          (tb signal))) 
      (local tb 
        (or (. state.tbs size) 
            (fn []))) 
      ;; make it to be a tail call to prevent call stack overflow
      ;; in case of sync streams
      (tb signal)) 
           
                        
    (each [i src (ipairs streams)] 
      (src (fn [signal]
             (match-signal signal
               (fn [tb] 
                 (tset state.tbs i tb)
                 (if (not state.started)
                   (do 
                     (tset state :started true)
                     (sink (make-start zip-tb))) 
                   (tb talkback.pull))) 
               (fn [data tb] 
                 (if (not state.closed)
                   (do 
                     (tset state.data i data)
                     (if (= (length state.data) size)
                       (do 
                         (local data state.data)
                         (tset state :data []) 
                         (sink (make-push data zip-tb))))))) 
               (if (not state.closed)
                 (do 
                   (tset state :closed true)
                   (zip-tb talkback.close) 
                   (sink (make-end)))))))))) 

(fn merge [...] 
  (local streams [...]) 
  (local size (length streams)) 
  (fn [sink] 
    (local state {:started false :closed 0 :tbs []})
    (fn merge-tb [signal]
      (each [_ tb (ipairs state.tbs)]
        (tb signal)))
    (each [i src (ipairs streams)] 
      (src (fn [signal] 
             (match-signal signal 
               (fn [tb] 
                 (tset state :tbs i tb)
                 (if (not state.started) 
                  (do 
                    (tset state :started true) 
                    (sink (make-start merge-tb))) 
                  (tb talkback.pull))) 
               (fn [data tb] 
                 (sink (make-push data merge-tb))) 
               (do 
                 (tset state :closed (+ state.closed 1)) 
                 (if (= state.closed size) 
                     (sink (make-end)))))))))) 

(fn make-source [src push]
  (fn [sink] 
    (src (fn [signal] 
           (match-signal signal 
             (fn [tb] 
               (sink (make-start tb))) 
             (fn [data tb] 
               (push sink data tb)) 
             (sink (make-end)))))))               

{: from-array
 : make-source 
 : merge
 : zip} 
