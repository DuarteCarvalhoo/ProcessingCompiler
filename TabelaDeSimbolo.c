#include "TabelaDeSimbolo.h"

elementos_tabela *tabela_global = NULL;

elementos_tabela *inserir_decls(char *id, char *tipo, char *parametro, int linha, int coluna){
    elementos_tabela *novo_elemento = (elementos_tabela*) malloc(sizeof(elementos_tabela));
    novo_elemento->tipo_decl = decls;
    novo_elemento->id = (char*) malloc((strlen(id)+1)*sizeof(char));
    strcpy(novo_elemento->id, id);
    novo_elemento->linha = (int) malloc(sizeof(int));
    novo_elemento->linha = linha;
    novo_elemento->coluna = (int) malloc(sizeof(int));
    novo_elemento->coluna = coluna;
    novo_elemento->repetido = 0;
    novo_elemento->next = NULL;

    novo_elemento->vardecl = (vardecl*) malloc(sizeof(vardecl));
    novo_elemento->vardecl->tipo = (char*) malloc((strlen(tipo)+1)*sizeof(char));
    strcpy(novo_elemento->vardecl->tipo, tipo);
    novo_elemento->vardecl->parametro = (char*)malloc((strlen(parametro)+1)*sizeof(char));
    strcpy(novo_elemento->vardecl->parametro, parametro);

    return novo_elemento;
}

elementos_tabela *inserir_vardecl(char* id, char* tipo, char* parametro, elementos_tabela** tabela, int linha, int coluna){
    elementos_tabela *novo_elemento = (elementos_tabela*) malloc(sizeof(elementos_tabela));
    novo_elemento->tipo_decl = variavel;
    novo_elemento->id = (char*)malloc(((strlen(id))+1)*sizeof(char));
    strcpy(novo_elemento->id, id);
    novo_elemento->next = NULL;
    novo_elemento->linha = (int) malloc(sizeof(int));
    novo_elemento->linha = linha;
    novo_elemento->coluna = (int) malloc(sizeof(int));
    novo_elemento->coluna = coluna;
    novo_elemento->repetido = 0;

    novo_elemento->vardecl = (vardecl*) malloc(sizeof(vardecl));
    novo_elemento->vardecl->tipo = (char*) malloc((strlen(tipo)+1)*sizeof(char));
    strcpy(novo_elemento->vardecl->tipo, tipo);
    novo_elemento->vardecl->parametro = (char*)malloc((strlen(parametro)+1)*sizeof(char));
    strcpy(novo_elemento->vardecl->parametro, parametro);

    return inserir_elemento(novo_elemento, tabela);
}

elementos_tabela *inserir_elemento(elementos_tabela *novo_elemento, elementos_tabela** tabela){
    elementos_tabela* aux = *tabela;
    elementos_tabela* anterior;

    if (aux != NULL){
        while (aux != NULL)
        {
            anterior = aux;
            aux = aux->next;
        }
        anterior->next = novo_elemento;
    } else {
        *tabela = novo_elemento;
    }

    return novo_elemento;
}

elementos_tabela *cria_funcdecl(char *id, char *tipo, int linha, int coluna){
    elementos_tabela *novo_elemento = (elementos_tabela*) malloc(sizeof(elementos_tabela));
    novo_elemento->tipo_decl = func;
    novo_elemento->id = (char*) malloc((strlen(id)+1)*sizeof(char));
    strcpy(novo_elemento->id, id);
    novo_elemento->linha = (int) malloc(sizeof(int));
    novo_elemento->linha = linha;
    novo_elemento->coluna = (int) malloc(sizeof(int));
    novo_elemento->coluna = coluna;
    novo_elemento->repetido = 0;
    novo_elemento->next = NULL;

    novo_elemento->funcdecl = (funcdecl*) malloc(sizeof(funcdecl));
    novo_elemento->funcdecl->n_parametros = 0;
    novo_elemento->funcdecl->n_parametros_entrada = 0;
    novo_elemento->funcdecl->flag_parametros_iguais = 0;
    novo_elemento->funcdecl->tipo_return = (char *) malloc(strlen(tipo)*sizeof(char)+1);
    strcpy(novo_elemento->funcdecl->tipo_return, tipo);
    novo_elemento->funcdecl->variaveis = NULL;

    return novo_elemento;
}

elementos_tabela *inserir_func(elementos_tabela *novo_elemento, elementos_tabela **tabela){
    elementos_tabela *aux = *tabela;
    elementos_tabela *anterior;
    if(aux!=NULL){
        while (aux != NULL)
        {
            anterior = aux;
            aux = aux->next;
        }
        anterior->next = novo_elemento;
    } else{
        *tabela = novo_elemento;
    }

    return novo_elemento;
}

