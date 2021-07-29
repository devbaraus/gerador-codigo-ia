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
#define STR     4
#define IMPORTDATABASE     111111 //usado para saber se ja foi add um import do pandas
#define IMPORTIMPUTER      121212
#define IMPORTSCALER       555555
#define IMPORTLABELENCODER 222222
#define IMPORTDIVISAO      333333
#define IMPORTSVC          444444
#define IMPORTRFC          424242 //Random Forest Classifier
#define IMPORTKNNC         123456 //KNN Classifier
#define IMPORTACCURACY     324324
#define IMPORTF1           666666
#define IMPORTLINEAR       616161
#define IMPORTPOLINOMIAL   626262
#define IMPORTRFR          636363
#define AddVAR(n,t) SymTab=MakeVAR(n,t,SymTab)
#define ASSERT(x,y) if(!(x)) printf("%s na  linha %d\n",(y),yylineno)
int modelo = 0; /* 0: classificação | 1: regressão */
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
%token <yint> NUMINT
%token <yflt> NUMFLT
%token <ystr> IDENTIFIER PARAMETRO
%token CARREGA TREINAMENTO PREDICAO RESULTADO FALTANTES DIVISAO ESCALONAR TRANSFORMAR
%token CLASSIFICADOR REGRESSOR ACURACIA F1
%left '>' '<' '='
%left '-' '+'
%left '*' '/'
%left '^'

%type  <yint>  exp param

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
			  fprintf(output, "imputer = SimpleImputer(missing_values = np.nan, strategy = estrategia)\n");
		  }
		  else{//se nao passou a estratégia, salvar como padrão.
			  fprintf(output, "imputer = SimpleImputer(missing_values = np.nan)\n");
		  }
		  fprintf(output, "imputer = imputer.fit(previsores_%s[:, inicio_previsores_%s:coluna_classe_%s])\n",p->name,p->name,p->name);
		  fprintf(
			  output,
			  "previsores_%s[:, inicio_previsores_%s:coluna_classe_%s] = imputer.transform(\n",p->name,p->name,p->name
		  );
		  fprintf(output, "    previsores_%s[:, inicio_previsores_%s:coluna_classe_%s]\n)\n\n\n",p->name,p->name,p->name);


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
	fprintf(output, "    previsores_%s, classe_%s, test_size=porcentagem_divisao\n)\n\n",p->name, p->name);
 }
| CLASSIFICADOR { modelo = 0; } modelo
| REGRESSOR { modelo = 1; } modelo
| TREINAMENTO IDENTIFIER IDENTIFIER {
	fprintf(output, "\n#---------- Treinando o modelo -----------#\n");
	/*
	É preciso buscar para ver se o modelo foi instanciado
	É preciso buscar se a base foi instanciada
	*/
	VAR *modelo=FindVAR($2);
	VAR *base=FindVAR($3);
	fprintf(output, "modelo_%s.fit(previsores_treinamento_%s, classe_treinamento_%s)\n",modelo->name, base->name, base->name);
}
| PREDICAO IDENTIFIER IDENTIFIER{
	fprintf(output, "\n#---------- Fazendo a predição -----------#\n");
	VAR *modelo=FindVAR($2);
	VAR *base=FindVAR($3);
	fprintf(output, "previsoes_%s = modelo_%s.predict(previsores_teste_%s)\n", base->name, modelo->name, base->name);
}
| RESULTADO resultados
;

