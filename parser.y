%{
#include <stdio.h>
#include <ctype.h>
#include "sym.h"
extern int yylineno;
extern int global_scope;
extern VAR *SymTab;
FILE * output;
#define UNDECL  0
#define INT     1
#define BOOL    2
#define FLT     3
#define IMPORTDATABASE 111111 //usado para saber se ja foi add um import do pandas
#define AddVAR(n,t) SymTab=MakeVAR(n,t,SymTab)
#define ASSERT(x,y) if(!(x)) printf("%s na  linha %d\n",(y),yylineno)
%}

%define parse.error verbose //aparecer mais detalhes dos erros
//docker run  -it  -v "%cd%":/usr/src  phdcoder/flexbison
%union {
	char * ystr;
	int   yint;// 1
	float yflt;
}

%{
#include <stdlib.h>

struct node {
    int data;
    struct node *next;
};

struct node *head = NULL;

void addImport(struct node **head, int val) {
    //create a new node
    struct node *newNode = malloc(sizeof(struct node));
    newNode->data = val;
    newNode->next = NULL;

	//if head is NULL, it is an empty list
    if(*head == NULL) {
        *head = newNode;
	}
    else {//Otherwise, find the last node and add the newNode
        struct node *lastNode = *head;

        //last node's next address will be NULL.
        while(lastNode->next != NULL) {
            lastNode = lastNode->next;
        }
        //add the newNode at the end of the linked list
        lastNode->next = newNode;
    }
}

void printList(struct node *head) {
    struct node *temp = head;
    //iterate the entire linked list and print the data
    while(temp != NULL) {
        printf("%d->", temp->data);
        temp = temp->next;
    }
    printf("NULL\n");
}

int encontreImport(struct node *head, int key) {
    struct node *temp = head;
    //iterate the entire linked list and print the data
    while(temp != NULL) {
         //key found return 1.
         if(temp->data == key)
             return 1;
         temp = temp->next;
    }
    //key not found
    return -1;
}

%}


%start program
%token SKIP IF THEN READ WRITE FI
%token <yint> NUMINT // antes era NUMBER agora subistitui
%token <yflt> NUMFLT
%token <ystr> IDENTIFIER
%token CARREGA TREINAMENTO PREDICAO RESULTADO ACURACIA DIVISAO ESCALONAR TRANSFORMAR
%token ASSGNOP
%left '>' '<' '='
%left '-' '+'
%left '*' '/'
%left '^'
%type  <yint>  exp

%%

program : commands { }
;

