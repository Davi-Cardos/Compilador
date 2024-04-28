%{
#include <iostream>
#include <string>
#include <sstream>

#define YYSTYPE atributos
#define TRUE 1
#define FALSE 0

using namespace std;

int var_temp_qnt;

struct atributos
{
	string label;
	string traducao;
	string tipo;
};

typedef struct {
	string nome;
	string tipo;
	string label;

} VARIAVEIS;

VARIAVEIS tabela_de_simbolos[30];
int qtd_variaveis = 0;

int yylex(void);
void yyerror(string);
string gentempcode();
int busca_variavel (string name);
void adicionar_variavel(string name, string label, string tipo);
%}

%token TK_NUM
%token TK_MAIN TK_ID TK_TIPO_INT TK_TIPO_FLOAT
%token TK_FIM TK_ERROR TK_TIPO_BOOL TK_TIPO_CHAR
%token TK_CHAR TK_BOOL TK_REAL

%start S

%left '+'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				string codigo = "/*Compilador FOCA*/\n"
								"#include <iostream>\n"
								"#include<string.h>\n"
								"#include<stdio.h>\n"
								"int main(void) {\n";
								
				codigo += $5.traducao;
								
				codigo += 	"\treturn 0;"
							"\n}";

				cout << codigo << endl;
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.traducao = "";
			}
			;

COMANDO 	: E ';'
			{
				$$ = $1;
			}
			| DECLARACAO ';'
			{
				$$.traducao = $1.traducao;
			}
			;

DECLARACAO  : TK_TIPO_INT TK_ID  
            {
				$$.label = gentempcode();
				$$.traducao = "";
				if (busca_variavel ($2.label) == 1){
					yyerror ("Variavel ja declarada\n");
				}
				else{
					adicionar_variavel ($2.label, $$.label, "int");
				} 

            }
			| TK_TIPO_FLOAT TK_ID  
            {
				$$.label = gentempcode();
				$$.traducao = "";
				if (busca_variavel ($2.label) == 1){
					yyerror ("Variavel ja declarada\n");
				}
				else{
					adicionar_variavel ($2.label, $$.label, "float");
				} 

            }
			;

TIPO        : TK_TIPO_INT 
			{}
			| TK_TIPO_FLOAT
			{}
			| TK_TIPO_CHAR
			{}
			| TK_TIPO_BOOL
			;

E 			: E '+' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " + " + $3.label + ";\n";
			}
			| E '-' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + 
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			| TK_ID '=' E
			{
				$$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";

			}
			| TK_NUM
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_CHAR
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + "; \n";
			}
			| TK_BOOL
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + "; \n";
			}
			| TK_REAL
			{
				$$.label = gentempcode();
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| E '*' E 
			{
				$$.label = gentempcode();

				if ($1.tipo == $3.tipo){
					$$.traducao = $1.traducao + $3.traducao + " \t" + $$.label + "=" + $1.label + " * " + $3.label + ";\n"; 
					$$.tipo = $1.tipo;

				}
				else if ($1.tipo == "int" && $3.tipo == "float"){
					$$.traducao = $1.traducao + $3.traducao + " \t" + $$.label + "=" + "(float)" + $1.label + "+" + $3.label + ";\n";
					$$.tipo = "float";
				}
				else if ($1.tipo == "float" && $3.tipo == "int"){
					$$.traducao = $1.traducao + $3.traducao + " \t" + $$.label + "=" + "(float)" + $1.label + "+" + $3.label + "; \n";
					$$.tipo = "float";
				}
				 else if ($1.tipo == "" || $3.tipo ==""){
					yyerror("Tipo nao foi detectado \n");
					
				}
				else if ($1.tipo == "bool" || $1.tipo == "char" || $3.tipo == "bool" || $3.tipo == "char"){
					yyerror ("Operacao invalida\n");
				}
			
			}
			| E '/' E
			{
				$$.label = gentempcode();
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + "=" + $1.label + " / " + $3.label + "; \n";
			}
			| '(' E ')'
			{
				$$ = $2;
			}
			| '(' TIPO ')' '(' E ')'
			{
				$$.tipo = $2.tipo;
				$$.label = gentempcode();
				$$.traducao = $5.traducao + "\t" + $$.label + "= (" +$2.tipo + ")" + $5.label + ";\n";

			}
			
			;

%%

#include "lex.yy.c"

int yyparse();

string gentempcode()
{
	var_temp_qnt++;
	return "t" + to_string(var_temp_qnt);
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	yyparse();

	return 0;
}

void yyerror(string MSG)
{
	cout << MSG << endl;
	exit (0);
}

int busca_variavel (string name){
	for (int i = 0; i < qtd_variaveis; i++){
		if (tabela_de_simbolos[i].nome == name){
			return 1;
		}
	}
	return 0;
}

void adicionar_variavel(string name, string label, string tipo){
	VARIAVEIS variavel;
	variavel.nome = name;
	variavel.tipo = tipo;
	variavel.label = label;

			tabela_de_simbolos[qtd_variaveis] = variavel;
			qtd_variaveis++;
		
}
