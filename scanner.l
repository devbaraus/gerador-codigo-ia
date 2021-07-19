%{
#include "parser.tab.h"
char *stringpool(char *);
%}
%option yylineno

DIGIT    [0-9]
ID       [_a-zA-Z][_A-Za-z0-9]*

%%

":="     { printf("Atribuição "); return(ASSGNOP);  }
">="     { printf(">= "); return(MAIORIGUAL);  }
{DIGIT}+ { printf("Inteiro "); yylval.yint = atoi(yytext);  return(NUMINT);   }
[-+]?{DIGIT}*"."{DIGIT}+ { printf("Real "); yylval.yflt = atof(yytext); return(NUMFLT);   }
true|false { printf("Booleano "); return(NUMBL); }
do       { printf("do "); return(DO);       }
else     { printf("else "); return(ELSE);     }
end      { printf("end "); return(END);      }
fi       { printf("fi "); return(FI);       }
if       { printf("if "); return(IF);       }
in       { printf("in ");  return(IN);       }
integer  { printf("tipo "); return(INTEGER);  }
float    { printf("tipo "); return(FLOAT);  }
bool     { printf("tipo "); return BOOLEAN;  }
function { printf("function "); return(FUNCTION); }
let      { printf("let "); return(LET);      }
read     { printf("read "); return(READ);     }
skip     { printf("skip "); return(SKIP);     }
return   { printf("retorno "); return(RETURN);     }
then     { printf("then ");return(THEN);     }
while    { printf("while ");return(WHILE);    }
write    { printf("write "); return(WRITE);    }
{ID}     { printf("Identificador "); yylval.ystr = stringpool(yytext);  return(IDENTIFIER); }
"\n"     { printf("\n");}
"//"[A-Za-z0-9_ ]* {printf("Comentário"); }
[ \t]+ /* blank, tab, new line: eat up whitespace */
.        { printf("%c",yytext[0]); return(yytext[0]); }

%%


