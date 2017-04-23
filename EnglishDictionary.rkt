#lang racket
;joao, sokthai
;what needs to be done (joao) --> make sure to exclude words without "examples"
;                      --> make the gui "look better"

(require rsound net/sendurl)
(require  json racket/gui  net/url (only-in srfi/13 string-contains))

(define word-list (list "boy" "lamp" "book" "city" "pen" "computer"))

(define button_enabled #t)

;helper functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define right-answer "")

(define (build-sublist-r num lst)
  (if (= num 0)
      '()
      (let ((a (list-ref lst 0 (random (length lst)))))
        (cons a (build-sublist-r (- num 1 ) (filter (λ (x) (not (equal? x a))) lst))))))
      
;;try to make this more abstract : acccept n number of buttons (recursion)
(define (refresh-buttons list-of-buttons list-of-choice)
    (send (car list-of-buttons) set-label (list-ref list-of-choice 0 0))
    (send (cadr list-of-buttons) set-label (list-ref list-of-choice 0 1))
    (send (caddr list-of-buttons) set-label (list-ref list-of-choice 0 2)))

(define (refresh-msg msg label)
  (send msg set-label label))

(define (list-ref list num rdm-num)
  (if (= num rdm-num)
      (car list)
      (list-ref (cdr list) (+ num 1) rdm-num)))

(define (check-answer guess answer)
  (if (equal? guess answer)
      (display "Right")
      (display "wrong")))

(define (string->list lst)
  (string-split lst) )

(define (list->string lst)
 (string-join lst) )

