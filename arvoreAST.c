#include "arvoreAST.h"

void tabela_de_simbolos(struct no *root){
    for(int i=0; i<root->num_filhos;i++){
        //printf("%d\n",root->num_filhos);
        //printf("new i = %d\n", i);
        //printf("root %s\n", root->tipo);
        struct no *filho = root->filhos[i];
        if(strcmp(filho->tipo,"MethodDecl")==0){
            //até aqui está tudo fixe
            decl_func(filho);
        }
        if(strcmp(filho->tipo,"Begin")==0){
            decl_func(filho);
            /*printf("Begin-> %d\n",filho->num_filhos);
            printf("1 -> tipo: %s valor: %s\n", filho->filhos[0]->tipo, filho->filhos[0]->valor);
            printf("2 -> tipo: %s valor: %s\n", filho->filhos[1]->tipo, filho->filhos[1]->valor);
            printf("3 -> tipo: %s valor: %s\n", filho->filhos[2]->tipo, filho->filhos[2]->valor);
            if(filho->filhos[3]!=NULL){
                printf("4 -> tipo: %s valor: %s\n", filho->filhos[3]->tipo, filho->filhos[3]->valor);
            }*///para o draw e setup
        }
        if(strcmp(filho->tipo,"VarDecl")==0){
            decl_field(filho);
        }
        //printf("fim do for\n");
    }
}

