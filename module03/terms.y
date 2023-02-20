/*
 *  bison specifications for the MIPL language.
 *  Written to meet requirements for CS 5500, Fall 2018.
 */

/*
 *  Declaration section.
 */
%{

#include <stdio.h>
#include <ctype.h>
#include <cstring>
#include <list>
#include <iostream>
#include <sstream>
#include <stack>

#include "Term.h"

using namespace std;

#define OUTPUT_TOKENS       0
#define OUTPUT_PRODUCTIONS  1


int yyerror(Node** node, const char *s);
void ignoreComment();
void prRule(const char*, const char*);
void printTokenInfo(const char* tokenType, const char* lexeme);

extern "C" {
    int yyparse(Node** node);
    int yylex(void);
    int yywrap() {return 1;}
}

%}

%parse-param { Node** root }

%union {
    char* text;
    Node* node;
};

/*
 *  Token declaration. 'N_...' for rules, 'T_...' for tokens.
 *  Note: tokens are also used in the flex specification file.
 */
%token      T_SENC    T_SDEC    T_LANGLE    T_RANGLE
%token      T_PROJ_1  T_PROJ_2  T_PK        T_SK
%token      T_AENC    T_ADEC    T_VK        T_SSK
%token      T_SIGN    T_VERIFY  T_LPAREN    T_RPAREN
%token      T_COMMA   T_PRV     T_PUB

%token      ST_EOF

%type <node> N_START N_TERMS
%type <text> T_PUB T_PRV

/*
 *  Starting point.
 */
%start      N_START

/*
 *  Translation rules.
 */
%%
N_START         : N_TERMS
                {
                    prRule("N_START", "N_TERMS");
                    printf("\n---- Completed parsing ----\n\n");
                    Node* node = $1;
                    
                    printf("ID: %d\n", node->getID());
                    *root = $1;
                    return 0;
                }
                ;
N_TERMS         : T_PRV
                {
                    $$ = new Node($1);
                    prRule("N_TERMS", "T_PRV");
                }
                | T_PUB
                {
                    $$ = new Node($1);
                    prRule("N_TERMS", "T_PUB");
                }
                | T_SENC T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    $$ = new BinaryTerm("senc", $3, $5);
                    prRule("N_TERMS", "senc(Terms, Terms)");
                }
                | T_SDEC T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    $$ = new BinaryTerm("sdec", $3, $5);
                    prRule("N_TERMS", "sdec(Terms, Terms)");
                }
                | T_LANGLE N_TERMS T_COMMA N_TERMS T_RANGLE
                {
                    $$ = new BinaryTerm("pair", $2, $4);
                    prRule("N_TERMS", "<Terms, Terms>");
                }
                | T_PROJ_1 T_LPAREN N_TERMS T_RPAREN
                {
                    $$ = new UnaryTerm("proj_1", $3);
                    prRule("N_TERMS", "pi_1(Terms)");
                }
                | T_PROJ_2 T_LPAREN N_TERMS T_RPAREN
                {
                    $$ = new UnaryTerm("proj_2", $3);
                    prRule("N_TERMS", "pi_2(Terms)");
                }
                | T_PK T_LPAREN N_TERMS T_RPAREN
                {
                    $$ = new UnaryTerm("pk", $3);
                    prRule("N_TERMS", "pk(Terms)");
                }
                | T_SK T_LPAREN N_TERMS T_RPAREN
                {
                    $$ = new UnaryTerm("sk", $3);
                    prRule("N_TERMS", "sk(Terms)");
                }
                | T_AENC T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    $$ = new BinaryTerm("aenc", $3, $5);
                    prRule("N_TERMS", "aenc(Terms, Terms)");
                }
                | T_ADEC T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    $$ = new BinaryTerm("adec", $3, $5);
                    prRule("N_TERMS", "adec(Terms, Terms)");
                }
                | T_VK T_LPAREN N_TERMS T_RPAREN
                {
                    $$ = new UnaryTerm("vk", $3);
                    prRule("N_TERMS", "vk(Terms)");
                }
                | T_SSK T_LPAREN N_TERMS T_RPAREN
                {
                    $$ = new UnaryTerm("ssk", $3);
                    prRule("N_TERMS", "ssk(Terms)");
                }
                | T_SIGN T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    $$ = new BinaryTerm("sign", $3, $5);
                    prRule("N_TERMS", "sign(Terms, Terms)");
                }
                | T_VERIFY T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    $$ = new BinaryTerm("verify", $3, $5);
                    prRule("N_TERMS", "verify(Terms, Terms)");
                }
                ;
%%
#include "lex.yy.c"
extern FILE *yyin;

int yyerror(Node** node, const char *s) {
  printf("Error");
  exit(1);
}

void prRule(const char *lhs, const char *rhs) {
  if (OUTPUT_PRODUCTIONS)
    printf("%s -> %s\n", lhs, rhs);
  return;
}

void printTokenInfo(const char* tokenType, const char* lexeme) {
  if (OUTPUT_TOKENS)
    printf("TOKEN: %-15s  LEXEME: %s\n", tokenType, lexeme);
}

void walkTree(Node* node) {
    auto* unary_derived = dynamic_cast<UnaryTerm*>(node);
    if (unary_derived) {
        cout << "(" << node->getID() << ", " << node->getName() << ")" << endl;
        walkTree(unary_derived->childTerm);
        return;
    }
    auto* binary_derived = dynamic_cast<BinaryTerm*>(node);
    if (binary_derived) {
        cout << "(" << node->getID() << ", " << node->getName() << ")" << endl;
        walkTree(binary_derived->leftTerm);
        walkTree(binary_derived->rightTerm);
        return;
    }
    
    // Else we are just a Node
    cout << "(" << node->getID() << ", " << node->getName() << ")" << endl;
}

int main(int argc, char** argv) {
    Node** root = new Node*;
    if (argc < 2) {
        printf("You must specify a file in the command line!\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");
    do {
        yyparse(root);
    } while (!feof(yyin));
    
    printf("Root ID: %d\n", (*root)->getID());
    
    walkTree(*root);
    return 0;
}
