%token_type { char* }
%default_type { Node* }

%include {
  #include <stdlib.h>
  #include <stdint.h>
  #include "parse.h"

  typedef struct node {
    int type;
    char *value;
    struct node *child;
    struct node *sibling;
  } Node;

  Node *root;

  Node* reduce_program(Node *p1) {
    Node *p;
    p = (Node *)malloc(sizeof(Node));
    if (p == NULL) {
      printf("Out Of Memory");
    }
    p->type = 0;
    p->value = "program";
    p->child = p1;
    p->sibling = NULL;
    root = p;
    return p;
  }

  Node* new_begin(Node *p1) {
    Node *p;
    p = (Node *)malloc(sizeof(Node));
    if (p == NULL)
      printf("Out Of Memory");
    p->type = 0;
    p->value = "new";
    p->child = p1;
    p->sibling = NULL;
    return p;
  }

  Node* call_bin_op(Node *p1, int t, Node *p2) {
    Node *p;
    p = (Node *)malloc(sizeof(Node));
    if (p == NULL) {
      printf("Out Of Memory");
    }
    p->type = t;
    p->value = "binary";
    p->child = p1;
    p1->sibling = p2;
    p->sibling = NULL;
    return p;
  }

  Node *reduce_ident(int t, char *v) {
    Node *p;
    p = (Node *)malloc(sizeof(Node));
    if (p == NULL) {
      printf("Out Of Memory");
    }
    p->type = t;
    p->value = v;
    p->child = NULL;
    p->sibling = NULL;
    return p;
  }
}

%parse_accept { printf("Parse has completed successfully.\n"); }
%syntax_error { fprintf(stderr, "Syntax error\n"); }
%parse_failure { fprintf(stderr, "Parse failure\n"); }

%start_symbol program

%left PLUS MINUS.
%left DIVIDE TIMES.

program(A) ::= top_compstmt(B).   { A = reduce_program(B); }
top_compstmt(A) ::= top_stmts(B) opt_terms. { A = B; }
top_stmts(A) ::= top_stmt(B). { A = new_begin(B); }
top_stmt ::= stmt.
//stmts(A) ::= stmt(B). { A = new_begin(B); }
stmt ::= expr.
expr ::= arg.
arg(A) ::= arg(B) PLUS arg(C).   { A = call_bin_op(B, PLUS ,C); }
arg(A) ::= arg(B) MINUS arg(C).  { A = call_bin_op(B, MINUS, C); }
arg(A) ::= arg(B) TIMES arg(C).  { A = call_bin_op(B, TIMES, C); }
arg(A) ::= arg(B) DIVIDE arg(C). { A = call_bin_op(B, DIVIDE, C); }
arg(A) ::= primary(B). { A = B; }
primary ::= literal.
literal ::= numeric.
numeric(A) ::= INTEGER(B). { A = reduce_ident(INTEGER, B); }

opt_terms ::= .
opt_terms ::= terms.
terms ::= term.
terms ::= terms term.

term ::= NL.
term ::= SEMICOLON.

%code {
  void *pointerToMalloc(void){
    return malloc;
  }

  void *pointerToFree(void){
    return free;
  }

  void freeNode(Node *p) {
    if (p == NULL)
      return;
    freeNode(p->child);
    freeNode(p->sibling);
    free(p);
  }

  void freeAllNode(void) {
    freeNode(root);
  }

  void showNode(Node *p) {
    if (p == NULL)
      return;
    if (p->value == NULL)
      return;
    printf("id:%lu, type:%d, value:%s\n", (uintptr_t)p, p->type, p->value);
    if (p->child != NULL)
      printf("  child:%lu\n", (uintptr_t)p->child);
    if (p->sibling != NULL)
      printf("  sibling:%lu\n", (uintptr_t)p->sibling);
    showNode(p->child);
    showNode(p->sibling);
  }

  void showAllNode(void) {
    showNode(root);
  }
}