void decl_func(no* no){
    char *nome_return;
    char *func_id;
    struct no *entrada_Metodo = no->filhos[0];
    nome_return = (char *) malloc(sizeof(char) * (strlen(entrada_Metodo->tipo)+1));
    strcpy(nome_return, entrada_Metodo->tipo);

    if(strcmp(no->tipo,"MethodDecl")==0){
        entrada_Metodo = no->filhos[1];
    }
    
    func_id = (char *) malloc(sizeof(char)*(strlen(entrada_Metodo->valor)+1));
    strcpy(func_id, entrada_Metodo->valor);

    //printf("func -> %s, return -> %s\n", func_id, nome_return);

    
    elementos_tabela *novo_elemento = cria_funcdecl(func_id, nome_return, entrada_Metodo->linha, entrada_Metodo->coluna);

    //ver se pode ser null ou nao -> entrada_Metedo->filhos[2]
    //printf("se %s -> %d\n", func_id, no->num_filhos);
    struct no *parametros_metodo = entrada_Metodo->filhos[0];
    if(parametros_metodo != NULL){
        printf("%d tipo %s valor %s", parametros_metodo->num_filhos, parametros_metodo->tipo, parametros_metodo->valor);
        for(int i=0; i<parametros_metodo->num_filhos; i++){
            (novo_elemento->funcdecl->n_parametros)++;
            (novo_elemento->funcdecl->n_parametros_entrada)++;
            struct no *parametros = parametros_metodo->filhos[i];
            char *var = (char *) malloc(sizeof(char) * (strlen(parametros->filhos[0]->tipo)+1));
            strcpy(var, parametros->filhos[0]->tipo);
            inserir_vardecl(parametros->filhos[1]->valor, var, "parametro", &(novo_elemento->funcdecl->variaveis), parametros->filhos[1]->linha, parametros->filhos[1]->coluna);
            free(var);
        }
    }    
    
    //printf("here1\n");
    
    elementos_tabela *aux = tabela_global;

    while (aux != NULL)
    {  
        elementos_tabela *nood = procurar_elementos(func_id, aux);
        if(nood != NULL){
            if(nood->tipo_decl == novo_elemento->tipo_decl){
                if(strcmp(nood->funcdecl->tipo_return, novo_elemento->funcdecl->tipo_return)==0){
                    if(nood->funcdecl->n_parametros_entrada == novo_elemento->funcdecl->n_parametros_entrada){
                        elementos_tabela *var_nood = nood->funcdecl->variaveis;
                        elementos_tabela *var_aux = novo_elemento->funcdecl->variaveis;
                        int n_parametros_iguais = 0;
                        for(int i=0; i<nood->funcdecl->n_parametros_entrada;i++){
                            if(strcmp(var_nood->vardecl->tipo, var_aux->vardecl->tipo)==0){
                                n_parametros_iguais++;
                            }
                            var_nood = var_nood->next;
                            var_aux = var_aux->next;
                        }
                        if(n_parametros_iguais==nood->funcdecl->n_parametros_entrada){
                            novo_elemento->repetido = 1;
                            break;
                        }
                    }
                }
            }
            if(nood->tipo_decl == 2){
                if(strcmp(novo_elemento->id, nood->id)==0){
                    if(strcmp(novo_elemento->id, "_")==0){
                        novo_elemento->repetido =1;
                        printf("Linha %d, coluna %d: Simbolo %s(", novo_elemento->linha, novo_elemento->coluna, novo_elemento->id);
                        elementos_tabela *aux_var = novo_elemento->funcdecl->variaveis;
                        for(int i=0; i<novo_elemento->funcdecl->n_parametros_entrada;i++){
                            printf("%s", aux_var->vardecl->tipo);
                            if(i==novo_elemento->funcdecl->n_parametros_entrada-1){
                                printf(",");
                            }
                            aux_var = aux_var->next;
                        }
                        printf(") já foram definidos\n");
                        break;
                    }
                }
            }
        }
        aux = aux->next;
    }
    inserir_func(novo_elemento, &tabela_global);
    //printf("here2\n");
    struct no *body_Metodo = no->filhos[1];
    //printf("tipo %s, valor %s\n",body_Metodo->tipo, body_Metodo->valor);
    for(int i=1;i<no->num_filhos;i++){
        if(strcmp(no->filhos[i]->tipo, "VarDecl")==0){
            //printf("vardecl valor: %s\n", no->filhos[i]->filhos[1]->valor);
            (novo_elemento->funcdecl->n_parametros)++;
            char *var = (char *) malloc(sizeof(char)*(strlen(no->filhos[i]->filhos[0]->tipo)+1));
            strcpy(var, no->filhos[i]->filhos[0]->tipo);
            inserir_vardecl(no->filhos[i]->filhos[1]->valor, var, "null", &(novo_elemento->funcdecl->variaveis), no->filhos[i]->filhos[1]->linha, no->filhos[i]->filhos[1]->coluna);
            free(var);
        } else if(strcmp(no->filhos[i]->tipo, "MethodDecl")==0){
            //printf("methoddecl valor: %s\n", no->filhos[i]->filhos[0]->valor);
            (novo_elemento->funcdecl->n_parametros)++;
            char *valor = (char *) malloc(sizeof(char)*(strlen(no->filhos[i]->filhos[0]->valor)+1));
            strcpy(valor, no->filhos[i]->filhos[0]->valor);
            inserir_func(cria_funcdecl(valor, "void", no->filhos[i]->filhos[0]->linha, no->filhos[i]->filhos[0]->coluna),&(novo_elemento->funcdecl->variaveis));
            free(valor);
        } else{ //if, calls, whiles, etc
            continue;
        }
    }
    //printf("here3\n");
    free(func_id);
    free(nome_return);
}

