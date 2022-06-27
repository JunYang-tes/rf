(local signal {:start 0 :push 1 :end 2})

(fn view [v]
  (local f (require :fennel))
  (f.view v)) 

(fn make-signal [type data] {: type : data}) 
(fn make-start [talkback] (make-signal signal.start talkback)) 
(fn make-push [data talkback] (make-signal signal.push {: data : talkback})) 
(fn make-end [] (make-signal signal.end))

(fn inspect-signal [s]
  (match s
    {:type signal.start} "{:type start}"
    {:type signal.push : data} (.. "{:type push :data " (view data) "}") 
    {:type signal.end} "{:type end}")) 
                           
{
  : signal
  : make-start 
  : make-push 
  : make-end 
  : inspect-signal} 
 
