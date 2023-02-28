# Module 3 Assignment
Author: Eric Willard

## Description
For this homework, I implemented the deduction algorithm in C++. I used flex and bison for lexical analysis and parsing respectively. I modified the Terms grammar to distinguish between PRV and PUB Terms by requiring PRV to be prefixed by `prv_` and PUB to be prefixed by `pub_`. I also extended the grammar to include a list of Terms, as well as a target term at the end for the deduction algorithm to detect.

The extended BNF:
```
TermsList ::= Terms, TermsList | Terms; Terms
Terms     ::= PRV | PUB | senc(Terms, Terms) | sdec(Terms, Terms)
              | <Terms, Terms> | PI_1(Terms) | PI_2(Terms) | pk(Terms)
              | sk(Terms) | aenc(Terms, Terms) | adec(Terms, Terms) 
              | vk(Terms) | ssk(Terms) | sign(Terms, Terms)
              | verify(Terms, Terms)
```

Example of a valid input:
```
senc(prv_s, prv_k), senc(prv_k, prv_s), <senc(prv_k, prv_s), prv_k>, senc(prv_k_1, prv_k), prv_k; <prv_k, prv_s>
```

## Deduction Algorithm
1) Construct a minimal DAG of the frame (TermsList) and target term
2) Mark all vertices in the frame, mark public keys (pk and vk), and public names
3) Consider the vertices one-by-one
    - If vertex is marked and labeled `<>`, then mark both vertices adjacent to it
    - If vertex is marked, is labeled `senc` and the vertex adjacent to it with edge labeled `0` is also marked, then mark the other vertex adjacent to it
    - If vertex is unmarked and labeled `<>/senc` then mark it if both vertices adjacent to it are marked
    - If the vertex is labeled `aenc/sign` and the vertex adjacent to it with edge `0` is `pk/vk`, and if the term adjacent to `pk/vk` is marked, then mark the other vertex adjacent to `aenc/sign`
    - If vertex is unmarked an labeled `sk` if the term adjacent to it is marked, then mark itself
4) If a vertex is marked in step 3, then repeat step 3.
5) Output YES if the target term is marked, otherwise output NO

## Compiling and running
To build the entire program from scratch, it will require that you have `flex`, `bison`, and `make` installed. These can be installed with your linux distributions package manager. For me, I used Ubuntu 22.04 so I can install these with `apt` or `apt-get`. If those requirements are met, then you can simply run `make` to build the binary called `parser` to run.

If you do not have `flex`, `bison`, and `make`, then you will need to use the `g++` compiler to compile with the following command:
```
g++ -std=c++11 -o parser terms.tab.c
```

After compiling, you can run the program with the command 
```
./parser <input_file>
```
where input file is the file containing the input. E.g. 
```
./parser tests/terms_list.test
```

The output will be all of the nodes after deduction, showing whether they are marked or not, and YES or NO indicating whether the target term is marked or not.

Example output on my machine:
```
$ cat tests/aenc_sym_key.test

aenc(pk(prv_A), prv_k), adec(sk(prv_A), aenc(pk(prv_A), prv_k)), senc(prv_k, prv_m), sdec(prv_k, senc(prv_k, prv_m)); sk(prv_A)                                                                   

$ ./parser tests/aenc_sym_key.test

---- Completed parsing ----

Nodes after deduction: 
(1, prv_A, false)
(2, pk(prv_A), true)
(3, prv_k, false)
(4, aenc(pk(prv_A), prv_k), true)
(5, sk(prv_A), false)
(6, adec(sk(prv_A), aenc(pk(prv_A), prv_k)), true)
(7, prv_m, false)
(8, senc(prv_k, prv_m), true)
(9, sdec(prv_k, senc(prv_k, prv_m)), true)
sk(prv_A) -> NO
```