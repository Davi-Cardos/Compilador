%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]
FIM_LINHA [\n]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*

%%

"\n"		{}

{DELIM} 	{}

"main"		  { return TK_MAIN;}

"int"		    { yylval.tipo = "int"; return TK_TIPO_INT;}

"float"     { yylval.tipo = "float"; return TK_TIPO_FLOAT;}

"char"      { yylval.tipo = "char";  return TK_TIPO_CHAR;}    

"bool"      { yylval.tipo = "bool"; return TK_TIPO_BOOL;}



[(){}[\];,]	{ return *yytext; }

[+\-*/]		{ return *yytext; }

"="		    { return '='; }

{NUM}		       { yylval.label = yytext; yylval.tipo = "int"; return TK_NUM; }
{ID}		       { yylval.label = yytext; return TK_ID; }
{CHAR}         { yylval.label = yytext; yylval.tipo = "char"; return TK_CHAR;}
"TRUE"|"FALSE" { yylval.label = yytext; yylval.tipo = "bool"; return TK_BOOL;}
{REAL}         { yylval.label = yytext; yylval.tipo = "float"; return TK_REAL;}
{FIM_LINHA}    { num_linha = yylineno;}


.			{ *yytext; }

%%
