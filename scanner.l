%{
#include "parser.tab.h"
char *stringpool(char *);
%}
%option yylineno

DIGIT    [0-9]
ID       [_a-zA-Z][_A-Za-z0-9]*

%%

":="     { printf("Atribuição "); return(ASSGNOP);  }
{DIGIT}+ { printf("Inteiro "); yylval.yint = atoi(yytext);  return(NUMINT);   }
[-+]?{DIGIT}*"."{DIGIT}+ { printf("Real "); yylval.yflt = atof(yytext); return(NUMFLT);   }



fi       { printf("fi "); return(FI);       }
if       { printf("if "); return(IF);       }
carrega  { printf("carrega "); return(CARREGA); }
divisao { printf("divisão "); return(DIVISAO); }
escalonar { printf("escalonar "); return(ESCALONAR); }
transformar { printf("transformar "); return(TRANSFORMAR); }
treinamento { printf("treinamento "); return(TREINAMENTO); }
predicao { printf("predição "); return(PREDICAO); }
resultado { printf("resultado "); return(RESULTADO); }
acuracia { printf("acurácia "); return(ACURACIA); }
read     { printf("read "); return(READ);     }
skip     { printf("skip "); return(SKIP);     }
then     { printf("then ");return(THEN);     }
write    { printf("write "); return(WRITE);    }
{ID}     { printf("Identificador "); yylval.ystr = stringpool(yytext);  return(IDENTIFIER); }
"\n"     { printf("\n");}
"//"[A-Za-z0-9_ ]* {printf("Comentário"); }
[ \t]+ /* blank, tab, new line: eat up whitespace */
.        { printf("%c",yytext[0]); return(yytext[0]); }

%%


