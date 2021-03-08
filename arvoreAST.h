#include "TabelaDeSimbolo.h"
#include <stdio.h>
#include <string.h>
#define Max_Num 1000

typedef struct no{
    char* tipo;
    char* valor;
    struct no *pai;
    struct no *bros;
    struct no *filhos[Max_Num];
    int num_filhos;
    int linha;
    int coluna;
}no;

void tabela_de_simbolos(struct no *root);
void decl_func(no *no);
void decl_field(no *no);
struct no *criar(char *tipo, char *valor, int linha, int coluna);
struct no *filho(no *pai, no *filho);
struct no *add_bro(no *aux, no *aux1);
void imprimir(no *root, int profundidade);
