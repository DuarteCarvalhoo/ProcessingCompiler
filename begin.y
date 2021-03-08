%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <math.h>
    #include <unistd.h>
    #include "arvoreAST.h"


    void yyerror(char *s);

    struct no *root = NULL;
    extern elementos_tabela *tabela_global;
    int yylex_destroy();
    void yyerror(char *s);

    char *tipoaux;

%}

%locations

%start Start

%union{
    char *str;
    struct no* no;
}

%token  Dec_OP Inc_OP
%token  And Assign Multi Virgula Div Equivale MaiorIgual Maior IF ChavetaE MenorIgual ParaE ParaRetoE Menor Menos MOD Diferente NOT OR Mais ChavetaD ParaD ParaRetoD
%token  SemiColon Boolean Color DLenght Double Else Int Random Return
%token  String Void Import For

%token <str> Intlit Boollit MetodosCall Reservado Id Stringlit ImportSpecial Pross

%type <no> Start Begin ImportLib MethodDecl VarDecl VarDeclBody Statement StatementBody TIPO VariavelGlobal VariavelGlobalAux Program ForAux Expr


%left Virgula
%right Assign
%left OR
%left And
%left Diferente Equivale
%left MaiorIgual MenorIgual Menor Maior
%left Mais Menos
%left Multi Div MOD
%right NOT
%left ParaRetoD ParaRetoE ParaD ParaE

%nonassoc IF
%nonassoc Else

%%

Start:  Begin Start             {   
                                    if(root != NULL){
                                        /*if($2 != NULL){
                                            add_bro($1,$2);
                                        }
                                        $$ = $1;*/
                                        $$ = filho(root,$1);
                                    } else{
                                        root = criar("Start", "", 0, 0);
                                        filho(root, $1);
                                        $$ = root;
                                    }
                                }                                  
    |   ImportLib Start         { 
                                    if(root != NULL){
                                        /*if($2 != NULL){
                                            add_bro($1,$2);
                                        }
                                        $$ = $1;*/
                                        $$ = filho(root,$1);
                                    } else{
                                        root = criar("Start", "", 0, 0);
                                        filho(root, $1);
                                        $$ = root;
                                    }
                                }                                      
    |   VariavelGlobal Start    {   
                                    if(root != NULL){
                                        $$ = filho(root,$1);
                                        /*printf("I'm VAR \n");
                                        if($2 != NULL){
                                            add_bro($2,$1);
                                        }
                                        printf("root what? %s\n", root->bros[0]);
                                        $$ = $1;*/
                                    } else{
                                        root = criar("Start", "", 0, 0);
                                        filho(root, $1);
                                        $$ = root;
                                    }
                                }                                      
    |   MethodDecl Start        { 
                                    if(root != NULL){
                                        /*if($2 != NULL){
                                            printf("Metodo\n");
                                            add_bro($1,$2);
                                        }
                                        $$ = $1;*/
                                        $$ = filho(root,$1);
                                    } else{
                                        root = criar("Start", "", 0, 0);
                                        filho(root, $1);
                                        $$ = root;
                                    }
                                }                            
    |   /* vazio */             {$$ = NULL;}                                              
    ;

Begin:  Void Pross ParaE ParaD ChavetaE Program ChavetaD    {
                                                                //printf(" --> funcao especifica do pross\n");
                                                                struct no *begin = criar("Begin", "", 0, 0);
                                                                struct no *idPross = criar("Void", $2, @2.first_line, @2.first_column);
                                                                filho(begin, idPross);
                                                                filho(begin, $6);
                                                                add_bro(idPross, $6);
                                                                $$ = begin;
                                                            }
    ;


ImportLib: Import ImportSpecial SemiColon       {
                                                    struct no *importLib = criar("ImportLib", "",0,0);
                                                    struct no *importString = criar("ImportSpecial", $2,@2.first_line, @2.first_column);
                                                    filho(importLib, importString);
                                                    $$ = importLib;
                                                }
    ;

