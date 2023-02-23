#pragma once

#include <memory>
#include <string>

using namespace std;

static int nextId = 1;

enum NodeType {
    PRV,
    PUB,
    SENC,
    SDEC,
    PAIR,
    PI_1,
    PI_2,
    PK,
    SK,
    AENC,
    ADEC,
    VK,
    SSK,
    SIGN,
    VERIFY
};

class Node {
private:
    int id;
    string name;
    bool marked;
    NodeType type;
    
public:
    Node(string name, NodeType type): name(name), id(nextId++), marked(false), type(type) {}
    
    void setMarked(bool b) { this->marked = b; }
    
    int getID() { return id; }
    string getName() { return name; }
    bool getMarked() { return marked; }
    NodeType getType() { return type; }
    
    virtual ~Node() = default;
};

class UnaryTerm : public Node {
public:
    Node* childTerm;
    
    UnaryTerm(string name, NodeType type, Node* node) : Node(name, type) {
        this->childTerm = node;
    }
};

class BinaryTerm : public Node {    
public:
    Node* leftTerm;
    Node* rightTerm;
    
    BinaryTerm(string name, NodeType type, Node* left, Node* right) : Node(name, type) {
        this->leftTerm = left;
        this->rightTerm = right; 
    }
};
