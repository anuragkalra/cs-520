%{
#include "parser.tab.h" // Token definitions from the parser
#include <stdio.h>
#include <string.h>
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
int g_tokens;
// must escape in character classes, \[, \], \(, \), 
%}

SPACE [ ]
ALPHANUMS [a-zA-Z0-9]
SYMBOLS [~@#$%&*+\/`<>=_|'.,;:!?{}\[\]\(\)^-]
ESCAPE [abfnrtv"\\]

%option yylineno
%option noinput
%option nounput

%%

[ \t\n\r]+

["]({SPACE}|{ALPHANUMS}|{SYMBOLS}|\\{ESCAPE}{SPACE})*(\\{ESCAPE})*["]  {
	yylval.stringval = strdup(yytext);
	if(g_tokens) printf("tSTRINGVAL(%s)\n", yylval.stringval); return tSTRINGVAL;
}

[/]{2}.* {
	yylval.stringval = strdup(yytext);
	if(g_tokens) printf("tCOMMENT(%s)\n", yylval.stringval); return tCOMMENT;
} 

"==" 	{if(g_tokens) printf("==\n"); return tBINEQ;}
"!=" 	{if(g_tokens) printf("!=\n"); return tBINNEQ;}
"&&"	{if(g_tokens) printf("&&\n"); return tBINAND;}
"||"	{if(g_tokens) printf("||\n"); return tBINOR;}

"!"		{if(g_tokens) printf("!\n"); return '!';}
"*"     {if(g_tokens) printf("*\n"); return '*';}
"/"     {if(g_tokens) printf("/\n"); return '/';}
"+"     {if(g_tokens) printf("+\n"); return '+';}
"-"     {if(g_tokens) printf("-\n"); return '-';}
"("     {if(g_tokens) printf("(\n"); return '(';}
")"     {if(g_tokens) printf(")\n"); return ')';}

"{"		{if(g_tokens) printf("{\n"); return '{';}
"}"		{if(g_tokens) printf("}\n"); return '}';}
":"		{if(g_tokens) printf(":\n"); return ':';}
"="		{if(g_tokens) printf("=\n"); return '=';}
";"		{if(g_tokens) printf(";\n"); return ';';}

var		  {if(g_tokens) printf("tVAR\n"); return tVAR;}
int		  {if(g_tokens) printf("tINT\n"); return tINT;}
float	  {if(g_tokens) printf("tFLOAT\n"); return tFLOAT;}
string 	  {if(g_tokens) printf("tSTRING\n"); return tSTRING;}
boolean	  {if(g_tokens) printf("tBOOL\n"); return tBOOL;}
while     {if(g_tokens) printf("tWHILE\n"); return tWHILE;}
if        {if(g_tokens) printf("tIF\n"); return tIF;}
else      {if(g_tokens) printf("tELSE\n"); return tELSE;}
print     {if(g_tokens) printf("tPRINT\n"); return tPRINT;}
read      {if(g_tokens) printf("tREAD\n"); return tREAD;}

TRUE {
  yylval.intval = 1;
  if(g_tokens) printf("tBOOLVAL(%d)\n", 1); return tBOOLVAL;
}

FALSE {
  yylval.intval = 0;
  if(g_tokens) printf("tBOOLVAL(%d)\n", 0); return tBOOLVAL;
}

(0|([1-9][0-9]*))"."[0-9]* 		{
	yylval.floatval = atof(yytext);
	if(g_tokens) printf("tFLOATVAL(%f)\n", yylval.floatval); return tFLOATVAL;
}

0|([1-9][0-9]*) 				{
	yylval.intval = atoi(yytext);
	if(g_tokens) printf("tINTVAL(%d)\n", yylval.intval); return tINTVAL;
}

[a-zA-Z_][a-zA-Z0-9_]* 			{ 
	yylval.stringval = strdup(yytext);
	if(g_tokens) printf("tIDENTIFIER(%s)\n", yylval.stringval); return tIDENTIFIER;
}

.       						{ fprintf(stderr, "Error: (line %d) unexpected character '%s'\n", yylineno, yytext); exit(1); }

%%

int main(int argc, char *argv[])
{	
	g_tokens = 0;

	// Here I don't check argument since script ./run.sh does it automatically
	if (strcmp(argv[1], "scan") == 0) {
		while (yylex()){}
		printf("OK\n");
	}
	if (strcmp(argv[1], "tokens") == 0) {
		g_tokens = 1;
		while (yylex()){}
	}
	if (strcmp(argv[1], "parse") == 0){
		yyparse();
		printf("OK\n");
	}

	return 0;
}