VariavelGlobal: TIPO Id VariavelGlobalAux SemiColon {
                                                        //printf(" --> variavel global sem valor\n");
                                                        struct no *variavelGlobal = criar("VarDecl","",@1.first_line, @1.first_column);
                                                        struct no *id = criar("Id", $2,@2.first_line, @2.first_column);
                                                        filho(variavelGlobal, $1);
                                                        filho(variavelGlobal, id);
                                                        if ($3 != NULL){
                                                            add_bro(variavelGlobal, $3);
                                                        }
                                                        $$ = variavelGlobal;
                                                    }
    | TIPO Id Assign Expr SemiColon                 {
                                                        printf(" --> variavel global decl\n");
                                                        struct no *variavelGlobal = criar("VarDecl","",@1.first_line, @1.first_column);
                                                        struct no *id = criar("Id", $2,@2.first_line, @2.first_column);
                                                        struct no *tipo = criar(tipoaux, "",0,0);
                                                        filho(variavelGlobal, tipo);
                                                        filho(variavelGlobal, id);
                                                        filho(variavelGlobal, $4);
                                                        add_bro(tipo, id);
                                                        add_bro(id, $4);
                                                        $$ = variavelGlobal;
                                                    }
    ;

VariavelGlobalAux: Virgula Id VariavelGlobalAux {
                                                    //printf(" --> variaveis global sem valores\n");
                                                    struct no *variavelGlobal = criar("VarDecl", "",@2.first_line, @2.first_column);
                                                    struct no *id = criar("Id", $2,@2.first_line, @2.first_column);
                                                    struct no *tipo = criar(tipoaux, "",0,0);
                                                    filho(variavelGlobal, id);
                                                    filho(variavelGlobal, tipo);
                                                    add_bro(tipo, id);
                                                    if ($3 != NULL){
                                                        add_bro(variavelGlobal, $3);
                                                    }
                                                    $$ = variavelGlobal;
                                                }
    |   /* vazio */                             {$$ = NULL;}
    ;


Program: MethodDecl Program {   
                                if ($2 != NULL){
                                    add_bro($1, $2);
                                }
                                $$ = $1; 
                            }
    |   Statement Program   {
                                if ($2 != NULL){
                                    add_bro($1, $2);
                                }
                                $$ = $1; 
                            }
    |   VarDecl Program     {
                                if ($2 != NULL){
                                    add_bro($1, $2);
                                }
                                $$ = $1; 
                            }
    |   SemiColon Program   {
                                if ($2 != NULL){
                                    $$ = $2;
                                } else {
                                    $$ = NULL;
                                } 
                            }
    |   /* vazio */         {$$ = NULL;}
    ;



MethodDecl: Id ParaE Expr ParaD SemiColon   {
                                                printf(" -> metodo invocado com body\n");
                                                struct no *methodDecl = criar("MethodDecl","",0,0);
                                                struct no *id = criar("Id",$1,@1.first_line, @1.first_column);
                                                filho(methodDecl, id);
                                                filho(methodDecl, $3);
                                                add_bro(id, $3);
                                                $$ = methodDecl;
                                            }
    |   Id ParaE ParaD SemiColon            {
                                                printf(" -> metodo invocado\n");
                                                struct no *methodDecl = criar("MethodDecl","",0,0);
                                                struct no *id = criar("Id",$1,@1.first_line, @1.first_column);
                                                filho(methodDecl, id);
                                                $$ = methodDecl;
                                            }
    |   TIPO Id ParaE Expr ParaD ChavetaE Program ChavetaD  {
                                                                printf(" -> metodo declarado com body\n");
                                                                struct no *methodDecl = criar("MethodDecl","",0,0);
                                                                struct no *id = criar("Id",$2,@2.first_line, @2.first_column);
                                                                filho(methodDecl, $1);
                                                                filho(methodDecl, id);
                                                                filho(methodDecl, $4);
                                                                filho(methodDecl, $7);
                                                                add_bro($1, id);
                                                                add_bro(id, $4);
                                                                add_bro($4, $7);
                                                                $$ = methodDecl;
                                                            }
    |   TIPO Id ParaE ParaD ChavetaE Program ChavetaD  {
                                                                printf(" -> metodo declarado\n");
                                                                struct no *methodDecl= criar("MethodDecl","",0,0);
                                                                struct no *id = criar("Id",$2,@2.first_line, @2.first_column);
                                                                filho(methodDecl, $1);
                                                                filho(methodDecl, id);
                                                                filho(methodDecl, $6);
                                                                add_bro($1, id);
                                                                add_bro(id, $6);
                                                                $$ = methodDecl;
                                                            }
    |   Void Id ParaE Expr ParaD ChavetaE Program ChavetaD  {
                                                                printf(" -> metodo void declarado com body\n");
                                                                struct no *methodDecl= criar("MethodDecl","",0,0);
                                                                struct no *id = criar("Id",$2,@2.first_line, @2.first_column);
                                                                struct no *voidy = criar("Void", "", @1.first_line, @1.first_column);
                                                                filho(methodDecl, voidy);
                                                                filho(methodDecl, id);
                                                                filho(methodDecl, $4);
                                                                filho(methodDecl, $7);
                                                                add_bro(voidy, id);
                                                                add_bro(id, $4);
                                                                add_bro($4, $7);
                                                                $$ = methodDecl;
                                                            }
    |   Void Id ParaE ParaD ChavetaE Program ChavetaD  {
                                                                printf(" -> metodo void declarado\n");
                                                                struct no *methodDecl= criar("MethodDecl","",0,0);
                                                                struct no *id = criar("Id",$2,@2.first_line, @2.first_column);
                                                                struct no *voidy = criar("Void", "", @1.first_line, @1.first_column);
                                                                filho(methodDecl, voidy);
                                                                filho(methodDecl, id);
                                                                filho(methodDecl, $6);
                                                                add_bro(voidy, id);
                                                                add_bro(id, $6);
                                                                $$ = methodDecl;
                                                            }                                                     
    ;



