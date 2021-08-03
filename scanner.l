%{
#include "parser.tab.h"
char *stringpool(char *);
%}
%option yylineno

DIGIT    [0-9]
ID       [_a-zA-Z][_A-Za-z0-9]*

%%

{DIGIT}+ { printf("Inteiro "); yylval.yint = atoi(yytext);  return(NUMINT);   }
[-+]?{DIGIT}*"."{DIGIT}+ { printf("Real "); yylval.yflt = atof(yytext); return(NUMFLT);   }


carrega  { printf("carrega "); return(CARREGA); }
divisao { printf("divisão "); return(DIVISAO); }
escalonar { printf("escalonar "); return(ESCALONAR); }
transformar { printf("transformar "); return(TRANSFORMAR); }
treinamento { printf("treinamento "); return(TREINAMENTO); }
predicao { printf("predição "); return(PREDICAO); }
faltantes { printf("faltantes "); return(FALTANTES); }
resultado { printf("resultado "); return(RESULTADO); }
classificador { printf("classificador "); return(CLASSIFICADOR); }
regressor     { printf("regressor ");     return(REGRESSOR); }
acuracia { printf("acurácia "); return(ACURACIA); }
mse { printf("mse "); return(MSE); }
f1       { printf("f1-score "); return(F1); }
r2       { printf("R2 "); return(R2); }
{ID}     { printf("Identificador "); yylval.ystr = stringpool(yytext);  return(IDENTIFIER); }
-{ID}={DIGIT}*?{ID}? { printf("parâmetro "); yylval.ystr = stringpool(yytext); return(PARAMETRO); }
"\n"     { printf("\n");}
"//"[A-Za-z0-9_ ]* {printf("Comentário"); }
[ \t]+ /* blank, tab, new line: eat up whitespace */
.        { printf("%c",yytext[0]); return(yytext[0]); }

%%
