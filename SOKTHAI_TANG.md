# English-Dictionary

### Statement
We created an app to help non-native English speakers to improve their language skills. We are both non-native speakers and we made some of the tricks that helped us learn English more convinient, using our cs knowledge. 

### Analysis

We used data abstraction to implement the game - keep track of the right answers, and accumulate the points from the user's right answers. 

We used two high order functions (filter and accumulate) to implement the game logic.

We used recursion to parse the received information, and also in the game logic

We used object-orientation to represent the users progress in the game and the game being, this include state-modification.  


### External Technologies
We used the Oxford Dictionary API to access their database.

### Data Sets or other Source Materials
We received from the Oxford Api, a database query and parsed the information using JSON (https://developer.oxforddictionaries.com/)

### Deliverable and Demonstration
We delivered a software that helps non-native English speakers improve their language skills. It consists of two parts. First, we created an interface that displays the definition of a word, requested by the user. In the second part we used the user search history to create games that will allow the user to practice on their newly acquired vocabulary. 

### Evaluation of Results
Our project was successful. We were able to integrate all three parts (GUI, API, data), and run it smothly. That means that a "non-technical" and with limited English language knowledge person can use it, and find it helpful. 

## Architecture Diagram
![alt_tag](https://github.com/oplS17projects/English-Dictionary/blob/master/flow-chart.png)

First we created a gui interface to let user enter a word she/he wants to search. Then we send a request the Oxford API. We receive the dictionary entry of the word, and parse it using it JSON. Then we display the definition of the word in a gui interface, and save the user's search history. Lastly, we use the user's search history to play games. 

## Schedule

### First Milestone (Sun Apr 9)
Joao: Get the GUI up and running (multiple windows, display) 
Sokthai: Figure out RSound library.

### Second Milestone (Sun Apr 16)
Joao: Design the game
Sokthai: Store user's history

### Public Presentation (Mon Apr 24, Wed Apr 26, or Fri Apr 28 [your date to be determined later])
Integrate all three parts

## Group Responsibilities

### Sokthai Tang @sokthai 
Parse information, Rsound, search history

### Joao Almeida @joaoccanto
GUI, connect to API, design game

### Accomplishments:
### Sokthai Tang @sokthai
Parse the received information
Download and play the mp3 files (rsound)
Save and manage the search history

### Joao Almeida
Connecte to the API
Designed GUI interface: main window, progress window, and two game windows
Designed game logic - (no duplicate choices, no duplicate answers, keep player's socres)


