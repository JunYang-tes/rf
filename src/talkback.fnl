(local talkback {:pull 0 :close 1})
(fn make-pull [] talkback.pull) 
(fn make-close [] talkback.close)

(fn view [value]
  (match value 
    0 "Pull" 
    1 "Close" 
    _ "Not a talkback signal")) 

{
 :pull 0 
 :close 1 
 : view
 : make-pull 
 : make-close} 
 
