#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef enum {variavel, func, decls} tipo_de_func;

typedef struct vardecl {
    char *tipo;
    char *parametro;
} vardecl;

typedef struct funcdecl {
    char *tipo_return;
    struct elementos_tabela *variaveis;
    int n_parametros;
    int n_parametros_entrada;
    int flag_parametros_iguais;
} funcdecl;

typedef struct elementos_tabela {
    tipo_de_func tipo_decl;
    char *id;
    funcdecl *funcdecl;
    vardecl *vardecl;
    struct elementos_tabela *next;
    int linha;
    int coluna;
    int repetido;
} elementos_tabela;

extern elementos_tabela *tabela_global;
elementos_tabela *inserir_decls(char *id, char *tipo, char *parametro, int linha, int coluna);
elementos_tabela *inserir_vardecl(char *id, char *tipo, char *parametro, elementos_tabela **tabela, int linha, int coluna);
elementos_tabela *inserir_elemento(elementos_tabela *novo_elemento, elementos_tabela **tabela);
elementos_tabela *cria_funcdecl(char *id, char *tipo, int linha, int coluna);
elementos_tabela *inserir_func(elementos_tabela *novo_elemento, elementos_tabela **tabela);
elementos_tabela *procurar_elementos(char *id, elementos_tabela *tabela);
elementos_tabela *procurar_repetidos(char *id, elementos_tabela *inicio, int index, int tipo);
elementos_tabela *procurar_funcao_rep(elementos_tabela *atual, elementos_tabela *inicio, int index);
void imprime_erro();
void imprimir_tabelas();

