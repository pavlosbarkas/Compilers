/*
A simple syntax analyser for a mini language:

Syntax Analysis File
I. Sakellariou 2013 (based on simple examples from other authors)
*/

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "jsonValidator.h"

int yylex();
int yyerror (const char * msg);
/* This var holds the line number */ 
int yylineno;

%}

%union{
	char str[250];
	int num;
	float numf;
	struct {
    	jsonType type;
    	char name[250];
		int len;
	} entity;
}

/* Output informative error messages (bison Option) */
%define parse.error verbose

/* Token declarations */
%token <num>  T_number_int
%token <numf> T_number_float
%token <str> T_string

%token <entity> T_array "array"
%token <entity> T_object "object"
%token <entity> T_constant "constant"

%token <entity> T_true
%token <entity> T_false
%token <entity> T_null

%token '('
%token ')'
%token '{'
%token '}'
%token '['
%token ']'
%token ':'
%token ','

%type<entity> value
%type<entity> elements
%type<entity> array
%type<entity> object
%type<entity> pair
%type<entity> members

%%

json: {initSymbolTable();} pair_declarations object
	;

pair_declarations:  {/*empty*/}
	| pair_declarations '(' T_string value ')'
	{
		/*Eisagwgh kathe kainourias metavlitis ston pinaka sumvolwn
		kai emfanish munhmatos lathous an exei hdh eisaxthei*/
	 	if (!addvar($3, $4.type, $4.len)){
			fprintf(stderr, "Entity: %s on line %d. ", $3, yylineno);
	 		yyerror("Entity already defined. Discarding..");
	 	}
	}
	;

object: '{' members '}' {$$.type = type_object; $$.len = 1;}  
	;

members: pair
	| pair ',' members 
	| error ',' members {}
	;

pair:  T_string ':' value
	{
		//Elegxos an exei dhlwthei h metavlhth
		if (lookup($1) == 0){
			fprintf(stderr, "Entity %s has not been declared. ", $1);
			yyerror("Missing Declaration!");
		//Elegxos an dinetai lathos tupou orisma sthn metavlhth
		}else if (lookup_type($1) != $3.type) {
			fprintf(stderr, "Entity (%s : %s) Expected Type %s. ", $1, nameOfType($3.type), nameOfType(lookup_type($1)));
			yyerror("Type Mismatch!");
			YYERROR;
		}
	
		if(lookup_type($1)== 5)
			//Elegxos an to megethos tou pinaka einai iso me to megethos pou dilwthike sta pairs
			if (lookup_length($1) != $3.len){
				fprintf(stderr, "Entity (%s : array) Expected Length %d, not %d. ", $1, lookup_length($1), $3.len);
				yyerror("Length Mismatch!");
			}
	}
	;

array: '[' ']' {$$.type = type_array; $$.len = 0;}
	| '[' elements ']' {$$.type = type_array; $$.len = $2.len;} 
	;

elements : value {$$.len = $1.len;}
	| value ',' elements {$$.len = $1.len + $3.len;}
	;

value: T_number_int {$$.type = type_integer; $$.len = 1;}
	| T_number_float {$$.type = type_real; $$.len = 1;}
	| T_string {$$.type = type_string; $$.len=1; strcpy($$.name, $1);} 
	| T_array T_number_int {$$.type = $1.type; $$.len = $2;}
	| T_object {$$.type = $1.type;$$.len = 1; }
	| T_constant {$$.type = $1.type;$$.len = 1; }
	| T_true {$$.type = $1.type;}
	| T_false {$$.type = $1.type;}
	| T_null{$$.type = $1.type;}
	| object {$$.type = $1.type;}
	| array {$$.type = $1.type;}
	;

%%
/* Line that includes the lexical analyser */
#include "jsonValidator.lex.c"

/* The usual yyerror, + line number indication. The variable line is defined in the lexical analyser.*/
int yyerror (const char * msg)
{
   fprintf(stderr, "ERROR in line %d: %s.\n", yylineno,msg);
}

/*
NOT NEEDED ANY MORE extern FILE *yyin, *yyout;

*/

/* Main */
int main (int argc, char ** argv)
{ ++argv, --argc; /* skip over program name */
	if ( argc > 0 )
		yyin = fopen( argv[0], "r" );
	else
		yyin = stdin;

  int res = yyparse();
  printf("Total Syntax Errors found %d \n",yynerrs);

}
