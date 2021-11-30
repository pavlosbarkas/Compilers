%{
#include <stdio.h>
#include <string.h>

#define TK_NAME 300
#define TK_LEFTPAR 301
#define TK_RIGHTPAR 302
#define TK_INIT 303
#define TK_NOINIT 304
#define TK_SENSOR 305
#define TK_TRUE 306
#define TK_OP 307
#define TK_IMPLIES 308
#define TK_NUM 309
#define TK_VAR 310
#define TK_MOVE 311
#define TK_TURN 312
#define TK_STAY 313
#define TK_FORWARD 314
#define TK_LEFT 315
#define TK_RIGHT 316

/* Needed for syntax analyser*/
#define LEXEND 0 

int line = 1;
%}
lowercase [a-z]
name {lowercase}+
uppercase [A-Z]
var {uppercase}({uppercase}|{lowercase})*
digit [0-9]
number digit+
newline \n|\x0A|\x0D|\x0A
%%
"{" {return(TK_LEFTPAR);}
"}" {return(TK_RIGHTPAR);}
"init" {return(TK_INIT);}
"no-init" {return(TK_NOINIT);}
"left-laser"|"right-laser"|"front-sonar" {return(TK_SENSOR);}
"true" {return(TK_TRUE);}
"move" {return(TK_MOVE);}
"turn" {return(TK_TURN);}
"stay" {return(TK_STAY);}
"forward" {return(TK_FORWARD);}
"left" {return(TK_LEFT);}
"right" {return(TK_RIGHT);}
">"|"<"|"=" {return(TK_OP);}
"=>" {return(TK_IMPLIES);}
{number} {return(TK_NUM);}
{name} {return(TK_NAME);}
{var} {return(TK_VAR);}
. {/* Do Nothing */}
{newline} { line++; }
%%

int token = 0;

//Functions implementing the grammar rules
void agent(void);
void rules(void);
void rules2(void);
void rule(void);
void a(void);
void action(void);
void b(void);
void error_syntax(void);
void match(int tk);

void agent(){
	if (token == TK_NAME){
		match(TK_NAME);
		match(TK_LEFTPAR);
		rules();
		match(TK_RIGHTPAR);
	}else if (token != LEXEND) 
		error_syntax();
}

void rules(void){
	if (token == TK_INIT){
		match(TK_INIT);
		rules2();
	}else if (token == TK_NOINIT){
		match(TK_NOINIT);
		rules2();
	}else if (token != TK_RIGHTPAR)
		error_syntax();
}

void rules2(void){
	if (token == TK_SENSOR || token == TK_TRUE){
		rule();
		rules2();
	}else if (token != TK_RIGHTPAR)
		error_syntax();
}

void rule(void){
	if (token == TK_SENSOR){
		match(TK_SENSOR);
		match(TK_OP);
		a();
		match(TK_IMPLIES);
		action();
	}else if (token == TK_TRUE){
		match(TK_TRUE);
		match(TK_IMPLIES);
		action();
	}else if (token != TK_RIGHTPAR)
		error_syntax();
}

void action(void){
	if (token == TK_MOVE){
		match(TK_MOVE);
		match(TK_FORWARD);
		a();
	}else if (token == TK_TURN){
		match(TK_TURN);
		b();
	}else if (token == TK_STAY){
		match(TK_STAY);
	}else if (token != TK_SENSOR && token != TK_TRUE && token != TK_RIGHTPAR)
		error_syntax();
}

void b(void){
	if (token == TK_LEFT){
		match(TK_LEFT);
		a();
	}else if (token == TK_RIGHT){
		match(TK_RIGHT);
		a();
	}else if (token != TK_SENSOR && token != TK_TRUE && token != TK_RIGHTPAR)
		error_syntax();
}

void a(void){
	if (token == TK_NUM){
		match(TK_NUM);
	}else if (token == TK_VAR){
		match(TK_VAR);
	}else if (token != TK_IMPLIES && token != TK_SENSOR && token != TK_TRUE && token != TK_RIGHTPAR)
		error_syntax();
}

void error_syntax(void){
   printf(" Syntax Error reading %s at line %d of input. \n",yytext, line);
   exit(-1);
}

void match(int tk){

   if (token == tk) token = yylex();
   else  error_syntax();
}

int main(int argc, char **argv ){
   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 )
       yyin = fopen( argv[0], "r" );
   else
      yyin = stdin;

   token = yylex(); 
   agent();
   if (token == LEXEND) printf("\n Success! \n \n");
   else error_syntax();
   return 0;
}
