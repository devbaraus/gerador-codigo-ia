/* Simple Symbol table
 * November 2001, A. Jost, Dalhousie University
 */

#include <stdio.h>
#include <stdlib.h>
#include "sym.h"
static char *strings;
static char *strp;
static int strsize = 0;
int global_scope = 0;
//char *calloc(int,int);
int escopo1Destruido = 0;
VAR *SymTab = NULL;

VAR *MakeVAR(char *name, int type, VAR *next) {
	VAR *p;
	p = NEW(VAR);
	p->name = name;
	p->type = type;
	p->scope = global_scope;
	p->next = next;
	return p;
}

VAR *FindVAR(char *name) {
	VAR *p = SymTab;
	printf("\nTo procurando por: %s", name);

	while( (p != NULL) && (p->name != name) ) {
		printf("\n [nome: %s, scopo: %d] ",p->name, p->scope);
		p = p->next;
	}

	return p;
}

VAR *ChecarEscopo1(char *name) {
	VAR *p = SymTab;
	printf("\nTo procurando por: %s", name);

	while( (p != NULL) && (p->name != name) ) {
		printf("\n [nome: %s, scopo: %d] ",p->name, p->scope);
		p = p->next;
	}

	if (p!=NULL) {//se encontrou, checar se é do scopo 1 ou 0
		printf("\nEstou retornando:  { nome: %s, scope: %d }   scopo_global: %d ",p->name,p->scope, global_scope);
		if((p->scope != 1)){//se a variavel que encontrou for diferente do escopo 1
			p = NULL;//então retorna nulo
			printf("Entrou aqui ");
		}
	}

	return p;
}

VAR *DestruirVAR() {
	VAR *atual = SymTab;
	VAR *proximo = NULL;

	while(atual != NULL) {
		printf("\n [nome: %s, scopo: %d] ",atual->name, atual->scope);
		escopo1Destruido = 0;

		if (atual->next != NULL) {//se tiver um próximo...
			proximo = atual->next;//pegue o próximo
			// if(atual->scope == 1){//se começar por um ponteiro de escopo 1
			// 	printf("*p: %s, scope: %d ~> %s ",atual->name,atual->scope,proximo->name);
			// 	printf("O atual era: ~>> %s ", atual->name);
			// 	aux = atual->next;
			// 	free(atual);//liberando o atual
			// 	atual = aux;//atual se torna o proximo
			// 	printf("Agora o atual é: ~>> %s", atual->name);
			// 	escopo1Destruido = 1;
			// }

			if (proximo->scope == 1) {
				printf(" proximo liberado: %d ", atual->next);
				atual->next = NULL;
				atual->next = proximo->next;//proximo do atual recebe o proximo do proximo
				free(proximo);//liberar o proximo ponteiro
				proximo = NULL;
				printf("Liberando memória do ponteiro: %d, proximo: %d, var: %s, scopo: %d", atual,atual->next,atual->name, atual->scope);
				escopo1Destruido = 1;
			}
		}
		if (escopo1Destruido == 0){//só se não destruiu o proximo do escopo 1
			atual = atual->next;
		}
	}
	//return atual;
}

/* Simple string table manager for use with symbol table */
void init_stringpool(int strs) {
	if ( strs <= 0 ) return;
	strings = (char *) calloc(strs, sizeof(char));

	if ( strings == NULL ) {
		fprintf(stderr, "Cannot allocate string table of size %d\n", strs);
		exit(1);
	}
	strsize = strs;
	strp = strings;
}

/* Add a string to string table and return a pointer to it.
 * If string is already in the table, return pointer to one found.
 * Guarantees that every unique string has a unique pointer.
 */
char *stringpool(char *s) {
	register char *start=strp;
	register char *p = strings;
	register char *q, *r;
	
    /* Stick a copy of the string at the end of the table */
	while ( *s != '\0' ) {
		if ( strp >= &(strings[strsize-2]) ) {
			fprintf(stderr, "sym: string table overflow (%d chars)\n", strsize);
			exit(1);
		}
		*strp++ = *s++;
	}
	*strp++ = '\0';
	/* Make sure this is not a duplicate */
	while(p<strp) {
	    r=p; q=start;
	    while((*p==*q)&&(*p!='\0')) { p++; q++; }
	    if (*p==*q) break; /* found it */
	    /* else advance p past next null; try again */
	    while (*p++) ;
	}
	if (r != start) { /* already in table: trash new copy */
	    strp = start;
	    start = r;
	}
	return( start );
}
