#lang racket
;joao, sokthai


(require rsound net/sendurl)
(require  json racket/gui  net/url (only-in srfi/13 string-contains))

(define word-list (list "boy" "lamp" "book" "city" "pen" "computer"))

(define button_enabled #t)


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
                 (send def-msg set-label (cadr (cadr (search (send word-field get-value))))))])


(new button% [parent main_frame]
     [label "Listen to Pronounciation"]
     [callback (λ (button e)
                 (pronounce result))])

(new button% [parent main_frame]
  [label "Play a game"]
  [callback (λ (button e)
              (send game_frame show #t))]
  [enabled button_enabled])

(define def-msg (new message% [parent main_frame]
                      [label ""]
                      [auto-resize #t]))
;;game: a button will play a sound
;;      three button each a choice
;;      this will need to be inside an object --->make-a-window

(define right-answer "")

(define list-of-answers word-list)

(define (get-right-answer)
  (begin (set! right-answer (list-ref list-of-answers 0 (random (length list-of-answers))))
         (set! list-of-answers (filter (λ (x) (not (equal? x right-answer))) list-of-answers))
         list-of-answers))

(define (generate-list-of-choices word lst)
  (append (list right-answer)
          (list (list-ref (filter (λ (x) (not (equal? x right-answer))) word-list) 0 (random (- (length word-list) 1))))
          (list (list-ref (filter (λ (x) (not (equal? x right-answer))) word-list) 0 (random (- (length word-list) 1))))))

;; duplicates can still happen here
(define (refresh-buttons)
  (let ((a (generate-list-of-choices right-answer word-list)))
          (send game-button1 set-label (list-ref a 0 (random (length a))))
          (send game-button2 set-label (list-ref a 0 (random (length a))))
          (send game-button3 set-label (list-ref a 0 (random (length a))))))

(define (list-ref list num rdm-num)
  (if (= num rdm-num)
      (car list)
      (list-ref (cdr list) (+ num 1) rdm-num)))

(define game-button1 (new button% [parent game_frame]
     [label (list-ref word-list 0 (random (length word-list)))]
     [callback (λ (button e)
                 (begin (get-right-answer)
                        (refresh-buttons)))]))

(define game-button2 (new button% [parent game_frame]
     [label (list-ref word-list 0 (random (length word-list))) ]
     [callback (λ (button e)
                 (begin (get-right-answer)
                        (refresh-buttons)))]))

(define game-button3 (new button% [parent game_frame]
     [label (list-ref word-list 0 (random (length word-list)))]
     [callback (λ (button e)
                 (begin (get-right-answer)
                        (refresh-buttons)))]))

(define game-listen-word (new button% [parent game_frame]
     [label "Listen to the Word"]
     [callback (λ (button e)
                 (play-sound (string-append path right-answer "_gb_1.mp3") #t))]))

(send main_frame show #t)




;------------
(define word "")
(define app_id "app_id:da0194c3")
(define app_key "app_key:761ad80847bb97ee40842f7ecc43fade")
(define open_api "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/")

(define file-path "C:\\Users\\sokthai\\Downloads/")
(define sound-url "")
(define result "")

(define macPath "/Users/sokthaitang/downloads/") ; path for mac
(define winPath "C:\\Users\\thai\\Downloads\\") ; path for widnow
(define ubuPath "/home/joao/Downloads/") ; pat for ubuntu
(define path ubuPath)

(define (search w)
  (set! result "")
  (define con-url (string->url (string-append open_api w)))
  (define dict-port (get-pure-port con-url (list app_id app_key)))
  (define respond (port->string dict-port))
  (close-input-port dict-port)
  
  (cond ((number? (string-contains respond "404 Not Found")) (set! result (list (list "Error:" "Not Found"))))
        (else
         (searchDict (readjson-from-input respond) '|word| "word:")
         (searchDict (readjson-from-input respond) '|definitions| "definitions:")
         (searchDict (readjson-from-input respond) '|examples| "examples:")
         (searchDict (readjson-from-input respond) '|audioFile| "pronunciation:")
         (let* ((audioURL (soundPath result)) 
                (fileName (string-append path
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
    (lambda () (read-json))))

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

(define (soundPath lst)
  
  (if (and (list? lst) (null? (cdr lst))) 
      (cadr (car lst))
      (soundPath (cdr lst)))
)


(define (pronounce lst)
  (let ((audioURL (soundPath lst)))
    (cond  ((equal? (caar lst) "Error:") '())
           (else
            (play-sound
               (string-append path (substring audioURL 43 (string-length audioURL))) #t)))))