modelo: IDENTIFIER IDENTIFIER param param {
	/*é preciso armazenar na tabela o nome da variável que 
	guarda o modelo para que ela não seja mais usada*/
	VAR *buscar = FindVAR($1);
	if (buscar == NULL){
		AddVAR($1,INT);
	}
	if(modelo == 0){ // se for um modelo de classificação...
		if(strcmp($2, "svm") == 0){// se o classificador for SVM...
			fprintf(output, "#---------- SVM -----------#\n");
			if(encontreImport(head, IMPORTSVC) == -1){//primeira vez importanto o SVC?
				addImport(&head, IMPORTSVC);// add ele na tabela de símbolos
				fprintf(output, "from sklearn.svm import SVC\n");
			}
			if ($3 != NULL)
				fprintf(output, "modelo_%s = SVC(kernel=\"%s\", random_state=0)\n\n",$1, $3);
			else
				fprintf(output, "modelo_%s = SVC(random_state=0)\n\n",$1);
		}
		else if (strcmp($2, "randomforest") == 0){ // se o classificador for random forest...
			fprintf(output, "#---------- RandomForest -----------#\n");
			if(encontreImport(head, IMPORTRFC) == -1){//primeira vez importanto o Random Forest?
				addImport(&head, IMPORTRFC);// add ele na tabela de símbolos
				fprintf(output, "from sklearn.ensemble import RandomForestClassifier\n");
			}
			fprintf(output, "modelo_%s = RandomForestClassifier(n_estimators=%d, random_state=0)\n\n",$1, $3);
		}
		else if (strcmp($2, "knn") == 0){ // se o classificador for KNN...
			fprintf(output, "#---------- KNN -----------#\n");
			if(encontreImport(head, IMPORTKNNC) == -1){//primeira vez importanto o KNN?
				addImport(&head, IMPORTKNNC);// add ele na tabela de símbolos
				fprintf(output, "from sklearn.neighbors import KNeighborsClassifier\n");
			}
			fprintf(output, "modelo_%s = KNeighborsClassifier(n_neighbors=%d, metric='minkowski', p=2)\n",$1, $3);
		}
	}
	else if(modelo == 1){//se for regressor...
		if(strcmp($2, "linear") == 0){// se o regressor for SVM...
			fprintf(output, "#---------- Regressão Linear -----------#\n");
			if(encontreImport(head, IMPORTLINEAR) == -1){
				addImport(&head, IMPORTLINEAR);// add ele na tabela de símbolos
				fprintf(output, "from sklearn.linear_model import LinearRegression\n");
			}
			fprintf(output, "modelo_%s = LinearRegression()\n\n",$1);
		}
		else if(strcmp($2, "polinomial") == 0){// se o classificador for SVM...
			fprintf(output, "#---------- Regressão Polinomial -----------#\n");
			if(encontreImport(head, IMPORTPOLINOMIAL) == -1){//primeira vez importanto o SVC?
				addImport(&head, IMPORTPOLINOMIAL);// add ele na tabela de símbolos
				fprintf(output, "from sklearn.preprocessing import PolynomialFeatures\n");
			}

			if ($3 != NULL){//passou a quantidade do polinômio?
				fprintf(output, "poly = PolynomialFeatures(degree = %d)\n", $3);
				if($4 != NULL){
					VAR *base=FindVAR($4);
					fprintf(output, "previsores_%s = poly.fit_transform(previsores_%s)\n", base->name, base->name);
					/* Antes de instanciar o regressor linear, verificar se ja foi importado do SKLEARN*/
					if(encontreImport(head, IMPORTLINEAR) == -1){
						addImport(&head, IMPORTLINEAR);// add ele na tabela de símbolos
						fprintf(output, "from sklearn.linear_model import LinearRegression\n");
					}
					fprintf(output, "modelo_%s = LinearRegression()\n\n",$1);
					
				}
			}
			else{
				printf("\n~> É necessário informar o grau do polinômio na regressão polinomial <~\n");
			}
		}
		else if (strcmp($2, "randomforest") == 0){
			fprintf(output, "#---------- Regressor RandomForest -----------#\n");
			if(encontreImport(head, IMPORTRFR) == -1){//primeira vez importanto o Regressor Random Forest?
				addImport(&head, IMPORTRFR);// add ele na tabela de símbolos
				fprintf(output, "from sklearn.ensemble import RandomForestRegressor\n");
			}
			if ($3 != NULL)//se passou a quantidade de arvores...
				fprintf(output, "modelo_%s = RandomForestRegressor(n_estimators=%d, random_state=0)\n\n",$1, $3);
			else          //se não passou, deixar a quantidade padrão do RFR
				fprintf(output, "modelo_%s = RandomForestRegressor(random_state=0)\n\n",$1);
		}
	}
}

resultados: IDENTIFIER ACURACIA {
	fprintf(output, "\n#---------- Checando a precisão ----------#\n");
	if(encontreImport(head, IMPORTACCURACY) == -1){
		addImport(&head, IMPORTACCURACY);
		fprintf(output, "from sklearn.metrics import accuracy_score\n");
	}
	/* Checar se o classificador existe e foi instanciado */
	VAR *p=FindVAR($1);
	fprintf(output, "precisao_%s = accuracy_score(classe_teste_%s, previsoes_%s)\n", p->name, p->name, p->name);
}
| IDENTIFIER F1 {
	fprintf(output, "\n#---------- Checando a F1-Score ----------#\n");
	if(encontreImport(head, IMPORTF1) == -1){
		addImport(&head, IMPORTF1);
		fprintf(output, "from sklearn.metrics import f1_score\n");
	}
	/* Checar se o classificador existe e foi instanciado */
	VAR *p=FindVAR($1);
	fprintf(output, "precisao_f1_%s = f1_score(classe_teste_%s, previsoes_%s, average='macro')\n\n", p->name, p->name, p->name);
}
;

exp : /* ε */ { $$=UNDECL; }
| NUMINT
| NUMFLT 	  { $$= FLT; fprintf(output, "%f", $1);}
| IDENTIFIER  {// a única coisa guardada na tabela de simbolos
	AddVAR($1, STR);
 }
| '(' {fprintf(output,"(");} exp ')' {fprintf(output,")");}  { $$= $3;}
| PARAMETRO {
	AddVAR($1, INT);
	VAR *p=FindVAR($1);
	char comando[50];//usado para guardar o comando sem modificar a string original
	strcpy(comando, p->name);
	//pegarLetras(comando);
	printf("- %s -", comando);
}
;

param: NUMINT | IDENTIFIER | /* ε */ { $$=NULL; }

%%

main( int argc, char *argv[] ) {
	output = fopen("output.py","w");
	init_stringpool(10000); //memória que vai guardar as strings
	if ( yyparse () == 0) printf("\ncodigo sem erros");
}

yyerror(char *s) { /* Called by yyparse on error */
	printf ("%s  na linha %d\n", s, yylineno );
}