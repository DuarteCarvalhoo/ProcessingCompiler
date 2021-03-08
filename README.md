# ProcessingCompiler
OS: Windows 10

This is how i run my program so far:
Flex begin.l
Bison -dy begin.y
gcc arvoreAST.c TabelaDeSimbolo.c lex.yy.c y.tab.c

I'm using two examples of code so far: "test1.txt" and "test2.txt". 