elementos_tabela *procurar_elementos(char *id, elementos_tabela *tabela){
    elementos_tabela *aux = tabela;
    while (aux!=NULL)
    {
        if (strcmp(aux->id, id) == 0){
            return aux;
        }else{
            aux = aux->next;
        }
    }
    return NULL;
}

elementos_tabela *procurar_repetidos(char *id, elementos_tabela *inicio, int index, int tipo){
    elementos_tabela *aux = inicio;
    for(int i = 0; i<index; i++){
        if(strcmp(aux->id, id)==0 && aux->tipo_decl == tipo){
            return aux;
        }
        else{
            aux = aux->next;
        }
    }
    return NULL;
}

elementos_tabela *procurar_funcao_rep(elementos_tabela *atual, elementos_tabela *inicio, int index){
    elementos_tabela *aux = inicio;

    for(int i=0;i<index;i++){
        if(aux->tipo_decl==1){
            if(strcmp(aux->funcdecl->tipo_return, atual->funcdecl->tipo_return)==0 && strcmp(aux->id, atual->id)==0){
                if(aux->funcdecl->n_parametros_entrada == atual->funcdecl->n_parametros_entrada){
                    int count = 0;
                    elementos_tabela *variavel_atual = atual->funcdecl->variaveis;
                    elementos_tabela *variavel_aux = aux->funcdecl->variaveis;

                    for(int i=0; i<atual->funcdecl->n_parametros_entrada;i++){
                        if(strcmp(variavel_atual->vardecl->tipo, variavel_aux->vardecl->tipo)==0){
                            count++;
                        }
                        variavel_atual = variavel_atual->next;
                        variavel_aux = variavel_atual->next;
                    }
                    if(count == atual->funcdecl->n_parametros_entrada){
                        return aux;
                    }
                }
            }
        }
        aux = aux->next;
    }
    return NULL;
}

void imprime_erro(){
    //printf("cheguei\n");
    elementos_tabela *aux = tabela_global;
    elementos_tabela *aux1 = tabela_global;
    int count = 0;

    //printf("cheguei2\n");
    while (aux!=NULL)
    {
        if(aux->tipo_decl == func){
            elementos_tabela *tabela = aux->funcdecl->variaveis;
            elementos_tabela *variveis_tabela = aux->funcdecl->variaveis;
            for(int i=0;i<aux->funcdecl->n_parametros_entrada;i++){
                elementos_tabela *procurar_variaveis = procurar_repetidos(variveis_tabela->id, tabela, i, 0);
                if(procurar_variaveis != NULL){
                    if(procurar_variaveis, "_"){
                        printf("Line %d, col %d: Symbol _ is reserved\n",variveis_tabela->linha, variveis_tabela->coluna);
                    } else{
                        printf("Line %d, col %d: Symbol %s already defined\n",variveis_tabela->linha, variveis_tabela->coluna, variveis_tabela->id);
                    }
                } else if(strcmp(variveis_tabela->id, "_") == 0){
                        printf("Line %d, col %d: Symbol _ is reserved\n",variveis_tabela->linha, variveis_tabela->coluna);
                }
                variveis_tabela = variveis_tabela->next;
            }
            elementos_tabela *procurar = procurar_funcao_rep(aux, tabela_global, count);
            if(procurar!=NULL){
                printf("Linha %d, coluna %d: Simbolo %s(", aux->linha, aux->coluna, aux->id);
                elementos_tabela *var_aux = aux->funcdecl->variaveis;
                for(int i=0; i<aux->funcdecl->n_parametros_entrada;i++){
                    printf("%s", var_aux->vardecl->tipo);
                    if(i<aux->funcdecl->n_parametros_entrada-1){
                        printf(",");
                    }
                    var_aux = var_aux->next;
                }
                printf(") already defined\n");
            }
        } else if(aux->tipo_decl == decls){
            elementos_tabela *procurar_decls = procurar_repetidos(aux->id, tabela_global, count, 2);
            if(procurar_decls != NULL){
                if(strcmp(procurar_decls->id, "_")==0){
                    printf("Line %d, col %d: Symbol _ is reserved\n",aux->linha, aux->coluna); 
                } else {
                    printf("Line %d, col %d: Symbol %s already defined\n",aux->linha, aux->coluna, aux->id);
                }
            } else if(strcmp(aux->id, "_")==0){
                printf("Line %d, col %d: Symbol _ is reserved\n",aux->linha, aux->coluna);
            }
        }
        aux = aux->next;
        count++;
    }
    //printf("cheguei3\n");
    while (aux1 != NULL)
    {
        if(aux1->tipo_decl == func){
            //printf("Still alive\n");
            elementos_tabela *tabela_variaveis = aux1->funcdecl->variaveis;
            elementos_tabela *variaveis = aux1->funcdecl->variaveis;
            int numero_param = aux1->funcdecl->n_parametros;
            int numero_param_entrada = aux1->funcdecl->n_parametros_entrada;
            //printf("Still alive1\n");
            for(int i=0; i<numero_param;i++){
                elementos_tabela *procurar_variavel = procurar_repetidos(variaveis->id, tabela_variaveis, i, 0);
                //printf("Still alive2\n");
                if(i>numero_param_entrada){
                    if(procurar_variavel!=NULL){
                        //printf("Still alive3\n");
                        if(strcmp(procurar_variavel->id, "_")==0){
                            //printf("Line %d, col %d: Symbol _ is reserved\n",variaveis->linha, variaveis->coluna);
                        } else {
                            //printf("Line %d, col %d: Symbol %s already defined\n",variaveis->linha, variaveis->coluna, variaveis->id);
                        }
                    }
                }
                variaveis = variaveis->next;
            }
        }
        aux1 = aux1->next;
    }
    //printf("cheguei4\n");
}

