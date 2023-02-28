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
#include <unordered_map>
#include <vector>
#include <map>

#include "Term.h"

using namespace std;

#define OUTPUT_TOKENS       0
#define OUTPUT_PRODUCTIONS  0

int yyerror(const char *s);
void ignoreComment();
void prRule(const char*, const char*);
void printTokenInfo(const char* tokenType, const char* lexeme);
void printTree(Node* node, int depth);
void walkTree(Node* node);

map<int, Node*> idToNodeMap;
unordered_map<string, Node*> subterm_map;
vector<Node*> terms_list;
Node* target_term;

extern "C" {
    int yyparse(vector<Node*> terms_list);
    int yylex(void);
    int yywrap() {return 1;}
}

%}

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
%token      T_COMMA   T_PRV     T_PUB       T_SEMI

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
N_START         : N_TERMS_LIST
                {
                    prRule("N_START", "N_TERMS_LIST");
                    printf("\n---- Completed parsing ----\n\n");
                    return 0;
                }
                ;
N_TERMS_LIST    : N_TERMS T_SEMI N_TERMS
                {
                    prRule("N_TERMS_LIST", "N_TERMS T_SEMI");
                    Node* node = $1;
                    node->mark();
                    terms_list.push_back($1);
                    target_term = $3;
                }
                | N_TERMS T_COMMA N_TERMS_LIST 
                {
                    prRule("N_TERMS_LIST", "N_TERMS T_COMMA N_TERMS_LIST");
                    Node* node = $1;
                    node->mark();
                    terms_list.push_back($1);
                }
                ;
N_TERMS         : T_PRV
                {
                    auto iter = subterm_map.find($1);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new Node($1, NodeType::PRV);
                        subterm_map[$1] = $$;
                    }
                    prRule("N_TERMS", "T_PRV");
                }
                | T_PUB
                {
                    auto iter = subterm_map.find($1);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new Node($1, NodeType::PUB);
                        subterm_map[$1] = $$;
                    }
                    $$->mark();
                    prRule("N_TERMS", "T_PUB");
                }
                | T_SENC T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "senc(" << $3->getName() << ", " << $5->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new BinaryTerm(subterm, NodeType::SENC, $3, $5);
                        subterm_map[subterm] = $$;
                    }
                    
                    prRule("N_TERMS", "senc(Terms, Terms)");
                }
                | T_SDEC T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "sdec(" << $3->getName() << ", " << $5->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new BinaryTerm(subterm, NodeType::SDEC, $3, $5);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "sdec(Terms, Terms)");
                }
                | T_LANGLE N_TERMS T_COMMA N_TERMS T_RANGLE
                {
                    stringstream ss;
                    ss << "<" << $2->getName() << ", " << $4->getName() << ">";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new BinaryTerm(subterm, NodeType::PAIR, $2, $4);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "<Terms, Terms>");
                }
                | T_PROJ_1 T_LPAREN N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "pi_1(" << $3->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new UnaryTerm(subterm, NodeType::PI_1, $3);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "pi_1(Terms)");
                }
                | T_PROJ_2 T_LPAREN N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "pi_2(" << $3->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new UnaryTerm(subterm, NodeType::PI_2, $3);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "pi_2(Terms)");
                }
                | T_PK T_LPAREN N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "pk(" << $3->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new UnaryTerm(subterm, NodeType::PK, $3);
                        subterm_map[subterm] = $$;
                    }
                    $$->mark();
                    prRule("N_TERMS", "pk(Terms)");
                }
                | T_SK T_LPAREN N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "sk(" << $3->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new UnaryTerm(subterm, NodeType::SK, $3);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "sk(Terms)");
                }
                | T_AENC T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "aenc(" << $3->getName() << ", " << $5->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new BinaryTerm(subterm, NodeType::AENC, $3, $5);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "aenc(Terms, Terms)");
                }
                | T_ADEC T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "adec(" << $3->getName() << ", " << $5->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new BinaryTerm(subterm, NodeType::ADEC, $3, $5);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "adec(Terms, Terms)");
                }
                | T_VK T_LPAREN N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "vk(" << $3->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new UnaryTerm(subterm, NodeType::VK, $3);
                        subterm_map[subterm] = $$;
                    }
                    $$->mark();
                    prRule("N_TERMS", "vk(Terms)");
                }
                | T_SSK T_LPAREN N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "k(" << $3->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new UnaryTerm(subterm, NodeType::SSK, $3);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "ssk(Terms)");
                }
                | T_SIGN T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "sign(" << $3->getName() << ", " << $5->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new BinaryTerm(subterm, NodeType::SIGN, $3, $5);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "sign(Terms, Terms)");
                }
                | T_VERIFY T_LPAREN N_TERMS T_COMMA N_TERMS T_RPAREN
                {
                    stringstream ss;
                    ss << "verify(" << $3->getName() << ", " << $5->getName() << ")";
                    string subterm = ss.str();
                    auto iter = subterm_map.find(subterm);
                    if (iter != subterm_map.end()) {
                        $$ = iter->second;
                    } else {
                        $$ = new BinaryTerm(subterm, NodeType::VERIFY, $3, $5);
                        subterm_map[subterm] = $$;
                    }
                    prRule("N_TERMS", "verify(Terms, Terms)");
                }
                ;
%%
#include "lex.yy.c"
extern FILE *yyin;

