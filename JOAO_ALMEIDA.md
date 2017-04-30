# English Dictionary in Racket
### Joao Almeida
### April, 30th, 2017

## Project Overview.

In our project we created a software that we believe would be helpful to people trying to learn English. There were two main parts to it. First we created a GUI interface that allowed the user to type any word in a text field, and displayed that word's definition back to the user. We also allowed the user to listen the pronounciation of the word. The second part of the program was to store the user's search history, and create games that allowed the users to practice on their newly gained vocabulary.

My contribution to the code was to connect to the Oxford Dictionary API, manage the GUI interfaces (receive and display information), and manage game logic. 

## Libraries used:

The code I have contributed to the project uses:

``` (rquire net/url) 
    (require racket/gui)
```

I used the net/url library to connect to and make request to the Oxford Dictionary Library
I used the racket/gui library to create user interfaces were information was displayed to users, and also gathered from users. 

# Key Code Excerpts

Here is a discussion of the most essential procedures, including a description of how they embody ideas from UMass Lowell's COMP.3010 Organization of Programming languages course.

## 1. Recursion / Let / Higher Order Function (filter) : List -> Sublist

The following code takes a list and creates a sublist that is of length x (where x is determined by the user). The items in the sublist are picked from the original list randomly, and there are no duplicates on the sublist.

```
(define (build-sublist-r num lst)
  (if (= num 0)
      '()
      (let ((a (list-ref lst 0 (random (length lst))))) 
(cons a (build-sublist-r (- num 1 ) (filter (λ (x) (not (equal? x a))) lst))))))
```
The procedure recurses x times (where x is determined by the user). Each time it picks a random item from the list, using the built in-procedure (random x) which produces a random number, and the procedure (list-ref lst 0 x) which returns the xth elment of  list. Then it binds the random element to a local variable, using let. Then it cons that random item to the list being created in the recursion, and then it calls the function again. But when it does that it filters out the random items out of the list to ensure no duplicates. 

This is piece of code I am most proud to have written for this project. It took me almost two days of work to figure this out, and at one point I had about 30 lines of code (and a bunch of set!) doing the same work. It was neat to be able to solve a problem by combining different concepts I have learned in this semester. 

## 2. Higher Order Function (foldr): Creating a Fill-In-The-Blank Phrase

This procedure takes in a sentence, and a word. It returns a sentence, where if the word exists inside the sentence it replaces the word with the string "******"

```
(define (string->list str)
  (string-split str) )
 
(define (list->string lst)
(string-join lst) )

(define (FIB-phrase sentence answer)
  (list->string (foldr (λ (x y) (if (equal? x answer)
                     (append (list "*****") y)
(append (list x) y))) '() (string->list sentence))))
```

This procedure takes in a string (a sentence) and breakes it down into down into a list of strings. To do this I used the built in funtion (string-split str) . Then it uses foldr to build a new list. At each iteration it checks if the element from the original list is equal to the elmenet were are trying to replace with "******". If it is it appends "******", otherwise it appends the element that was tested. Then before it returns the result it transfor the newly produced list back into a string - also using a built in procedure (string-join lst).