Statement: ChavetaE StatementBody ChavetaD              {
                                                            //printf(" -> this is a statment\n");
                                                            if ($2 != NULL && $2->bros != NULL){
                                                                struct no *bloco = criar("Bloco", "",@2.first_line, @2.first_column);
                                                                filho(bloco, $2);
                                                                $$ = bloco;
                                                            } else {
                                                                $$ = $2;
                                                            }
                                                        }
    |   IF ParaE Expr ParaD Statement                   {   
                                                            struct no *iff = criar("If","",@1.first_line, @1.first_column);
                                                            filho(iff, $3);
                                                            if ($5!=NULL){
                                                                filho(iff, $5);
                                                                struct no *bloco = criar("Bloco","",@5.first_line, @5.first_column);
                                                                filho(iff, bloco);
                                                                add_bro($3,$5);
                                                                add_bro($5,bloco);
                                                                $$ = iff;
                                                            } else {
                                                                struct no *bloco = criar("Bloco", "",0,0);
                                                                filho(iff, bloco);
                                                                struct no *bloco1 = criar("Bloco", "",0,0);
                                                                filho(iff, bloco1);
                                                                add_bro($3, bloco);
                                                                add_bro(bloco, bloco1);
                                                                $$ = iff;
                                                            }
                                                        }
    |   IF ParaE Expr ParaD Statement Else Statement    {
                                                            struct no *iff = criar("If","",@1.first_line, @1.first_column);
                                                            filho(iff, $3);
                                                            if ($5!=NULL){
                                                                filho(iff, $5);
                                                                add_bro($3, $5);
                                                                if($7 != NULL){
                                                                    filho(iff,$7);
                                                                    add_bro($5,$7);
                                                                    $$ = iff;
                                                                } else {
                                                                    struct no *bloco1 = criar("Bloco","",@7.first_line, @7.first_column);
                                                                    filho(iff, bloco1);
                                                                    add_bro($5, bloco1);
                                                                    $$ = iff;
                                                                }
                                                            } else {
                                                                struct no *bloco = criar("Bloco", "",@5.first_line, @5.first_column);
                                                                filho(iff, bloco);
                                                                add_bro($3, bloco);
                                                                if($7 != NULL){
                                                                    filho(iff, $7);
                                                                    add_bro($5, $7);
                                                                    $$ = iff;
                                                                } else{
                                                                    struct no *bloco1 = criar("Bloco", "",@7.first_line, @7.first_column);
                                                                    filho(iff, bloco1);
                                                                    add_bro(bloco, bloco1);
                                                                    $$ = iff;
                                                                }
                                                            }
                                                        }
    |   For ParaE ForAux ParaD Statement                {
                                                            struct no *forr = criar("For", "",@1.first_line, @1.first_column);
                                                            filho(forr, $3);
                                                            if ($5 != NULL){
                                                                filho(forr, $5);
                                                                add_bro($3,$5);
                                                                $$ = forr;
                                                            } else {
                                                                struct no *bloco = criar("Bloco", "",@5.first_line, @5.first_column);
                                                                filho(forr, bloco);
                                                                add_bro($3, bloco);
                                                            }
                                                        }
    |   For ParaE Int ForAux ParaD Statement            {
                                                            struct no *forr = criar("ForInt", "",@1.first_line, @1.first_column);
                                                            filho(forr, $4);
                                                            if ($6 != NULL){
                                                                filho(forr, $6);
                                                                add_bro($4,$6);
                                                                $$ = forr;
                                                            } else {
                                                                struct no *bloco = criar("Bloco", "",@6.first_line, @6.first_column);
                                                                filho(forr, bloco);
                                                                add_bro($4, bloco);
                                                            }
                                                        }
    /*|   PRINT ParaE StatementAux ParaD SemiColon*/
    ;


