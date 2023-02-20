/*
 	flex specifications for the MIPL language.
 	Written to meet requirements for CS5500, Fall 2018.
*/

/*
 *	Constant definitions are now in mipl.y
 */
%{

%}

/*
 *	Definitions of regular expressions
 */
QUOTE			'
UNDERSCORE		_
WSPACE		[ \t\r]+
NEWLINE          \n
COUNT_DIGIT	    [1-9]
DIGIT			0|{COUNT_DIGIT}
LO_ALPHA		[a-z]
HI_ALPHA		[A-Z]
ALPHA			{LO_ALPHA}|{HI_ALPHA}
ALPHANUM		{ALPHA}|{DIGIT}
PUB_VAR     pub_({ALPHANUM}|{UNDERSCORE})*
PRV_VAR     prv_({ALPHANUM}|{UNDERSCORE})*
/*
 *	Tokens
 */
%%
"("			{
                printTokenInfo("T_LPAREN", yytext);
				return T_LPAREN;
			}
")"			{
                printTokenInfo("T_RPAREN", yytext);
				return T_RPAREN;
			}
","			{
                printTokenInfo("T_COMMA", yytext);
				return T_COMMA;
			}
"<"			{
                printTokenInfo("T_LANGLE", yytext);
				return T_LANGLE;
			}
">"			{
                printTokenInfo("T_RANGLE", yytext);
				return T_RANGLE;
			}
"senc"      {
                printTokenInfo("T_SENC", yytext);
                return T_SENC;
            }
"sdec"      {
                printTokenInfo("T_SDEC", yytext);
                return T_SDEC;
            }
"pk"        {
                printTokenInfo("T_PK", yytext);
                return T_PK;
            }
"sk"        {
                printTokenInfo("T_SK", yytext);
                return T_SK;
            }
"aenc"      {
                printTokenInfo("T_AENC", yytext);
                return T_AENC;
            }
"adec"      {
                printTokenInfo("T_ADEC", yytext);
                return T_ADEC;
            }
"vk"        {
                printTokenInfo("T_VK", yytext);
                return T_VK;
            }
"ssk"       {
                printTokenInfo("T_SSK", yytext);
                return T_SSK;
            }
"sign"      {
                printTokenInfo("T_SIGN", yytext);
                return T_SIGN;
            }
"verify"    {
                printTokenInfo("T_VERIFY", yytext);
                return T_VERIFY;
            }
"pi_1"      {
                printTokenInfo("T_PROJ_1", yytext);
                return T_PROJ_1;
            }
"pi_2"      {
                printTokenInfo("T_PROJ_2", yytext);
                return T_PROJ_2;
            }
{PUB_VAR}   {
                printTokenInfo("T_PUB", yytext);
                yylval.text = strdup(yytext);
                return T_PUB;
            }
{PRV_VAR}   {
                printTokenInfo("T_PRV", yytext);
                yylval.text = strdup(yytext);
                return T_PRV;
            }
{NEWLINE}   { }
{WSPACE}	{ }

%%