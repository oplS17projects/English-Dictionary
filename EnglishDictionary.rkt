#lang racket
;joao

; What to do?
; --> have one window "create" another (parent/child frames) - done 
; --> resize windows - done
; --> design a game window/ how to position things on a window
; --> design main window
; --> append string -done
; --> print a string on the window.

(require net/url)
(require racket/gui)

(define button_enabled #t)

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
                 (search-word (send word-field get-value)))])

;; this button is initially set to false; change to true when there
;; are enough words to play a game.

(new button% [parent main_frame]
  [label "Play a game"]
  [callback (λ (button e)
              (send game_frame show #t))]
  [enabled button_enabled])

(send main_frame show #t)

(define (search-word word)
  (define url  (string->url (string-append "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/" word)))
  (define header (list app_id app_key))
  (define my-port (get-pure-port url header))
(display-pure-port my-port))