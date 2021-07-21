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
#define IMPORTIMPUTER  121212
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
#include <string.h>

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

char* pegarLetras(char line[]){
   int i, j;
   for (i = 0, j; line[i] != '\0'; ++i) {
      while (!(line[i] >= 'a' && line[i] <= 'z') && !(line[i] >= 'A' && line[i] <= 'Z') && !(line[i] == '\0')) {
         for (j = i; line[j] != '\0'; ++j) {
            line[j] = line[j + 1];
         }
         line[j] = '\0';
      }
   }
   return line;	
}

%}


%start program
%token <yint> NUMINT // antes era NUMBER agora subistitui
%token <yflt> NUMFLT
%token <ystr> IDENTIFIER PARAMETRO
%token CARREGA TREINAMENTO PREDICAO RESULTADO ACURACIA DIVISAO ESCALONAR TRANSFORMAR
%token ASSGNOP FALTANTES
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
command : CARREGA {//verifica se ja add o import no código
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
  IDENTIFIER {
	fprintf(output, "%s = pd.read_csv('%s.csv')\n\n", $3, $5);//pegando o nome da base.csv
  }
  exp exp {//se passou previsores por parâmetro ou não :)
	   VAR *p=FindVAR($3);/*buscando o nome da variável que guardou a base para concatenar com o nome das
							variáveis que serão geradas no python*/
	   if($8 == UNDECL) {// se não passou o parâmetro
			fprintf(output, "#Substituir a linha abaixo pela coluna de inicio dos atributos previsores\n");
			fprintf(output, "inicio_previsores_%s = 0\n", p->name);
	   }
	   else {//se passou o parâmetro coluna previsores, usar ele
		   fprintf(output, "#Substituir a linha abaixo pela coluna de inicio dos atributos previsores\n");
		   fprintf(output, "inicio_previsores_%s = %d\n", p->name, $8);
	   }

	   fprintf(output, "#Substituir a linha abaixo pelo numero da coluna classe\n");
	   fprintf(output, "coluna_classe_%s = %d\n\n", p->name, $7);
	   fprintf(output, "previsores_%s = %s.iloc[:, inicio_previsores_%s:coluna_classe_%s].values\n", p->name, p->name, p->name, p->name);
	   fprintf(output, "classe_%s = %s.iloc[:, coluna_classe_%s].values\n\n\n",p->name, p->name, p->name);
}
| FALTANTES {
	if(encontreImport(head, IMPORTIMPUTER) == -1){
		addImport(&head, IMPORTIMPUTER);
		fprintf(output, "#-------- Tratando os valores faltantes -----------#\n");
		fprintf(output, "from sklearn.impute import SimpleImputer\n");
		fprintf(output,"import numpy as np\n");
	}
  }
  IDENTIFIER exp {
	  VAR *p=FindVAR($3);//checar se a base declarada existe...
	  if(p!=NULL){//se passou qual é a estratégia
		  //printf(" ~>%s<~",estrategia->name);
		  if($4 != UNDECL) {// se não passou o parâmetro
				fprintf(output, "estrategia = \"%s\"\n", $4);
				fprintf(output, "imputer = SimpleImputer(missing_values = np.nan, strategy = estrategia)\n");
		  }
		  else{//se nao passou a estratégia, salvar como padrão.
			  fprintf(output, "imputer = SimpleImputer(missing_values = np.nan)\n");
		  }
		  fprintf(output, "imputer = imputer.fit(previsores_%s[:, inicio_previsores_%s:coluna_classe_%s])\n",p->name,p->name,p->name);
		  fprintf(
			  output,
			  "previsores_%s[:, inicio_previsores_%s:coluna_classe_%s] = imputer.transform(previsores_%s[:, inicio_previsores_%s:coluna_classe_%s])\n\n\n"
			  ,p->name,p->name,p->name,p->name,p->name,p->name
		  );

	  }
	  else{
		  printf("Base de dados não existe");
	  }
  }
| ESCALONAR {
	fprintf(output, "#----------Escalonando os atributos -----------#\nfrom sklearn.preprocessing import StandardScaler\nscaler = StandardScaler()\nprevisores = scaler.fit_transform(previsores)\n");
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
| IDENTIFIER ASSGNOP { fprintf(output, "%s = ", $1); } exp { 
	VAR *p=FindVAR($1);
	ASSERT((p!=NULL),"Identificador Não declarado/");
	ASSERT( (p->type == INT && $4 == INT) || (p->type == FLT && ($4 == INT || $4 == FLT) ), " Tipo incompatível de dados");
	fprintf(output, ";\n");
}
;

resultados: ACURACIA {
	fprintf(output, "\n#---------- Checando a pricisão ----------#\nfrom sklearn.metrics import accuracy_score\nprecisao = accuracy_score(classe_teste, previsoes)\n");
}
;

exp : /* ε */ { $$=UNDECL; }
| NUMINT  { }
| NUMFLT 	  { $$= FLT; fprintf(output, "%f", $1);}
| IDENTIFIER  {// a única coisa guardada na tabela de simbolos
	//VAR *p=FindVAR($1);
	AddVAR($1, INT);
	//ASSERT((p!=NULL),"Identificador Não declarado");
	//$$= (p!=NULL)? p->type:UNDECL;
	//fprintf(output, "%s", $1);
}
| '(' {fprintf(output,"(");} exp ')' {fprintf(output,")");}  { $$= $3;}
| PARAMETRO {
	AddVAR($1, INT);
	VAR *p=FindVAR($1);
	char comando[50];//usado para guardar o comando sem modificar a string original
	strcpy(comando, p->name);
	pegarLetras(comando);
	printf("- %s -", comando);
}
/* | exp */
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