% Name: Dawei Xu
% ID: 
% Description: This is my version for Prolog Project4. The methodology
% is quite straightforward, which is shooting at any new place, until
% hit the wumpus. The program won't shoot at any same direction. I do 
% come up with many new ways to optimize, but I really do not have enough 
% time for that. It is a little bit tricky for new comer.

:- module(wumpus,[initialState/5, guess/3,updateState/4]).

% initialState is to build a 2 dimensions array which is a list of lists
% to store the map information, and mark the start point.
initialState(NR,NC,XS,YS,State0):- 
	length(InitialMap,NR),
	length(Column,NC),
	maplist(same_length(Column),InitialMap),
	maplist(isEmpty,InitialMap),
	markPosition(InitialMap,XS,YS,start,Map),
	append([Map],[[],1],State0).

% Mark the whole map to e which means empty.
isEmpty([]).
isEmpty([e|Tail]) :- isEmpty(Tail).

% Function to mark a position in a map, and
% returns the NewMap.
markPosition(Map,X,Y,Value,NewMap) :- 
	Y0 is Y-1,
	X0 is X-1,
	length(A,Y0),
	length(C,X0),
	append(A,[Row|B],Map),
	append(C,[_|D],Row),
	append(C,[Value|D],NewRow),
	append(A,[NewRow|B],NewMap).

% Function to make a guess, if the guess
% already exists or is the same direction with
% Failed guess, then guess again.
guess(State0,State,Guess) :- 
	((append([Map],[Failed,Length],State0),
	append(State0,[],State),
	length(Guess,Length),
	append(A,[shoot],Guess),
	guessMoves(A),
	getIndex(Map,start,X,Y),
	validGuess(Map,X,Y,A),
	\+member(Guess,Failed),
	\+sameDirection(Failed,Guess)) ->
	writeln(Guess);
	(append([Map],[Failed,Length],State0),
	length(WrongGuess,Length),
	append(A,[shoot],WrongGuess),
	guessMoves(A),
	getIndex(Map,start,X,Y),
	validGuess(Map,X,Y,A),
	\+member(WrongGuess,Failed),
	sameDirection(Failed,WrongGuess)) ->
	append(Failed,[WrongGuess],NewFailed),
	writeln(NewFailed),
	NewLength is Length+1,
	guess([Map,NewFailed,NewLength],State,Guess);
	append([Map],[Failed,Length],State0),
	NewLength is Length+1,
	guess([Map,Failed,NewLength],State,Guess)).

% Used to guess Moves.
guessMoves([]).
guessMoves([A|B]) :- 
	(B=[] ->
	(A=north;A=south;A=west;A=east);
	(A=north;A=south;A=west;A=east),
	guessMoves(B)).

% Function to return the Index of an Element.
getIndex(Map,Elt,X,Y) :- 
	nth1(Y,Map,Row),
	nth1(X,Row,Elt).

% Function to determine if the Guess is the 
% same direction with any guess in Failed.
sameDirection(Failed,Guess) :-
	(append(Moves,[shoot],Guess),
	append(A,[Move],Moves),
	append(_,[Move],A),
	append(A,[shoot],B),
	member(B,Failed));
	(append(Moves,[shoot],Guess),
	append(A,[Move],Moves),
	append(B,[Move],A),
	append(_,[Move],B),
	append(B,[shoot],C),
	member(C,Failed)).

% To determine if a guess is valid.		
validGuess(_,_,_,[]).
validGuess(Map,X,Y,Guess) :- 
	append([Move],Rest,Guess),
	(
	Move=north ->
		X1 is X,Y1 is Y-1;
	Move=south ->
		X1 is X,Y1 is Y+1;
	Move=west ->
		X1 is X-1,Y1 is Y;
	Move=east ->
		X1 is X+1, Y1 is Y),
	validPosition(Map,X1,Y1),
	getIndex(Map,e,X1,Y1), 
	markPosition(Map,X1,Y1,start,NewMap),
	validGuess(NewMap,X1,Y1,Rest).

% To determine if an index is within a map.
validPosition(Map,X,Y) :- 
	X>0,
	Y>0,
	length(Map,Rows),
	nth1(1,Map,Row),
	length(Row,Columns),
	X=<Columns,
	Y=<Rows.

% Update the map. return State, which includes
% Map, Failed Guess and Length of Guess.
updateState(State0,Guess,Feedback,State) :- 
	append([Map],[Failed,Length],State0),
	append(HeadFeedbacks,[LastFeedback],Feedback),
	append(Moves,[shoot],Guess),
	getIndex(Map,start,X,Y),
	(LastFeedback=miss ->
		updateMap(Map,Moves,HeadFeedbacks,X,Y,NewMap),
		writeln(NewMap);
		updateMap(Map,Guess,Feedback,X,Y,NewMap),
		writeln(NewMap)),
	append(Failed,[Guess],NewFailed),
	append([NewMap],[NewFailed,Length],State).
	
% Function to update the Map.
updateMap(Map,Guess,Feedback,X,Y,NewMap) :- 
	(length(Feedback,0) ->
		append(Map,[],NewMap);
	append([A],B,Guess),
	append([C],D,Feedback),
	tempIndex(A,X,Y,X1,Y1),
	nextIndex(C,X,Y,X1,Y1,NextX,NextY,Value),
	(validPosition(Map,X1,Y1) ->
	markPosition(Map,X1,Y1,Value,TempMap),
	updateMap(TempMap,B,D,NextX,NextY,NewMap);
	updateMap(Map,B,D,NextX,NextY,NewMap))).

% Next index after a move, may be not valid.
tempIndex(Move,X,Y,X1,Y1) :-
	(Move = north ->
		X1 is X,Y1 is Y-1;
	 Move = south ->
	 	X1 is X,Y1 is Y+1;
	 Move = west ->
	 	X1 is X-1,Y1 is Y;
	 Move = east ->
	 	X1 is X+1, Y1 is Y).

% The actual Index after a move.
nextIndex(Feedback,X,Y,X1,Y1,NextX,NextY,Value) :-
	(Feedback = pit ->
	Value = p,NextX is X,NextY is Y;
	Feedback = wall ->
	Value = #,NextX is X,NextY is Y;
	Feedback = wumpus ->
	Value = w,NextX is X,NextY is Y;
	Value = e,NextX is X1,NextY is Y1).