int yyerror(const char *s) {
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

void printTree(Node* node, int depth) {
    for (int i = 0; i < depth; ++i) {
        std::cout << "--";
    }
    if (depth) {
        std::cout << "> ";
    }
    
    depth = depth + 1;
    
    auto* unary_derived = dynamic_cast<UnaryTerm*>(node);
    if (unary_derived) {
        cout << "(" << node->getID() << ", " << node->getName() << ", " << boolalpha << node->marked() << ")" << endl;
        printTree(unary_derived->childTerm, depth);
        return;
    }
    auto* binary_derived = dynamic_cast<BinaryTerm*>(node);
    if (binary_derived) {
        cout << "(" << node->getID() << ", " << node->getName() << ", " << boolalpha << node->marked() << ")" << endl;
        printTree(binary_derived->leftTerm, depth);
        printTree(binary_derived->rightTerm, depth);
        return;
    }
    
    // Else we are just a Node
    cout << "(" << node->getID() << ", " << node->getName() << ", " << boolalpha << node->marked() << ")" << endl;
}

void walkTree(Node* node) {
    auto iter = idToNodeMap.find(node->getID());
    if (iter == idToNodeMap.end()) {
        idToNodeMap[node->getID()] = node;
    }
    
    auto* unary_derived = dynamic_cast<UnaryTerm*>(node);
    if (unary_derived) {
        walkTree(unary_derived->childTerm);
        return;
    }
    auto* binary_derived = dynamic_cast<BinaryTerm*>(node);
    if (binary_derived) {
        walkTree(binary_derived->leftTerm);
        walkTree(binary_derived->rightTerm);
        return;
    }
}

void deduction() {
    bool newMark;
    do {
        newMark = false;
        for (auto it = idToNodeMap.begin(); it != idToNodeMap.end(); it++) {
            switch (it->second->getType()) {
                case NodeType::PRV: break;
                case NodeType::PUB: break;
                case NodeType::SENC:
                {
                    BinaryTerm* senc = dynamic_cast<BinaryTerm*>(it->second);
                    if (senc->leftTerm->marked() && senc->rightTerm->marked() && !senc->marked()) {
                        senc->mark();
                        newMark = true;
                    }
                    if (senc->marked() && senc->leftTerm->marked() && !senc->rightTerm->marked()) {
                        senc->rightTerm->mark();
                        newMark = true;
                    }
                    break;
                }
                case NodeType::SDEC: break;
                case NodeType::PAIR:
                {
                    BinaryTerm* pair = dynamic_cast<BinaryTerm*>(it->second);
                    if (pair->leftTerm->marked() && pair->rightTerm->marked() && !pair->marked()) {
                        pair->mark();
                        newMark = true;
                    }
                    
                    if (pair->marked() && !pair->leftTerm->marked() && !pair->rightTerm->marked()) {
                        pair->leftTerm->mark();
                        pair->rightTerm->mark();
                        newMark = true;
                    }
                    break;
                }
                case NodeType::PI_1: break;
                case NodeType::PI_2: break;
                case NodeType::PK: break;
                case NodeType::SK:
                {
                    UnaryTerm* sk = dynamic_cast<UnaryTerm*>(it->second);
                    if (!sk->marked() && sk->childTerm->marked()) {
                        sk->mark();
                        newMark = true;
                    }
                    if (sk->marked() && !sk->childTerm->marked()) {
                        sk->childTerm->mark();
                        newMark = true;
                    }
                    break;
                }
                case NodeType::AENC:
                {
                    BinaryTerm* aenc = dynamic_cast<BinaryTerm*>(it->second);
                    if (aenc->leftTerm->getType() == NodeType::PK) {
                        UnaryTerm* pk = dynamic_cast<UnaryTerm*>(aenc->leftTerm);
                        if (pk->childTerm->marked()) {
                            aenc->rightTerm->mark();
                            newMark = true;
                        }
                    }
                    
                    if (aenc->leftTerm->marked() && aenc->rightTerm->marked()) {
                        aenc->mark();
                        newMark = true;
                    }
                    
                    break;
                }
                case NodeType::ADEC: break;
                case NodeType::VK: break;
                case NodeType::SSK: 
                {
                    UnaryTerm* ssk = dynamic_cast<UnaryTerm*>(it->second);
                    if (!ssk->marked() && ssk->childTerm->marked()) {
                        ssk->mark();
                        newMark = true;                        
                    }
                    break;
                }
                case NodeType::SIGN:
                {
                    BinaryTerm* sign = dynamic_cast<BinaryTerm*>(it->second);
                    if (sign->leftTerm->getType() == NodeType::VK) {
                        UnaryTerm* vk = dynamic_cast<UnaryTerm*>(sign->leftTerm);
                        if (vk->childTerm->marked()) {
                            sign->rightTerm->mark();
                            newMark = true;
                        }
                    }
                    
                    if (sign->leftTerm->marked() && sign->rightTerm->marked()) {
                        sign->mark();
                        newMark = true;
                    }
                    break;
                }
                case NodeType::VERIFY: break;
            }
        }
    } while (newMark);
}

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("You must specify a file in the command line!\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");
    do {
        yyparse();
    } while (!feof(yyin));
    
    for (auto it = terms_list.begin(); it != terms_list.end(); it++) {
        walkTree((*it));
    }
    walkTree(target_term);
    
    deduction();
    
    cout << "Nodes after deduction: " << endl;
    for (auto it = idToNodeMap.begin(); it != idToNodeMap.end(); it++) {
        cout << "(" << it->first << ", " << it->second->getName() << ", " << boolalpha << it->second->marked() << ")" << endl;
    }
    if (target_term->marked()) {
        cout << "YES" << endl;
    } else {
        cout << "NO" << endl;
    }
    return 0;
}
