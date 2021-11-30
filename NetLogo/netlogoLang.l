/* This is an example of a simple lexer */
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
%}
ws [ \t]+
newline \n|\x0A|\x0D|\x0A
nzdigit [1-9]
lowercase [a-z]
uppercase [A-Z]
name {lowercase}+
var \?({lowercase}|{uppercase})+
num {nzdigit}(0|{nzdigit})*
%%

"to" {return T_TO;}
"end" {return T_END;}
"to-report" {return T_TOREPORT;}
"[" {return '[';}
"]" {return ']';}
"if" {return T_IF;}
"report" {return T_REPORT;}
"=" {return '=';}
"(" {return '(';}
")" {return ')';}
{name} {return T_NAME;}
{var} {return T_VAR;}
{num} {return T_NUM;}
. {/* Do Nothing */}
{newline} {/* Do Nothing */}
{ws} {/* Do Nothing */}
%%