void imprimir_tabelas(){
    elementos_tabela *aux = tabela_global;
    elementos_tabela *aux1 = tabela_global;

    //print primeira coisa da classe
    while (aux != NULL){
        if(aux->tipo_decl == decls && aux->repetido == 0){
            printf("%s\t\t%s\n",aux->id, aux->vardecl->tipo);
        } else if(aux->funcdecl->n_parametros_entrada>0){
            printf("%s\t(", aux->id);
            elementos_tabela *parametros = aux->funcdecl->variaveis;
            if(strcmp(parametros->vardecl->parametro, "parametro")==0){ 
                printf("%s", parametros->vardecl->tipo);
                parametros = parametros->next;
            }
            for(int i=1; i<aux->funcdecl->n_parametros;i++){
                if(strcmp(parametros->vardecl->parametro, "parametro")==0){
                    printf(",%s", parametros->vardecl->tipo);
                }
                parametros = parametros->next;
            }
            printf(")\t%s\n", aux->funcdecl->tipo_return);
        }else {
            printf("%s\t\t%s\n",aux->id,aux->funcdecl->tipo_return);
        }
        aux = aux->next;
    }
    printf("\n");

    while(aux1!=NULL){
        if(aux1->tipo_decl == func){
            elementos_tabela *parametros_func = aux1->funcdecl->variaveis;
            printf("===== Metodo %s(",aux1->id);
            if(aux1->funcdecl->n_parametros_entrada>0){
                if(parametros_func->vardecl!=NULL && strcmp(parametros_func->vardecl->parametro, "parametro") == 0){
                    printf("%s", parametros_func->vardecl->tipo);
                    parametros_func = parametros_func->next;
                }
            }
            for(int i=0; i<aux1->funcdecl->n_parametros_entrada;i++){ 
                printf("hello2\n");
                if(parametros_func->vardecl!=NULL && strcmp(parametros_func->vardecl->parametro,"parametro")==0){
                    printf(",%s", parametros_func->vardecl->tipo);
                }
                parametros_func = parametros_func->next;
            }

            printf(") Tabela de Simbolos =====\n");

            elementos_tabela *print_parametros = aux1->funcdecl->variaveis;

            for(int i=0; i<aux1->funcdecl->n_parametros;i++){
                if(print_parametros->tipo_decl==0){
                    if(strcmp(print_parametros->vardecl->parametro, "parametro")==0){
                        printf("%s\t\t%s\tparametro\n", print_parametros->id, print_parametros->vardecl->tipo);
                    } else if (strcmp(print_parametros->vardecl->parametro, "null")==0){
                        printf("%s\t\t%s\n", print_parametros->id, print_parametros->vardecl->tipo);
                    }
                } else if(print_parametros->tipo_decl==1){
                    printf("%s()\t\t%s\n",print_parametros->id,print_parametros->funcdecl->tipo_return);
                }
                print_parametros = print_parametros->next;
            }
            printf("%s()\t\t%s\n",aux1->id, aux1->funcdecl->tipo_return);
            printf("\n");
        }
        aux1 = aux1->next;
    }
}