commands : /* empty */
| command ';' /*{ fprintf(output, ";\n"); }*/ commands
;
command : SKIP
| CARREGA {//verifica se ja add o import no código
	if(encontreImport(head, IMPORTDATABASE) == -1){
		addImport(&head, IMPORTDATABASE);
		fprintf(output, "import pandas as pd\n");
	}
  }
  IDENTIFIER {
	VAR *p=FindVAR($3);
	if(p==NULL){//verifica se a base ainda não foi adicionada
	  	AddVAR($3,FLT);// adicionando
	}
	else {
		printf("base de dados ja foi carregada");
	}
  }
  IDENTIFIER { //pegando o nome da base.csv
		fprintf(output, "%s = pd.read_csv('%s.csv')", $3, $5);
  }  
  {
	VAR *p=FindVAR($3);/*buscando o nome da variável que guardou a base para concatenar com o nome das
	                     variáveis que serão geradas no python*/
	fprintf(output, "\n\n#Substituir a linha abaixo pela coluna de inicio dos atributos previsores\n");
	fprintf(output, "inicio_previsores_%s = 0\n", p->name);
	fprintf(output, "#Substituir a linha abaixo pelo numero da coluna classe\n");
	fprintf(output, "coluna_classe_%s = None\n\n", p->name);
	fprintf(output, "previsores_%s = %s.iloc[:, inicio_previsores_%s:coluna_classe_%s].values\n", p->name, p->name, p->name, p->name);
	fprintf(output, "classe_%s = %s.iloc[:, coluna_classe_%s].values\n\n",p->name, p->name, p->name);
}
| ESCALONAR {
	fprintf(output, "\n#----------Escalonando os atributos -----------#\nfrom sklearn.preprocessing import StandardScaler\nscaler = StandardScaler()\nprevisores = scaler.fit_transform(previsores)\n");
}
| DIVISAO { fprintf(output, "\n#------------Dividindo a base de dados para Treinamento------------#\nfrom sklearn.model_selection import train_test_split\nporcentagem_divisao = "); } exp {
	fprintf(output, "\nprevisores_treinamento, previsores_teste, classe_treinamento, classe_teste = train_test_split(\n    previsores, classe, test_size=porcentagem_divisao\n)\n");
}
| TREINAMENTO {
	fprintf(output, "\n#---------- Treinando o modelo -----------#\nmodelo.fit(previsores_treinamento, classe_treinamento)\n");
}
| PREDICAO {
	fprintf(output, "\n#---------- Fazendo as predições -----------#\nprevisoes = modelo.predict(previsores_teste)\n");
}
| RESULTADO resultados {}
| READ IDENTIFIER {
	VAR *p=FindVAR($2);//procura o conteúdo de 2
	ASSERT( (p!=NULL),"Identificador Não declarado");//se achou p != nulo
	if(p->type == FLT){
		fprintf(output, "scanf(\"%%f\", %s); \n", $2);
	}
	else if(p->type == INT){
		fprintf(output, "scanf(\"%%d\", %s); \n", $2);
	}
}
| WRITE IDENTIFIER {
	VAR *p=FindVAR($2);//procura o conteúdo de 2

	if(p!= NULL){ //se for algo declarado
		if(p->type == FLT){
			fprintf(output, "printf(\"%%f\", %s); \n", $2);
			//printf("valor: %d", num);
		}
		else if(p->type == INT){
			fprintf(output, "printf(\"%%d\", %s); \n", $2);
		}
	}
	else {//se não for inteiro nem float...
		fprintf(output, "printf(\"%s\");\n", $2);
	}
}
| IDENTIFIER ASSGNOP { fprintf(output, "%s = ", $1); } exp { 
	VAR *p=FindVAR($1);
	ASSERT((p!=NULL),"Identificador Não declarado/");
	ASSERT( (p->type == INT && $4 == INT) || (p->type == FLT && ($4 == INT || $4 == FLT) ), " Tipo incompatível de dados");
	fprintf(output, ";\n");
}
| {fprintf(output,"if");} IF exp {fprintf(output,"{\n");} THEN commands FI {fprintf(output,"}\n");} {//S2 é o retorno de tudão da expressão
	ASSERT( $3 == BOOL, "Valor boleano esperado");
}
;

resultados: ACURACIA {
	fprintf(output, "\n#---------- Checando a pricisão ----------#\nfrom sklearn.metrics import accuracy_score\nprecisao = accuracy_score(classe_teste, previsoes)\n");
}
;

exp : NUMINT  { $$= INT; fprintf(output, "%d", $1);}
| NUMFLT 	  { $$= FLT; fprintf(output, "%f", $1);}
| IDENTIFIER  {// a única coisa guardada na tabela de simbolos
	VAR *p=FindVAR($1);
	//printf(" Salvando variável no scopo: -> %d <- ", global_scope);
	ASSERT((p!=NULL),"Identificador Não declarado");
	$$= (p!=NULL)? p->type:UNDECL;
	fprintf(output, "%s", $1);
}
| '(' {fprintf(output,"(");} exp ')' {fprintf(output,")");}  { $$= $3;}
;

%%


main( int argc, char *argv[] ) {
	output = fopen("output.py","w");
	init_stringpool(10000); //memória que vai guardar as strings
	if ( yyparse () == 0) printf("codigo sem erros");
}

yyerror(char *s) { /* Called by yyparse on error */
	printf ("%s  na linha %d\n", s, yylineno );
}