(define (FIB-phrase sentence answer)
  (list->string (foldr (λ (x y) (if (equal? x answer)
                     (append (list "********") y)
                     (append (list x) y))) '() (string->list sentence))))

(define (make-player)
  (define points 0)
  (define (add-point point)
    (begin (set! points (+ points point))
            'ok))
  (define (get-points)
    points)
  (define (dispatch msg)
    (cond ((eq? msg 'add-point) add-point)
          ((eq? msg 'get-points) (get-points))))
dispatch)

(define (make-game words-at-play)
  (define answer "")
  (define choices '())

  (define (generate-choices)
    (set! choices (build-sublist-r 3 words-at-play)))

  
  (define (set-right-answer)
    (begin (set! answer (list-ref choices 0 (random 3)))))
  
  (define (refresh-game-buttons list-of-buttons)
    (refresh-buttons list-of-buttons choices))

  (define (check-answer index)
    (if (equal? answer (list-ref choices 0 index))
          1
          0))
  
  (define (get-answer)
    answer)
  
  (define (filter-answer)
    (begin (set! words-at-play (filter (λ (x) (not (equal? x answer))) words-at-play))
           'ok))
  (define (how-many-word-at-play?)
    (length words-at-play))
  
  (define (end-game? frame)
    (if (= (length words-at-play) 3)
        (send frame show #false)
        'ok))
  (define (refresh-game-msg msg)
    (refresh-msg msg (FIB-phrase
                             (list-ref (cdr (caddr (search answer))) 0 0)
                             answer)))
  
  (define (dispatch msg)
    (cond ((eq? msg 'refresh-game-buttons) refresh-game-buttons)
          ((eq? msg 'set-right-answer) (set-right-answer))
          ((eq? msg 'generate-choices) (generate-choices))
          ((eq? msg 'check-answer) check-answer)
          ((eq? msg 'filter-answer) (filter-answer))
          ((eq? msg 'how-many-word-at-play?) (how-many-word-at-play?))
          ((eq? msg 'end-game?) end-game?)
          ((eq? msg 'refresh-game-msg) refresh-game-msg)
          ((eq? msg 'get-answer) (get-answer))))
  
  
  dispatch
  )

(define game (make-game '()))
(define player (make-player))

;;; needs to "rember"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;main frame components 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define main_frame (new frame% [label "main"]
                        [height 500]
                        [width 500]))

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
  [label "Play What's the Word"]
  [callback (λ (button e)
              (begin (set! game (make-game word-list))
                     (set! player (make-player))
                     (game 'generate-choices)
                     ((game 'refresh-game-buttons) game1-buttons)
                     (game 'set-right-answer)
                     (send game_frame show #t)))]
  [enabled (>= (length word-list) 5)])


(new button% [parent main_frame]
  [label "Play Fill in the Blank"]
  [callback (λ (button e)
              (begin (set! game (make-game word-list))
                     (set! player (make-player))
                     (game 'generate-choices)
                     ((game 'refresh-game-buttons) game2-buttons)
                     (game 'set-right-answer)
                     ((game 'refresh-game-msg) phrase-msg)
                     (send game2_frame show #t)))])

(define def-msg (new message% [parent main_frame]
                      [label ""]
                      [auto-resize #t]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;game1 frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define game_frame (new frame% [label "game"]
                         [height 500]
                         [width 500]
                         [parent main_frame]))

(define game1-button1 (new button% [parent game_frame]
     [label ""]
     [callback (λ (button e)
                 ((player 'add-point) ((game 'check-answer) 0))
                 (game 'filter-answer)
                 ((game 'end-game?) game_frame)
                 (game 'generate-choices)
                 ((game 'refresh-game-buttons) game1-buttons)
                 (game 'set-right-answer))]))

(define game1-button2 (new button% [parent game_frame]
     [label "" ]
     [callback (λ (button e)
                 ((player 'add-point) ((game 'check-answer) 1))
                 (game 'filter-answer)
                 ((game 'end-game?) game_frame)
                 (game 'generate-choices)
                 ((game 'refresh-game-buttons) game1-buttons)
                 (game 'set-right-answer))]))

(define game1-button3 (new button% [parent game_frame]
     [label ""]
     [callback (λ (button e)
                 ((player 'add-point) ((game 'check-answer) 2))
                 (game 'filter-answer)
                 ((game 'end-game?) game_frame)
                 (game 'generate-choices)
                 ((game 'refresh-game-buttons) game1-buttons)
                 (game 'set-right-answer))]))

(define game-listen-word (new button% [parent game_frame]
     [label "Listen to the Word"]
     [callback (λ (button e)
                 (play-sound (string-append path (game 'get-answer) "_gb_1.mp3") #t))]))


(define game1-buttons (list game1-button1 game1-button2 game1-button3)) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;game2: "Fill in the blanks"
;       Three choices displayed in buttons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define game2_frame (new frame% [label "game 2"]
                         [height 500]
                         [width 500]
                         [parent main_frame]))

(define game2-button1 (new button% [parent game2_frame]
     [label ""]
     [callback (λ (button e)
                 ((player 'add-point) ((game 'check-answer) 0))
                 (game 'filter-answer)
                 ((game 'end-game?) game2_frame)
                 (game 'generate-choices)
                 ((game 'refresh-game-buttons) game2-buttons)
                 ((game 'refresh-game-msg) phrase-msg)
                 (game 'set-right-answer))]))

(define game2-button2 (new button% [parent game2_frame]
     [label "" ]
     [callback (λ (button e)
                 ((player 'add-point) ((game 'check-answer) 0))
                 (game 'filter-answer)
                 ((game 'end-game?) game2_frame)
                 (game 'generate-choices)
                 ((game 'refresh-game-buttons) game2-buttons)
                 ((game 'refresh-game-msg) phrase-msg)
                 (game 'set-right-answer))]))

(define game2-button3 (new button% [parent game2_frame]
     [label ""]
     [callback (λ (button e)
                 ((player 'add-point) ((game 'check-answer) 0))
                 (game 'filter-answer)
                 ((game 'end-game?) game2_frame)
                 (game 'generate-choices)
                 ((game 'refresh-game-buttons) game2-buttons)
                 ((game 'refresh-game-msg) phrase-msg)
                 (game 'set-right-answer))]))

(define phrase-msg (new message% [parent game2_frame]
                      [label ""]
                      [auto-resize #t]))

(define game2-buttons (list game2-button1 game2-button2 game2-button3)) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;game1: a button will play a sound
;;      three button each a choice
;;      this will need to be inside an object --->make-a-window

;;game2: fill in the blank
;;       filter an example gvien by oxford dictionary
;;       give 3 options as buttons 

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
(define winPath "C:\\Users\\joaocarlos\\Downloads\\") ; path for widnow
(define ubuPath "/home/joao/Downloads/") ; path for ubuntu
(define history (list))
(define path winPath)
(define wordList "wordList")

(define (search word)
  (set! result "")
  (define con-url (string->url (string-append open_api word)))
  (define dict-port (get-pure-port con-url (list app_id app_key)))
  (define respond (port->string dict-port))
  (close-input-port dict-port)
  
  (cond ((number? (string-contains respond "404 Not Found")) (set! result (list (list "Error:" (string-append "Not Found: " word)))))
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
           (write-to-file word wordList)
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


 (define (write-to-file data path) 
   (with-output-to-file path 
     (lambda () 
       (write data)) #:exists 'append))


(define (read-from-file path)
  (file->list path))
