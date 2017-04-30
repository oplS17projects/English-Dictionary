# English Dictionary

## Sokthai Tang
### April 30, 2017

 Overview
This project provides a useful and conveience way to learn engilsh. 
It interacts closly with the Oxford Dictionary API and users. 
It implements a rich feature of hash table recursion search and the history database.
---

The search feature funciton is critical to the program to find the location of the definition, 
pronounciation, example etc... from the nestest JSON file that is returned by the APIs.

The history database file is providing a way for users to play game. 
The word will be save in the file each time users searching a certain vocabulary, 
it will allow users a way to practice the word by listen to select the word and 
fill in a sentence. 

**Authorship note:** All of the code described here was written by myself.

# Libraries Used
The code uses four libraries:

```
(require net/sendurl)
(require  json)
(require racket/gui)
(require net/url (only-in srfi/13 string-contains))
```
* The "net/sendurl" is allow the program to send a remote URL to the server and download the audio file. 
* The "json" library is used to parse the replies from the Oxford Dictionary API.
* The "racket/gui" library is needed for playing the MP3 audio file. 
* The "net/url" library is used to make the URL that need to connect between the APIs and the programe. 
* The "srfi/13" library contains a "string-contains" function that is used to search if the APIs return a valid result.

# Key Code Excerpts

Here is a discussion of the most essential procedures, including a description of how they embody ideas 
Organization of Programming languages course.


## 1. Initialization Oxford Dinctionary APIs object

The following code open a port between the APIs and the program, so the user will be able to call it and make the search

```
(define app_id "app_id:da0194c3")
(define app_key "app_key:761ad80847bb97ee40842f7ecc43fade")
(define open_api "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/")
(define con-url (string->url (string-append open_api word)))
(define dict-port (get-pure-port con-url (list app_id app_key)))
(define respond (port->string dict-port))
 ```
 
## 2. Selectors and Predicates using Procedural Abstraction

The hash table is important for this function to parse the value of the (key, pair) format of hash table. 
It is being passed by a function called "readjson-from-input" that convert JSON to hash format.
The hash table provides a audio URL that can be sent to the web and download the file. 

```
(searchDict (readjson-from-input respond) '|audioFile| "audioFile:")

(define (downloadMP3 lst word)
  (if (audio? lst)
      (let* ((audioURL (cadr (soundPath lst))) 
             (fileName (string-append path word "_gb_1.mp3")))
        (if (not (file-exists? fileName))              
              (send-url (cadr (soundPath lst)))
            'ok)
        ...
  

(define (readjson-from-input var)
  (with-input-from-string var
    (lambda () (read-json))))
```
The selector procedures is required to filter the right keyword and return to the result. 
```
(define (display hash k des)
  (cond  
    ((list? (hash-ref hash k))
    ...

(define (show lst k des)
  (for (((key val) (in-hash (car lst )))) 
          (return des val))
  ...           
```
## 3. Using Recursion to search Results

The replied JSON file from the Oxford APIs is too large and there are many redundant information. 
Recursively search the file and parse the appropriate information to the user with the hash code. 

```
(define (searchDict hash k des)
  (cond ((list? hash)  (searchDict (car hash) k des))
        ((and (hash? hash) (not (empty? (hash-ref hash k (lambda () empty))))) (display hash k des))     
        (else        
         (cond ((hash? hash)              
                (for (((key val) (in-hash hash)))
                  (searchDict (hash-ref hash key) k des)))                  
               (else hash)))))
```




## 4. High order procedure. Filter the audio URL

In many cases, the Oxford Dictionary APIs does not return a consistent audios format.
It may return a list or a string of the audio file. Filter out the list and selecting only
the string in order to send to the web URL. 


```
(define (fil lst)
  (filter (lambda (x)
          (if (list? (cadr x))
              (not (and (eq? (car x) "audioFile:") (<= (string-length (caadr x)) 43)))
              ...
```

## 5. Performance and efficiency

Having the game to run smoothly and effectively is one of the main purpose of the design stage of this program.
Since the game is having users selecting the right word after the word is played, it is a better idea to have the 
audios file's name be unified. 

```
(define (rename lst)
(if (not (eq? lst ""))
      (let* ((URL (cadr (soundPath lst)))
            (originalName (substring URL 43 (string-length URL))))
        (if (not (file-exists? (string-append path (cadar result) "_gb_1.mp3")))
                  (rename-file-or-directory (string-append path originalName) (string-append path (cadar result) "_gb_1.mp3"))
                  'ok)) 'ok ))
```
