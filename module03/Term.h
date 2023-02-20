#pragma once

#include <memory>
#include <string>

using namespace std;

static int nextId = 1;


class Node {
private:
    int id;
    string name;
    
public:
    Node(string name): name(name), id(nextId++) {}
    int getID() { return id; }
    string getName() { return name; };
    
    virtual ~Node() = default;
};

class UnaryTerm : public Node {
public:
    Node* childTerm;
    
    UnaryTerm(string name, Node* node) : Node(name) {
        this->childTerm = node;
    }
};

class BinaryTerm : public Node {    
public:
    Node* leftTerm;
    Node* rightTerm;
    
    BinaryTerm(string name, Node* left, Node* right) : Node(name) {
        this->leftTerm = left;
        this->rightTerm = right; 
    }
};
