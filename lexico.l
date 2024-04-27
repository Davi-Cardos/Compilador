%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{yylval.tipo = "int"; return TK_TIPO_INT;}

"float"     {yylval.tipo = "float"; return TK_TIPO_FLOAT;}

"char"      {yylval.tipo = "char";  return TK_TIPO_CHAR;}    

"boolean"   {yylval.tipo = "boolean"; return TK_TIPO_CHAR;}

[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }

{NUM}		{ yylval.label = yytext; return TK_NUM; }
{ID}		{ yylval.label = yytext; return TK_ID; }

.			{ *yytext; }

%%
