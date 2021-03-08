
/*** definition section ***/

%{
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"
    #define PLACE yylloc.first_line = yylloc.last_line = yylineno, yylloc.first_column = coluna - yyleng, yylloc.last_column = coluna + strlen(yytext) - 1, coluna += yyleng;
    int flagprints = 0;
    int num_linha = 1;
    int coluna = 0;
    void count();
%}
 
%option yylineno

%X  COMENTARIO

letras              [A-Za-z_$]
alfanumericas       [A-Za-z_$0-9]
ID                  {letras}{alfanumericas}*
IMPORTSPECIAL       {letras}{alfanumericas}*"."{letras}{alfanumericas}*"."({letras}{alfanumericas}*|"*")
RESERVADO           "new"|"this"
PROSS               "setup"|"draw"|"mousePressed"
ESPACO              \f|\t|" "
BOOLLIT             "true"|"false"
INTLIT              ("+"|"-")?[0-9]+
STRINGLIT           \"(\\.|[^"\\])*\"
NOVALINHA           \r|\n|\r\n

%%

{INTLIT}    {count();PLACE;yylval.str=(char *)strdup(yytext);return(Intlit);    if(flagprints==1){printf("Intlit: %s\n", yytext);}}
{NOVALINHA} {count();PLACE;    if(flagprints==1){printf("NovaLinha\n");}}
{BOOLLIT}   {count();PLACE;yylval.str=(char *)strdup(yytext);return(Boollit);    if(flagprints==1){printf("Boollit; %s\n", yytext);}}
"&&"        {count();PLACE;return(And);    if(flagprints==1){printf("And: %s\n", yytext);}}
"="         {count();PLACE;return(Assign);    if(flagprints==1){printf("Assign: %s\n", yytext);}}
"*"         {count();PLACE;return(Multi);    if(flagprints==1){printf("Multi: %s\n", yytext);}}
","         {count();PLACE;return(Virgula);    if(flagprints==1){printf("Virgula: %s\n", yytext);}}
"/"         {count();PLACE;return(Div);    if(flagprints==1){printf("Div: %s\n", yytext);}}
"=="        {count();PLACE;return(Equivale);    if(flagprints==1){printf("Equivale: %s\n", yytext);}}
">="        {count();PLACE;return(MaiorIgual);    if(flagprints==1){printf("MaiorIgual: %s\n", yytext);}}
">"         {count();PLACE;return(Maior);    if(flagprints==1){printf("Maior: %s\n", yytext);}}
"if"        {count();PLACE;return(IF);    if(flagprints==1){printf("IF: %s\n", yytext);}}
"{"         {count();PLACE;return(ChavetaE);    if(flagprints==1){printf("ChavetaE: %s\n", yytext);}}
"<="        {count();PLACE;return(MenorIgual);    if(flagprints==1){printf("MenorIgual: %s\n", yytext);}}
"("         {count();PLACE;return(ParaE);    if(flagprints==1){printf("ParaE: %s\n", yytext);}}
"["         {count();PLACE;return(ParaRetoE);    if(flagprints==1){printf("ParaRetoE: %s\n", yytext);}}
"<"         {count();PLACE;return(Menor);    if(flagprints==1){printf("Menor: %s\n", yytext);}}
"-"         {count();PLACE;return(Menos);    if(flagprints==1){printf("Menos: %s\n", yytext);}}
"++"        {count();PLACE;return(Inc_OP);   if(flagprints==1){printf("Inc_OP: %s\n", yytext);}}
"--"        {count();PLACE;return(Dec_OP);   if(flagprints==1){printf("Dec_OP: %s\n", yytext);}}
"%"         {count();PLACE;return(MOD);    if(flagprints==1){printf("MOD: %s\n", yytext);}}
"!="        {count();PLACE;return(Diferente);    if(flagprints==1){printf("Diferente: %s\n", yytext);}}
"!"         {count();PLACE;return(NOT);    if(flagprints==1){printf("NOT: %s\n", yytext);}}
"||"        {count();PLACE;return(OR);    if(flagprints==1){printf("OR: %s\n", yytext);}}
"+"         {count();PLACE;return(Mais);    if(flagprints==1){printf("Mais: %s\n", yytext);}}
"}"         {count();PLACE;return(ChavetaD);    if(flagprints==1){printf("ChavetaD: %s\n", yytext);}}
")"         {count();PLACE;return(ParaD);    if(flagprints==1){printf("ParaD: %s\n", yytext);}}
"]"         {count();PLACE;return(ParaRetoD);    if(flagprints==1){printf("ParaRetoD: %s\n", yytext);}}
";"         {count();PLACE;return(SemiColon);    if(flagprints==1){printf("SemiColon: %s\n", yytext);}}
"boolean"   {count();PLACE;return(Boolean);    if(flagprints==1){printf("Boolean: %s\n", yytext);}}
"color"     {count();PLACE;return(Color);     if(flagprints==1){printf("Color %s\n", yytext);}}
{PROSS}     {count();PLACE;yylval.str=(char *)strdup(yytext);return(Pross);    if(flagprints==1){printf("Pross %s\n",yytext);}}
".lenght"   {count();PLACE;return(DLenght);    if(flagprints==1){printf("DLenght: %s\n", yytext);}}
"double"    {count();PLACE;return(Double);    if(flagprints==1){printf("Double: %s\n", yytext);}}
"else"      {count();PLACE;return(Else);    if(flagprints==1){printf("Else: %s\n", yytext);}}
"int"       {count();PLACE;return(Int);    if(flagprints==1){printf("Int: %s\n", yytext);}}
"return"    {count();PLACE;return(Return);    if(flagprints==1){printf("Return: %s\n");}}
"String"    {count();PLACE;return(String);    if(flagprints==1){printf("String: %s\n");}}
"void"      {count();PLACE;return(Void);    if(flagprints==1){printf("Void: %s\n", yytext);}}
"import"    {count();PLACE;return(Import);    if(flagprints==1){printf("Import %s\n", yytext);}}
"for"       {count();PLACE;return(For);    if(flagprints==1){printf("For\n");}}
"random"    {count();PLACE;return(Random);    if(flagprints==1){printf("Random\n");}}
{RESERVADO} {count();PLACE;yylval.str=(char *)strdup(yytext);return(Reservado);    if(flagprints==1){printf("Reservado: %s\n", yytext);}}
{IMPORTSPECIAL} {count();PLACE;yylval.str=(char *)strdup(yytext);return(ImportSpecial);    if(flagprints==1){printf("ImportSpecial: %s\n", yytext);}}
{ID}        {count();PLACE;yylval.str=(char *)strdup(yytext);return(Id);    if(flagprints==1){printf("Id: %s\n", yytext);}}
{ESPACO}    {count();    if(flagprints==1){printf("Espaco \n");}}

"//"                    {if(flagprints==1){printf("Comentario1Linha");}BEGIN COMENTARIO;}
<COMENTARIO>{NOVALINHA} {if(flagprints==1){printf("Nova Linha\n");}num_linha++;BEGIN 0;}
<COMENTARIO>.           {;}

{STRINGLIT} {count();yylval.str=(char *)strdup(yytext);return(Stringlit);    if(flagprints==1){printf("Stringlit: %s\n", yytext);}}

<<EOF>>     {return 0;}
.        {if(flagprints==1){printf("Error\n");}}

%%

/***C code section ***/


yywrap(){
    return(1);
}


void count(){
    int i;

    for(i=0; yytext[i] != '\0'; i++){
        if(yytext[i] == '\n'){
            coluna = 0;
            num_linha++;
        } else if(yytext[i]==" "){
            coluna++;
        } else{
            coluna++;
        }
    }
    ECHO; // ???
}


void yyerror(char *s){
    printf("\n error: Line %d, col %d: %s: %s\n", num_linha, (int)(coluna - strlen(yytext)), s, yytext);
    //printf("\n error: %s\n", yytext);
}