StatementBody: Statement StatementBody          {
                                                    if ($1 == NULL && $2 == NULL){
                                                        $$ = NULL;
                                                    } else if ($1 == NULL){
                                                        $$ = $2;
                                                    } else if ($2 == NULL){
                                                        $$ = $1;
                                                    } else{
                                                        $$ = add_bro($1, $2);
                                                    }
                                                }
    |   Expr SemiColon StatementBody            {
                                                    if ($3!=NULL){
                                                        $$ = add_bro($1, $3);
                                                    } else {
                                                        $$ = $1;
                                                    }
                                                }
    |   MethodDecl StatementBody                {
                                                    if ($2!=NULL){
                                                        $$ = add_bro($1, $2);
                                                    } else {
                                                        $$ = $1;
                                                    }
                                                }
    |   Return Expr SemiColon StatementBody     {   
                                                    struct no *ret = criar("Return","",@1.first_line, @1.first_column);
                                                    filho(ret, $2);
                                                    if ($4!=NULL){
                                                        add_bro(ret, $4);
                                                    }
                                                    $$ = ret;
                                                }
    |   Return SemiColon StatementBody          {   
                                                    struct no *ret = criar("Return","",@1.first_line, @1.first_column);
                                                    if ($3!=NULL){
                                                        add_bro(ret, $3);
                                                    }
                                                    $$ = ret;
                                                }
    |   /*vazio*/                               {$$ = NULL;}
    ;

ForAux: Expr SemiColon Expr SemiColon Expr  {
                                                struct no *forAux = criar ("ForAux", "",0,0);
                                                filho(forAux, $1);
                                                filho(forAux, $3);
                                                filho(forAux, $5);
                                                add_bro($1,$3);
                                                add_bro($3,$5);
                                                $$ = forAux;
                                            }
    ;

VarDecl: TIPO Id VarDeclBody SemiColon  {
                                            struct no *varDecl = criar("VarDecl","",@1.first_line, @1.first_column);
                                            struct no *id = criar("Id",$2,@2.first_line, @2.first_column);
                                            filho(varDecl, $1);
                                            filho(varDecl, id);
                                            add_bro($1, id);
                                            if( $3 != NULL){
                                                add_bro(varDecl, $3);
                                            }
                                            $$ = varDecl;
                                        }
    |   TIPO Id Assign Expr SemiColon   {  
                                            struct no *varDeclAssign = criar("VarDecl","",@1.first_line, @1.first_column);
                                            struct no *id = criar("Id", $2,@2.first_line, @2.first_column);
                                            struct no *tipo = criar(tipoaux, "",0,0);
                                            filho(varDeclAssign, tipo);
                                            filho(varDeclAssign, id);
                                            filho(varDeclAssign, $4);
                                            add_bro(tipo, id);
                                            add_bro(id, $4);
                                            $$ = varDeclAssign;
                                        }
    | Expr SemiColon                    {
                                            struct no *varDecl = criar("VarAssign","",0,0);
                                            filho(varDecl, $1);
                                            $$ = varDecl;
                                        }
    ;

