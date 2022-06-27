(local {: make-start
        : make-push
        : make-end } (require :signal))
(local talkback (require :talkback)) 
(local {: make-source } (require :source))
(import-macros {: match-signal } :signal-m)
(import-macros {: make-src } :source-m) 

;; (fn map [src f]
;;   (fn [sink] 
;;     (src (fn [signal] 
;;            (match-signal signal
;;              (fn [tb] 
;;                (sink (make-start tb))) 
;;              (fn [data tb] 
;;                (sink (make-push (f data) tb))) 
;;              (sink (make-end))))))) 

(fn map [src f]
  (-> src 
      (make-source 
        (fn [sink data tb] 
          (sink (make-push (f data) tb)))))) 

(fn filter [src f]
  (-> src 
      (make-source 
        (fn [sink data tb] 
          (if (f data) 
            (sink (make-push data tb)) 
            (tb talkback.pull)))))) 

(fn skip [src count]
  (local t
   (make-src 
      (local state {:skipped 0}) 
      (fn [sink data tb] 
        (if (< state.skipped count) 
          (do 
            (tset state :skipped (+ state.skipped 1))
            (tb talkback.pull))
          (sink (make-push data tb)))))) 
  (t src)) 

(fn scan [src f initial]
  (local t (make-src 
             (local state {:data initial}) 
             (fn [sink data tb] 
               (tset state :data (f state.data data)) 
               (sink (make-push state.data tb)))))
  (t src)) 

{ 
 : map
 : filter 
 : scan 
 : skip} 
