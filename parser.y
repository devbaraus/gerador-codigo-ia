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

%start program
%token LET IN
%token INTEGER
%token FLOAT
%token SKIP IF THEN END READ WRITE FI
%token <yint> NUMINT // antes era NUMBER agora subistitui
%token <yflt> NUMFLT
%token <ystr> IDENTIFIER
%token BOOLEAN FUNCTION
%token CARREGA TREINAMENTO PREDICAO RESULTADO ACURACIA DIVISAO ESCALONAR
%token ASSGNOP
%left '>' '<' '='
%left '-' '+'
%left '*' '/'
%left '^'
%type  <yint>  exp

%%

program : LET declarations IN { } commands { } END
;
/*Nome da função*/
declaration_function : /* empty */ 
| INTEGER IDENTIFIER { 
	VAR *p=FindVAR($2);
	ASSERT((p==NULL),"Identificador já declarado");
	AddVAR($2,INT);
	fprintf(output, "int %s", $2);
}
| FLOAT IDENTIFIER { 
	VAR *p=FindVAR($2);
	ASSERT((p==NULL),"Identificador já declarado");
	AddVAR($2,FLT);
	fprintf(output, "float %s", $2);
}
;
parametros_function: /* empty */
| INTEGER IDENTIFIER {fprintf(output,"int %s", $2); AddVAR($2,INT);} id_param_functions
| FLOAT IDENTIFIER  {fprintf(output,"float %s", $2); AddVAR($2,FLT);} id_param_functions 
| BOOLEAN IDENTIFIER {fprintf(output,"bool %s", $2); AddVAR($2,BOOL);} id_param_functions
;
id_param_functions : /* empty */
| ',' INTEGER IDENTIFIER { fprintf(output, ", int %s", $3); AddVAR($3,INT);} id_param_functions
| ',' FLOAT IDENTIFIER  { fprintf(output, ", float %s", $3); AddVAR($3,FLT);} id_param_functions
| ',' BOOLEAN IDENTIFIER  { fprintf(output, ", bool %s", $3); AddVAR($3,BOOL);} id_param_functions
;
declarations : /* empty */
| INTEGER { fprintf(output, "int "); } id_seq_int IDENTIFIER { fprintf(output, "%s", $4); } ';' { fprintf(output, "; \n"); } declarations { 
	VAR *p=ChecarEscopo1($4);
	ASSERT((p==NULL),"Identificador já declarado*");
	AddVAR($4,INT); 
}
| FLOAT { fprintf(output, "float "); } id_seq_float IDENTIFIER { fprintf(output, "%s", $4); } ';' { fprintf(output, "; \n"); } declarations { 
	VAR *p=ChecarEscopo1($4);
	ASSERT((p==NULL),"Identificador já declarado+");
	AddVAR($4,FLT);
}
| CARREGA { fprintf(output, "import pandas as pd\nbase "); } id_seq_float IDENTIFIER { fprintf(output, "= pd.read_csv('%s.csv')", $4); } ';' 
	{ 
		fprintf(output, "\n\n#Substituir a linha abaixo pela coluna de inicio dos atributos previsores\ninicio_previsores = None\n#Substituir a linha abaixo pelo numero da coluna classe\ncoluna_classe = None\n\nprevisores = base.iloc[:, inicio_previsores:coluna_classe].values\nclasse = base.iloc[:, coluna_classe].values\n\n"); 
	} declarations { 
	VAR *p=FindVAR($4);
	ASSERT((p==NULL),"base de dados ja foi carregada");
	AddVAR($4,FLT);
}
| inicio_function id_seq_function // pode declarar 1 ou mais funções
;
id_seq_int : /* empty */
| id_seq_int IDENTIFIER ','  { 
	VAR *p=ChecarEscopo1($2);
	ASSERT((p==NULL),"Identificador já declarado-");
	AddVAR($2,INT);
	fprintf(output, "%s, ", $2);
} //pode ser tipo float ou int
;
id_seq_float : /* empty */
| id_seq_float IDENTIFIER ','  { 
	VAR *p=ChecarEscopo1($2);//ChecarEscopo1
	ASSERT((p==NULL),"Identificador já declarado!");
	AddVAR($2,FLT);
	fprintf(output, "%s, ", $2);
}
;
id_seq_function: /* empty */
| inicio_function
;
//variáveis passadas como parâmetros na chamada de uma função
params: /* empty*/
| IDENTIFIER param
;
param: /* empty */
| ',' IDENTIFIER
| ',' IDENTIFIER '(' params ')' {// um parâmetro pode ser a chamada de uma função também
	VAR *p=FindVAR($2);//pegando tipo da função
	ASSERT((p!=NULL)," Função não declarada");
}
;

commands : /* empty */
| command ';' /*{ fprintf(output, ";\n"); }*/ commands
;
command : SKIP
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

inicio_function: /* empty */
| FUNCTION declaration_function { global_scope=1; fprintf(output, "(");} '(' parametros_function ')' {fprintf(output, ")");} {fprintf(output, "{\n");} exp_function ';' { fprintf(output, "}"); DestruirVAR(); global_scope=0; }
;//ao trocar global_scope para 1 a partir desse momento todas as variáveis serão add dentro do scopo 1 :)

exp_function: LET declarations IN commands END //expressores dentro do escopo da função
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
| IDENTIFIER '(' params ')' {// pode chamar função também f(paramns)
	VAR *p=FindVAR($1);//pegando tipo da função
	ASSERT((p!=NULL)," Função não declarada");
	$$ = p->type;//retorno o tipo da função
}
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

