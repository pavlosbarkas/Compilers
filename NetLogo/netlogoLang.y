// Simple NetLogo parser
%{
#include <stdio.h>

int yylex();
extern int yylineno; 
extern char* yytext; 

void yyerror (const char * msg)
  {
   printf(" Line %d in (%s) -- Error: %s \n",yylineno, yytext,  msg);
  }
  
%}
%define parse.error verbose

%token T_NAME
%token T_VAR
%token T_NUM

%token T_TO "to"
%token T_END "end"
%token T_TOREPORT "to-report"
%token T_IF "if"
%token T_REPORT "report"

%%
PDefinitions : PDef PDefinitions 
				| //empty
				;
				 
PDef : T_TO ProcFunN Body T_END
		| T_TOREPORT ProcFunN Body T_END
		;
		
ProcFunN : T_NAME 
		| T_NAME '[' Vars ']'
		;
		
Vars : T_VAR 
	| Vars T_VAR
	;
	
Body : Command 
	| Command Body
	;
	
Command : T_IF Call '[' Body ']' 
		| T_REPORT T_VAR 
		| T_REPORT T_NUM
		| Call | T_VAR '=' T_NUM
		;
		
Call : '(' T_NAME Args ')'
		;
		
Args : T_VAR Args 
	| T_NUM Args 
	| Call Args 
	| //empty
	;

%%
#include "netlogo.lex.c"

int main(int argc, char **argv ){
   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 )
       yyin = fopen( argv[0], "r" );
   else
      yyin = stdin;

   if (yyparse() == 0) printf("\n Success! \n");
   else printf("Parse not Complete.\n");
   return 0;
}
