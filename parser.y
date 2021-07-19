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
%token SKIP IF THEN END WHILE DO READ WRITE FI RETURN
%token <yint> NUMINT // antes era NUMBER agora subistitui
%token <yflt> NUMFLT
%token <ystr> IDENTIFIER
%token NUMBL
%token BOOLEAN FUNCTION CARREGA
%token ASSGNOP MAIORIGUAL
%left '>' '<' '=' MAIORIGUAL
%left '-' '+'
%left '*' '/'
%left '^'
%type  <yint>  exp

%%

program : LET declarations IN { fprintf(output, "\nint main(){\n"); } commands { fprintf(output, "\n}"); } END
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
| CARREGA { fprintf(output, "base "); } id_seq_float IDENTIFIER { fprintf(output, "= pd.read_csv('%s.csv')", $4); } ';' { fprintf(output, "; \n"); } declarations { 
	//fprintf(output, "base = pd.read_csv('%s')", $2);
	VAR *p=ChecarEscopo1($4);
	ASSERT((p==NULL),"Identificador já declarado+");
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
| WHILE exp DO commands END { ASSERT( $2 == BOOL, "Valor boleano esperado"); }
;

function_return: /* empty */
| RETURN {fprintf(output, "return ");} exp {fprintf(output, ";\n");} ';' { /* printf(" Retornando variável: %d", $2); */ }
;

inicio_function: /* empty */
| FUNCTION declaration_function { global_scope=1; fprintf(output, "(");} '(' parametros_function ')' {fprintf(output, ")");} {fprintf(output, "{\n");} exp_function ';' { fprintf(output, "}"); DestruirVAR(); global_scope=0; }
;//ao trocar global_scope para 1 a partir desse momento todas as variáveis serão add dentro do scopo 1 :)

exp_function: LET declarations IN commands function_return END //expressores dentro do escopo da função
;

exp : NUMBL   /*{ $$= BOOL;fprintf(output, "%d", $1);}*/
| NUMINT      { $$= INT; fprintf(output, "%d", $1);}
| NUMFLT 	  { $$= FLT; fprintf(output, "%f", $1);}
| IDENTIFIER  {// a única coisa guardada na tabela de simbolos
	VAR *p=FindVAR($1);
	//printf(" Salvando variável no scopo: -> %d <- ", global_scope);
	ASSERT((p!=NULL),"Identificador Não declarado");
	$$= (p!=NULL)? p->type:UNDECL;
	fprintf(output, "%s", $1);
}
| exp MAIORIGUAL {fprintf(output," >= ");}  exp {
	ASSERT( (($1 == INT || $1 == FLT) && ($4 == INT || $4 == FLT)) , "Operadores imcompatível");
	$$= BOOL; 
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