void decl_field(no* no){
    char *tipo = (char *) malloc(sizeof(char)*(strlen(no->filhos[0]->tipo)+1));
    strcpy(tipo, no->filhos[0]->tipo);
    char *valor = (char*) malloc(sizeof(char)*(strlen(no->filhos[1]->valor)+1));
    strcpy(valor, no->filhos[1]->valor);
    elementos_tabela *novo_elemento =inserir_decls(valor, tipo, "null", no->filhos[1]->linha, no->filhos[1]->coluna);
    if(no->filhos[2] != NULL){
        //printf("filho2!=NULL -> %s\n", no->filhos[2]->valor);
        //printf("filho2!=NULLtipo -> %s\n", no->filhos[2]->tipo);
        if(strcmp(no->filhos[2]->tipo,"Virgula")==0 && no->filhos[2]->num_filhos>0){
            int contaVirgulas =1;
            struct no *no_aux=no->filhos[2];
            struct no *no_aux2=no->filhos[2];
            while (strcmp(no_aux->filhos[0]->tipo,"Virgula")==0)
            {
                no_aux=no_aux->filhos[0];
                contaVirgulas++;
            }
            for(int i=0;i<contaVirgulas;i++){
                char *valor2 = (char*) malloc(sizeof(char)*(strlen(no_aux2->filhos[1]->filhos[0]->valor)+1));
                strcpy(valor2, no_aux2->filhos[1]->filhos[0]->valor);
                elementos_tabela *novo_elemento1 = inserir_decls(valor2, tipo, "null", no_aux2->filhos[1]->filhos[0]->linha, no_aux2->filhos[1]->filhos[0]->coluna);
                inserir_func(novo_elemento1, &tabela_global);
                no_aux2 = no_aux2->filhos[0];
            } 
        }
    }
    
    elementos_tabela *aux = tabela_global;

    while (aux !=NULL)
    {
        elementos_tabela *nood =procurar_elementos(novo_elemento->id, aux);
        if(nood!=NULL){
            if(nood->tipo_decl == novo_elemento->tipo_decl){
                if(strcmp(novo_elemento->id, "_")==0){
                    novo_elemento->repetido =1;
                    printf("Linha %d, coluna, %d: Simbolo: %s está reservado.\n", no->filhos[1]->linha, no->filhos[1]->coluna, no->filhos[1]->valor);
                    break;
                }
                novo_elemento->repetido =1;
                printf("Linha %d, coluna, %d: Simbolo: %s está definido.\n", no->filhos[1]->linha, no->filhos[1]->coluna, no->filhos[1]->valor); 
                break;
            }
        }
        aux = aux->next;
    }
    if (strcmp(novo_elemento->id,"_")==0 && novo_elemento->repetido == 0){
        novo_elemento->repetido =1;
        printf("Linha %d, coluna %d: Simbolo %s está reservado\n", novo_elemento->linha, novo_elemento->coluna, novo_elemento->id);
    }
    inserir_func(novo_elemento, &tabela_global);
    free(tipo);
    free(valor);
}


struct no *criar(char* tipo, char* valor, int linha, int coluna){
    //printf("---treeCriar---");
    struct no* new = (struct no *) malloc(sizeof(no));
    if(new == NULL){
        return NULL;
    }
    new->tipo = tipo;
    new->valor = valor;
    new->pai = NULL;
    new->bros = NULL;
    new->num_filhos = 0;
    new->linha = linha;
    new->coluna = coluna;
    return new;
}

struct no *filho(struct no* pai, struct no* filho){
    //printf("---treeFilho---");
    if(pai == NULL || filho == NULL){
        return NULL;
    }
    pai->filhos[pai->num_filhos] = filho;
    pai->num_filhos++;
    filho->pai = pai;
    struct no *temp = filho->bros;
    while(temp != NULL){
        temp->pai = pai;
        pai->filhos[pai->num_filhos] = temp;
        pai->num_filhos++;
        temp = temp->bros;
    }
    
    return pai;
}

struct no *add_bro(struct no* aux, struct no* aux1){
    //printf("---treeBro---");
    struct no *temp = aux;
    if(temp != NULL){
        while(temp->bros != NULL){
            temp = temp->bros;
        }
        temp->bros = aux1;
    }
    return aux;
}

void imprimir(struct no* root, int profundidade){
    //printf("something \n");
    if(root == NULL){
        //printf("---treeImprimir---");
        return;
    }
    for(int i=0; i<profundidade; i++){
        printf("--");
    }
    if(strcmp(root->valor, "")==0){
        printf("%s\n", root->tipo);
    } else {
        printf("%s %s\n", root->tipo, root->valor);
    }
    for(int j=0;j<root->num_filhos;j++){
        imprimir(root->filhos[j], profundidade+1);
    }

    free(root);
}
