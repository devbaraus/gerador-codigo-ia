%{
#include <stdio.h>
#include <ctype.h>
#include "sym.h"
#include <time.h>
extern int yylineno;
extern int global_scope;
extern VAR *SymTab;
FILE * output;
#define UNDECL  0
#define INT     1
#define BOOL    2
#define FLT     3
#define IMPORTDATABASE     111111 //usado para saber se ja foi add um import do pandas
#define IMPORTIMPUTER      121212
#define IMPORTSCALER       555555
#define IMPORTLABELENCODER 222222
#define IMPORTDIVISAO      333333
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

program : { 
	time_t t = time(NULL);
    struct tm tm = *localtime(&t);
	fprintf(output, "\"\"\"\nTemplate gerado por Flauberth Duarte.\n");
    fprintf(
		output,
		"Gerado em: %02d-%02d-%d %02d:%02d:%02d\n", 
		tm.tm_mday, tm.tm_mon + 1, tm.tm_year + 1900, tm.tm_hour-3, tm.tm_min, tm.tm_sec
	);
	fprintf(output,"#-------Encontre me em: -------------#\n");
	fprintf(output, "Github: https://github.com/Samanosukeh\n");
	fprintf(output,"Site:   www.samanosuke.com.br\n\"\"\"\n\n");
} commands
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
	fprintf(output, "#-----------Carregando base de dados-----------#\n");
	fprintf(output, "%s = pd.read_csv('%s.csv')\n\n", $3, $5);//pegando o nome da base.csv
  }
  exp exp {//se passou previsores por parâmetro ou não :)
	   VAR *p=FindVAR($3);/*buscando o nome da variável que guardou a base para concatenar com o nome das
							variáveis que serão geradas no python*/
	   if($8 == UNDECL) {// se não passou o parâmetro
			fprintf(output, "inicio_previsores_%s = 0\n", p->name);
	   }
	   else {//se passou o parâmetro coluna previsores, usar ele
		   fprintf(output, "inicio_previsores_%s = %d\n", p->name, $8);
	   }

	   fprintf(output, "coluna_classe_%s = %d\n\n", p->name, $7);
	   fprintf(output, "previsores_%s = %s.iloc[:, inicio_previsores_%s:coluna_classe_%s].values\n", p->name, p->name, p->name, p->name);
	   fprintf(output, "classe_%s = %s.iloc[:, coluna_classe_%s].values\n\n\n",p->name, p->name, p->name);
}
| FALTANTES {
	fprintf(output, "#-------- Tratando os valores faltantes -----------#\n");
	if(encontreImport(head, IMPORTIMPUTER) == -1){
		addImport(&head, IMPORTIMPUTER);
		fprintf(output, "from sklearn.impute import SimpleImputer\n");
		fprintf(output,"import numpy as np\n");
	}
  }
  IDENTIFIER exp {
	  VAR *p=FindVAR($3);//checar se a base declarada existe...
	  if(p!=NULL){//se passou qual é a estratégia
		  //printf(" ~>%s<~",estrategia->name);
		  if($4 != UNDECL) {// se passou o parâmetro da estratégia...
			  VAR *t=FindVAR($4);
			  int teste1 = strcmp(t->name,"media");
			  int teste2 = strcmp(t->name,"mediana");
			  int teste3 = strcmp(t->name,"mais_frequente");
			  char *string="";
			  if(teste1 == 0){
				  fprintf(output, "estrategia = \"mean\"\n");
			  }
			  else if (teste2 == 0){
				  fprintf(output, "estrategia = \"median\"\n");
			  }
			  else if (teste3 == 0){
				  fprintf(output, "estrategia = \"most_frequent\"\n");
			  }
			  else{
				  printf("--  Estratégia não reconhecida --");
				  //estratégia média é escolhida por padrão então...
				  fprintf(output, "estrategia = \"mean\"\n");
			  }
			  //fprintf(output, "estrategia = \"%s\"\n", string);
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
| ESCALONAR IDENTIFIER {
	fprintf(output, "#----------Escalonando os atributos -----------#\n");
	if(encontreImport(head, IMPORTSCALER) == -1){
		addImport(&head, IMPORTSCALER);
		fprintf(output, "from sklearn.preprocessing import StandardScaler\n");
	}
	fprintf(output, "scaler = StandardScaler()\n");
	VAR *p=FindVAR($2);
	if(p!=NULL){//se achou a base que ta tentando escalonar...
		fprintf(output, "previsores_%s = scaler.fit_transform(previsores_%s)\n",p->name,p->name);
	}
	else{
		printf("É necessário passar a base que será escalonada");
	}
	fprintf(output,"\n\n");
}
| TRANSFORMAR IDENTIFIER IDENTIFIER {
	fprintf(output, "#----------Transformação categórica pra numérica -----------#\n");
	if(encontreImport(head, IMPORTLABELENCODER) == -1){
		addImport(&head, IMPORTLABELENCODER);
		fprintf(output, "from sklearn.preprocessing import LabelEncoder\n");
	}
	fprintf(output, "labelencorder = LabelEncoder()\n");
	AddVAR($3, INT);//adicionando o 3 parâmetro para checar a string
	VAR *p=FindVAR($3);
	int teste1 = strcmp(p->name,"classe");
	int teste2 = strcmp(p->name,"previsores");
	if(teste1 == 0){//se é classe
		fprintf(output, "classe_%s = labelencorder.fit_transform(classe_%s)",$2,$2);
	}
	else if(teste2 == 0){//senão se for previsores..
		fprintf(output, "previsores_%s[\n    # Escreva aqui as colunas que queira aplicar o label encoder\n", $2);
		fprintf(output, "    # em formato de lista ex: [1, 3, 6, 7]\n");
		fprintf(output, "] = labelencorder.fit_transform(previsores_%s[\n",$2);
		fprintf(output, "    # Escreva aqui as colunas que queira aplicar o label encoder\n");
		fprintf(output, "    # em formato de lista ex: [1, 3, 6, 7]\n])");
	}
	else{//se não foi passado nem classe nem previsores...
		printf("É necessário passar o conjunto que será aplicado o labelEncoder");
	}
	fprintf(output,"\n\n");
	
}
| DIVISAO IDENTIFIER NUMINT { 
	fprintf(output, "\n#------------Dividindo a base de dados para Treinamento------------#\n");
	if(encontreImport(head, IMPORTDIVISAO) == -1){
		addImport(&head, IMPORTDIVISAO);
		fprintf(output, "from sklearn.model_selection import train_test_split\n");
	}
	fprintf(output, "porcentagem_divisao = 0.%d\n", $3);
	VAR *p=FindVAR($2);
	fprintf(
		output,
		"previsores_treinamento_%s, previsores_teste_%s, classe_treinamento_%s, classe_teste_%s = train_test_split(\n"
		,p->name,p->name,p->name,p->name
	);
	fprintf(output, "    previsores_%s, classe_%s, test_size=porcentagem_divisao\n)\n",p->name, p->name);
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