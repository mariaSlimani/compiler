# Compiler
Compiler created during school project.
It compiles a code according to the language described in the Language.pdf file
# How to run it 
### `lex scanner.lex`
### `yacc -d parser.y`
### `cc -o compiler y.tab.c lex.yy.c -ll`
### `./compiler < input.txt`
### The Result will be in output.txt
## scanner.lex
Contains the code for the lexical analysis.
It contains :
- the grammars of all the words and the definitions of the keywords that the compiler must recognize
- Production rules
## tsbib.h
Contains the structure of the symbol table and its fields (name, type, state, size and value), as well as the various functions and methods that will allow us to keep track of all the variables, functions and structures manipulated in the program.
- When defining an id, we insert an entry in the symbol table, the declaration of an id is unique so we must check its existence beforehand.
- When an id is used in the program, we look for the corresponding entry in the symbol table and insert it

we have defined the following operations:
● Insert a name in the table
● Show table
● Determine if a name already exists in the table
● Insert name information
● Retrieve type and value

## parser.y
Contains the code for the syntactic analysis as well as the semantic analysis.
- It contains the definition of the tokens and production rules
- It contains the semantic tests on the variables