VarDeclBody: Virgula Id VarDeclBody {
                                        struct no *varDecl = criar("VarDecl","",@2.first_line, @2.first_column);
                                        struct no *tipo = criar(tipoaux, "",0,0);
                                        struct no *id = criar("Id",$2,@2.first_line, @2.first_column);
                                        filho(varDecl, tipo);
                                        filho(varDecl, id);
                                        add_bro(tipo, id);
                                        if ($3!=NULL){
                                            add_bro(varDecl, $3);
                                        }
                                        $$ = varDecl;
                                    }
    |   /*vazio*/                   {$$ = NULL;}
    ;


Expr:  Expr Assign Expr {
                            
                            struct no* assign = criar("Assign","",@2.first_line, @2.first_column);
                            filho(assign, $1);
                            filho(assign, $3);
                            add_bro($1,$3);
                            $$ = assign;
                        }
    |  ParaE Expr ParaD {
                            $$ = $2;
                        }
    |  Expr Mais Expr   {
                            struct no *soma = criar("Soma","",@2.first_line, @2.first_column);
                            filho(soma, $1);
                            filho(soma, $3);
                            add_bro($1,$3);
                            $$ = soma;
                        }
    |  Expr Menos Expr  {
                            struct no *subt = criar("Subt","",@2.first_line, @2.first_column);
                            filho(subt, $1);
                            filho(subt, $3);
                            add_bro($1,$3);
                            $$ = subt;
                        }
    |  Expr Multi Expr  {
                            struct no *multi = criar("Multi","",@2.first_line, @2.first_column);
                            filho(multi, $1);
                            filho(multi, $3);
                            add_bro($1,$3);
                            $$ = multi;
                        }
    |  Expr Div Expr    {
                            struct no *div = criar("Div","",@2.first_line, @2.first_column);
                            filho(div, $1);
                            filho(div, $3);
                            add_bro($1,$3);
                            $$ = div;
                        }
    |  Expr MOD Expr    {
                            struct no *mod = criar("Mod","",@2.first_line, @2.first_column);
                            filho(mod, $1);
                            filho(mod, $3);
                            add_bro($1,$3);
                            $$ = mod;
                        }
    |  Expr And Expr    {
                            struct no *and = criar("And","",@2.first_line, @2.first_column);
                            filho(and, $1);
                            filho(and, $3);
                            add_bro($1,$3);
                            $$ = and;
                        }
    |  Expr OR Expr     {
                            struct no *or = criar("Or","",@2.first_line, @2.first_column);
                            filho(or, $1);
                            filho(or, $3);
                            add_bro($1,$3);
                            $$ = or;
                        }
    |  Expr Equivale Expr   {
                                struct no *eq = criar("Eq","",@2.first_line, @2.first_column);
                                filho(eq, $1);
                                filho(eq, $3);
                                add_bro($1,$3);
                                $$ = eq;
                            }   
    |  Expr MaiorIgual Expr {
                                struct no *maiorIgual = criar("MaiorIgual","",@2.first_line, @2.first_column);
                                filho(maiorIgual, $1);
                                filho(maiorIgual, $3);
                                add_bro($1,$3);
                                $$ = maiorIgual;
                            }
    |  Expr Maior Expr  {
                            struct no *maior = criar("Maior","",@2.first_line, @2.first_column);
                            filho(maior, $1);
                            filho(maior, $3);
                            add_bro($1,$3);
                            $$ = maior;
                        }
    |  Expr MenorIgual Expr {
                                struct no *menorIgual = criar("MenorIgual","",@2.first_line, @2.first_column);
                                filho(menorIgual, $1);
                                filho(menorIgual, $3);
                                add_bro($1,$3);
                                $$ = menorIgual;
                            }
    |  Expr Menor Expr  {
                            struct no *menor = criar("Menor","",@2.first_line, @2.first_column);
                            filho(menor, $1);
                            filho(menor, $3);
                            add_bro($1,$3);
                            $$ = menor;
                        }    
    |  Expr Diferente Expr  {
                                struct no *diferente = criar("Diferente","",@2.first_line, @2.first_column);
                                filho(diferente, $1);
                                filho(diferente, $3);
                                add_bro($1,$3);
                                $$ = diferente;
                            } 
    |  Expr Virgula Expr    {
                                struct no *virgula = criar("Virgula","",@2.first_line, @2.first_column);
                                filho(virgula, $1);
                                filho(virgula, $3);
                                add_bro($1,$3);
                                $$ = virgula;
                            }
    |  NOT Expr         {
                            struct no *not = criar("Not","",@1.first_line, @1.first_column);
                            $$ = filho(not, $2);
                        }    
    |  Menos Expr %prec NOT {
                                struct no *menos = criar("Menos", "",@1.first_line, @1.first_column);
                                $$ = filho(menos, $2);
                            } 
    |  Mais Expr %prec NOT  {
                                struct no *mais = criar("Mais", "",@1.first_line, @1.first_column);
                                $$ = filho(mais, $2);
                            }
    |  Id               {   
                            $$ = criar("Id",$1,@1.first_line, @1.first_column);
                        }
    |  Id Dec_OP        {
                            struct no *dec_OP = criar("Id--","",@2.first_line, @2.first_column);
                            struct no *id = criar("Id",$1,@1.first_line, @1.first_column);
                            $$ = filho(dec_OP, id);
                        }
    |  Id Inc_OP        {
                            struct no *inc_OP = criar("Id++","",@2.first_line, @2.first_column);
                            struct no *id = criar("Id",$1,@1.first_line, @1.first_column);
                            $$ = filho(inc_OP, id);
                        }
    |  Id DLenght       {
                            struct no *dLenght = criar("DLenght","",@2.first_line, @2.first_column);
                            struct no *id = criar("Id",$1,@1.first_line, @1.first_column);
                            $$ = filho(dLenght, id);
                        }   
    |  Intlit           {
                            $$ = criar("Intlit", $1,@1.first_line, @1.first_column);
                        }               
    |  Boollit          {
                            $$ = criar("Boollit",$1,@1.first_line, @1.first_column);
                        }
    |  Color ParaE Expr ParaD   {
                                    struct no *colorLit = criar("ColorLit","",@3.first_line, @3.first_column);
                                    $$ = filho(colorLit, $3);
                                }
    |  Random ParaE Expr ParaD  {
                                    struct no *random = criar("Random","",@3.first_line, @3.first_column);
                                    $$ = filho(random,$3);
                                }            
    ;

