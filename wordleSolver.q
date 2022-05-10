lst:read0 `wordleList.txt;
wordleList:"," vs ssr/[raze lst;("\"";" ");("";"")];

getResult:{[guess;answer]
	// Function should take in a guess, check against answer and return the guess pattern
	near: ?[guess in\: answer;1;0nj];
	exact: ?[guess = answer;2;0nj];
	res: near ^ exact
	};
// getResult["weary";"wordy"]

getPatterns:{[guess;list]
	// show the match distribution of a guess against a list of possible answers
	res:asc each list@group getResult/:[guess;list];
	kres:asc key res;
	kres#res
	};
//getPatterns["weary";wordleList][2 0N 0N 1 2]


getPatternProbabilities:{[guess;list]
	// show the probabbility distribution of a guess against a list of possible answers
	desc (1%count list)*count each group getResult/:[guess;list]
	};
// getPatternProbabilities["weary";wordleList][2 0N 0N 1 2]

getInformationValue:{[guess;list;pattern]
	// Information theory
	// get the information of a possible pattttern
	// I(x) = -log_2(p(x))
	neg 2 xlog getPatternProbabilities[guess;list][pattern]
	};
// getInformationValue["weary";wordleList;2 0N 0N 1 2]

entropy:{[guess;list]
	// Return the amount of information expected from a guess
	// SUM_x[p[x]*I(x)]
	// I(x) = -log_2(p(x))
	patterns:getPatternProbabilities[guess;list];
	information:neg 2 xlog patterns;
	sum patterns*information
	};
// entropy["weary";wordleList]

getListEntropy:{[list]
	// get entropy of each word in list
	desc list!entropy\:[list;list]
	};

guess:{[guess;answer;list]
	pattern: getResult[guess;answer];
	possibleAnswers:getPatterns[guess;list][pattern];
	entropies:getListEntropy[list];
	bestGuess:{x?max x}[entropies];
	$[1 = count entropies;bestGuess;.z.s[bestGuess;answer;possibleAnswers]]
	};
// guess["weary";"wordy";wordleList]

reset:{
	.wordle.entropy.current:.wordle.entropy.init;
	.wordle.entropy.all:enlist .wordle.entropy.current;
	.wordle.list.current:.wordle.list.init;
	.wordle.list.all: enlist asc .wordle.list.init;
	.wordle.guess.current:"";
	.wordle.guess.all:enlist"";
	.wordle.pattern.current:`long$();
	.wordle.pattern.all:enlist `long$();
	.wordle.guess.best:{x?max x}[.wordle.entropy.current];
	.wordle.answer:raze 1? .wordle.list.init;
	};
// reset[]

init:{[list]
	// init the wordle solve instance
	show "Calculating best guesses, please wait";
	.wordle.list.init:list;
	.wordle.entropy.init:getListEntropy .wordle.list.init;
	reset[];
	show "done"
	};
// init wordleList

top5guess:{5 sublist .wordle.entropy.current};

nextGuess:{.wordle.guess.best};

solve:{[guess]
	solve0[guess;.wordle.answer]

	};

solve0:{[guess;answer]
	res:getResult[guess;answer];
	updateGuess[guess;res];
	.wordle.guess.best
	};

// solve/["raise"]
showSolution:{[guess]
	res:solve/[guess];
	state:-6_showState[];
	state,:enlist "Answer: ", .wordle.answer;
	state,:enlist "Guesses: ",", " sv 1_.wordle.guess.all;
	state,:enlist "Score: ", string count 1_.wordle.guess.all;
	state
	};
// showSolution["raise"]

updateGuess:{[guess;pattern]

	.wordle.guess.current:guess;
	.wordle.guess.all,:enlist guess;
	.wordle.pattern.current:pattern;
	.wordle.pattern.all,:enlist pattern;
	.wordle.list.current:getPatterns[guess; .wordle.list.current][pattern];
	.wordle.list.all,:enlist .wordle.list.current;
	.wordle.entropy.current:getListEntropy .wordle.list.current;
	.wordle.entropy.all,:enlist .wordle.entropy.current;
	.wordle.entropy.best: enlist[.wordle.guess.best] ! enlist .wordle.entropy.current @.wordle.guess.best;
	.wordle.guess.best:{x?max x}[.wordle.entropy.current];
	showState[]
	};

// How to use:
// pull in a list of words into process
// run init list
// use solve to input 

// begin script
show  each ("Wordle Solver by Rian Morgan";"How to use:");
try:{[guess]
	// INPUT @param guess - user guess
	// OUTPUT board state, top 5 next guesses
	
	// Word validity checks
	if[any ("";`) like\: (),guess;:top5guess[]];
	if[5 <> count guess;:"Please guess a 5 letter word"];
	if[not guess in .wordle.list.init;:"Word not in list, try again."];
	showState[]
	};
// try[""]


showState:{
	// show current state
	numGuess:max 1,-1+count .wordle.pattern.all;
	pattern:{(raze"|",'ssr[raze string 0^x;"0";" "]),"|"}'[1_.wordle.pattern.all];
	words:{(raze"|",'x),"|"}'[1_.wordle.guess.all];
	res:raze flip numGuess cut words,pattern,numGuess#enlist "___________";
	res:res,enlist "  ";
	res:res,enlist "Top 5 guesses:";
	-1 res, {key[x],'value[x]}": ",/:string top5guess[];

	};


guess0:{[x]
	pattern: getResult[x[0];x[1]];
	possibleAnswers:getPatterns[x[0];x[2]][pattern];
	entropies:$[x[3]=0;.wordle.entropy.init;getListEntropy[x[2]]];
	bestGuess:{x?max x}[entropies];
	(bestGuess;x[1];possibleAnswers;$[all pattern = 2 2 2 2 2;x[3];x[3]+1])
	};

	//count each {guess0\[(x;"wordy";wordleList;0)]}'[ (5#wordleList)][;;0]

	//guess0\[("raise";"wordy";wordleList;0)]

test:{
	show "format guess (\"raise\";0N 0N 1 2 1)";
	show "Enter guess:";
	.rian.guess:guess:read0 0;
	show "Enter pattern:";
	.rian.pattern:pattern:"I"$read0 0;
	list:getPatterns[guess;wordleList] pattern;
	list

	
	};

init[wordleList];