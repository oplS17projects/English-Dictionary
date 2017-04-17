#lang racket
;joao, sokthai


; What to do?
; --> learn github
; --> have one window "create" another (parent/child frames) - done 
; --> resize windows - done
; --> design a game window/ how to position things on a window, choose random choices - done
; --> design main window -  
; --> append string -done
; --> print a string on the window.

(require net/url net/sendurl)
(require racket/gui (only-in srfi/13 string-constains) json)
(define word-list (list "one" "two" "three" "four" "five" "six" "seven" "eight" "nine" "ten"))

(define button_enabled #t)
(define open_api "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/")
(define app_id  "app_id: 7b58b972")
(define app_key "app_key: b70c1d9cbbc48700a36ac012292c533c")

(define main_frame (new frame% [label "main"]
                        [height 500]
                        [width 500]))

(define game_frame (new frame% [label "game"]
                         [height 500]
                         [width 500]
                         [parent main_frame]))

(define word-field (new text-field% [parent main_frame]
[label "word:"]))

(new button% [parent main_frame]
     [label "Search a word"]
     [callback (λ (button e)
                 (new message% [label (search-word (send word-field get-value))]
                      [parent main_frame]))])

;; this button is initially set to false; change to true when there
;; are enough words to play a game.

(new button% [parent main_frame]
  [label "Play a game"]
  [callback (λ (button e)
              (send game_frame show #t))]
  [enabled button_enabled])

;;;;; create a random num in between 0 and (upper-bound - 1)

(define (create-rdm-num upper-bound) 
   (modulo (eval (date-second (seconds->date(current-seconds)))) upper-bound))

;;; create a list with 3 possible answers
(define (possible-answ list num rdm-num)
  (if (= num rdm-num)
      (car list)
      (possible-answ (cdr list) (+ num 1) rdm-num)))


(new button% [parent game_frame]
     [label (possible-answ word-list 0 1)]
     [callback (λ (button e)
                 1)])

(new button% [parent game_frame]
     [label (possible-answ word-list 0 1) ]
     [callback (λ (button e)
                 1)])

(new button% [parent game_frame]
     [label (possible-answ word-list 0 1)]
     [callback (λ (button e)
                 1)])

;;why is this giving me an error?
;(new button% [parent game_frame]
;     [label (possible-answ word-list 0 (create-rdm-num 10))]
;    [callback (λ (button e)
;                 1)])



(send main_frame show #t)

(define (search-word word)
  (string-append word " was searched"))



;------------
(define word "")
;(define app_id "app_id:da0194c3")
;(define app_key "app_key:761ad80847bb97ee40842f7ecc43fade")
;(define open_api "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/")



;(define myrespond "")

(define file-path "C:\\Users\\sokthai\\Downloads/")
(define sound-url "")
(define result "")


(define macPath "/Users/sokthaitang/downloads/") ; path for mac
(define winPath "C:\\Users\\thai\\Downloads\\") ; path for widnow
(define ubuPath "/home/thai/Downloads/") ; pat for ubuntu


(define (search w)

  
  ;(define result "")
  (set! result "")
  (define con-url (string->url (string-append open_api w)))
  (define dict-port (get-pure-port con-url (list app_id app_key)))
  (define respond (port->string dict-port))
  ;(set! myrespond respond)
  (close-input-port dict-port)
  
  (cond ((number? (string-contains respond "404 Not Found")) (set! result (list (list "Error:" "Not Found"))))
        (else
         (searchDict (readjson-from-input respond) '|word| "word:")
         (searchDict (readjson-from-input respond) '|definitions| "definitions:")
         (searchDict (readjson-from-input respond) '|examples| "examples:")
         (searchDict (readjson-from-input respond) '|audioFile| "pronunciation:")
         (let* ((audioURL (soundPath result)) 
                (fileName (string-append macPath
                                       (substring audioURL 43 (string-length audioURL)))))
           (if (not (file-exists? fileName))
               (send-url (soundPath result))
               'ok)
         )
  ))
  result
)




(define (readjson-from-input var)
  (with-input-from-string var
    (lambda () (read-json)))
      
  )



(define (searchDict hash k des)
  (cond ((list? hash)  (searchDict (car hash) k des))
        ((and (hash? hash) (not (empty? (hash-ref hash k (lambda () empty))))) (display hash k des))     
        (else        
         (cond ((hash? hash)              
                (for (((key val) (in-hash hash)))
                  (searchDict (hash-ref hash key) k des)))                  
               (else hash)))))




(define (display hash k des)
  (cond  
    ((list? (hash-ref hash k))
     (cond
    
       ((string? (car (hash-ref hash k))) (return  des (car (hash-ref hash k))))
       (else
        (show (hash-ref hash k) k des))))
    
    (else (return  des (hash-ref hash k (lambda () ""))))
  )
)




(define (return des content )
  
  (if (list? result)
      (set! result (append result (list (list des content))))
      (set! result (list (list des content))))
  
  
)
  

(define (show lst k des)

  (cond ((null? lst) lst)
        (else
         (for (((key val) (in-hash (car lst )))) 
          (return des val)
           )

         (show (cdr lst) k des)
         ))
  )




(module file-player racket/base
   (require racket/system)
   (define player (find-executable-path "xmms"))
   (define (play file)
     (system* player (if (path? file) (path->string file) file)))
   (provide play))




;-----play mp3


(define (soundPath lst)
  
  (if (and (list? lst) (null? (cdr lst))) 
      (cadr (car lst))
      (soundPath (cdr lst)))
)


(define (pronounce lst)
  (let ((audioURL (soundPath lst)))
    (cond  ((equal? lst "") '())
           (else
            (play-sound
               (string-append macPath
                                       (substring audioURL 43
                                                  (string-length audioURL))) #t)))
 )
  )