TIPO:   Boolean {
                    struct no *booleanaux = criar("Boolean", "",@1.first_line, @1.first_column);
                    tipoaux = "Boolean";
                    $$ = booleanaux;
                }
    |   Int     {
                    struct no *intaux = criar("Int", "",@1.first_line, @1.first_column);
                    tipoaux = "Int";
                    $$ = intaux;
                }
    |   String  {
                    struct no *stringaux = criar("String", "",@1.first_line, @1.first_column);
                    tipoaux = "String";
                    $$ = stringaux;
                }
    |   Double  {  
                    struct no *doubleaux = criar("Double", "",@1.first_line, @1.first_column);
                    tipoaux = "Double";
                    $$ = doubleaux;
                }
    |   Color   {
                    struct no *coloraux = criar("Color", "",@1.first_line, @1.first_column);
                    tipoaux = "Color";
                    $$ = coloraux;
                }
    ;



%%
/*#include <stdio.h>

extern char yytext[];
extern int coluna;
extern int num_linha;

void yyerror(s)
char *s;
{
    fflush(stdout);
    //printf("\n%d\n%d\n/*s\n", coluna, num_linha, s);
    printf("\n%*s\n%*s\n", coluna, "^", coluna, s);
}*/



    


int main(){
    //printf("respostas bison here \n\n");
    yyparse();
    printf("\n");
    //imprimir(root, 0);
    printf("\n\ntabelas de simbolos\n\n");
    tabela_de_simbolos(root);
    printf("\nimprimir erros\n\n");
    imprime_erro();
    printf("\nimprimir tabelas\n\n");
    imprimir_tabelas();
    printf("\nfim\n");
    return 0;
}