%token_type { char* }
%default_type { node* }

%include {
  #include <stdlib.h>
  #include <stdint.h>
  #include <string.h>
  #include "atom_type.h"
  #include "parse.h"

  typedef enum {
    ATOM,
    CONS,
    LITERAL
  } NodeType;

  typedef struct node node;

  typedef struct {
    struct node *car;
    struct node *cdr;
  } Cons;

  typedef struct {
    int type;
  } Atom;

  typedef struct {
    char *name;
  } Literal;

  struct node {
    NodeType type;
    union {
      Atom atom;
      Cons cons;
      Literal literal;
    };
  };

  /* mrb_parser_state is not used in HelloWorld_ToyamaRubyKaigi01 branch */
  typedef struct mrb_parser_state {
    /* see mruby/include/mruby/compile.h */
    node *cells;
    node *locals;
  } parser_state;

  parser_state *p;
  node *root;

  static char*
  parser_strndup(parser_state *p, const char *s, size_t len)
  {
    char *b = (char *)malloc(len+1);
    memcpy(b, s, len);
    b[len] = '\0';
    return b;
  }
  #undef strndup
  #define strndup(s,len) parser_strndup(p, s, len)
  static char*
  parser_strdup(parser_state *p, const char *s)
  {
    return parser_strndup(p, s, strlen(s));
  }
  #undef strdup
  #define strdup(s) parser_strdup(p, s)

  static node*
  cons_gen(parser_state *p, node *car, node *cdr)
  {
    node *c;
    c = (node *)malloc(sizeof(node));
    if (c == NULL) printf("Out Of Memory");
    c->type = CONS;
    c->cons.car = car;
    c->cons.cdr = cdr;
    return c;
  }
  #define cons(a,b) cons_gen(p,(a),(b))

  static node*
  atom(int t)
  {
    node* a;
    a = (node *)malloc(sizeof(node));
    if (a == NULL) printf("Out Of Memory");
    a->type = ATOM;
    a->atom.type = t;
    return a;
  }

  static node*
  literal(const char *s)
  {
    node* l;
    l = (node *)malloc(sizeof(node));
    if (l == NULL) printf("Out Of Memory");
    l->type = LITERAL;
    l->literal.name = strdup(s);
    return l;
  }

  static node*
  list1_gen(parser_state *p, node *a)
  {
    return cons(a, 0);
  }
  #define list1(a) list1_gen(p, (a))

  static node*
  list2_gen(parser_state *p, node *a, node *b)
  {
    return cons(a, cons(b,0));
  }
  #define list2(a,b) list2_gen(p, (a),(b))

  static node*
  list3_gen(parser_state *p, node *a, node *b, node *c)
  {
    return cons(a, cons(b, cons(c,0)));
  }
  #define list3(a,b,c) list3_gen(p, (a),(b),(c))

  static node*
  list4_gen(parser_state *p, node *a, node *b, node *c, node *d)
  {
    return cons(a, cons(b, cons(c, cons(d, 0))));
  }
  #define list4(a,b,c,d) list4_gen(p, (a),(b),(c),(d))

  static node*
  append_gen(parser_state *p, node *a, node *b)
  {
    return list3(atom(ATOM_stmts_add), a, b);
  }
  #define append(a,b) append_gen(p,(a),(b))
  #define push(a,b) append_gen(p,(a),list1(b))

  #define nsym(x) ((node*)(intptr_t)(x))
  #define nint(x) ((node*)(intptr_t)(x))

  /* (:call a b c) */
  static node*
  new_call(parser_state *p, node *a, int b, node *c, int pass)
  {
    node *n;
    switch (b) {
      case PLUS:
        n = list4(atom(ATOM_binary), a, literal(":+"), c);
        break;
      case TIMES:
        n = list4(atom(ATOM_binary), a, literal(":*"), c);
        break;
    }
    return n;
  }

  /* (:begin prog...) */
  static node*
  new_begin(parser_state *p, node *body)
  {
    if (body) {
      node *add;//, *new;
      add = list3(atom(ATOM_stmts_add), list1(atom(ATOM_stmts_new)), body);
      return add;
    }
    return cons(atom(ATOM_stmts_new), 0);
  }

  #define newline_node(n) (n)

  static node*
  call_bin_op(node *recv, int m, node *arg1)
  {
    node *n = new_call(p, recv, m, arg1, 1);
    return n;
  }

  /* (:int . i) */
  static node*
  new_int(parser_state *p, const char *s, int base, int suffix)
  { // base は10進法などを表す
    node* result = list2(atom(ATOM_at_int), literal(s));
    return result;
  }

  /* (:fcall self mid args) */
  static node*
  new_fcall(parser_state *p, node *b, node *c)
  {
    node *n = list3(atom(ATOM_command), b, c);
    return n;
  }

  /* (:block_arg . a) */
  static node*
  new_block_arg(parser_state *p, node *a)
  {
    return cons((node*)NODE_BLOCK_ARG, a);
  }

  /* (:dstr . a) */
  static node*
  new_dstr(parser_state *p, node *a)
  {
    return list2(atom(ATOM_string_literal), a);
  }
}

%parse_accept { printf("Parse has completed successfully.\n"); }
%syntax_error { fprintf(stderr, "Syntax error\n"); exit(1); }
%parse_failure { fprintf(stderr, "Parse failure\n"); exit(1); }

%start_symbol program

%nonassoc LOWEST.
%nonassoc LBRACE_ARG.
%left PLUS MINUS.
%left DIVIDE TIMES.

program ::= top_compstmt(B).   {
  root = list2(atom(ATOM_program), B);
}
top_compstmt(A) ::= top_stmts(B) opt_terms. { A = B; }
top_stmts(A) ::= none. { A = new_begin(p, 0); }
top_stmts(A) ::= top_stmt(B). { A = new_begin(p, B); }
top_stmts(A) ::= top_stmts(B) terms top_stmt(C). {
  A = append(B, newline_node(C));
  }
top_stmt ::= stmt.
stmt ::= expr.
expr ::= command_call.
expr ::= arg.

command_call ::= command.

command(A) ::= operation(B) command_args(C). [LOWEST] { A = new_fcall(p, B, C); }

command_args ::= call_args.

call_args(A) ::= args(B) opt_block_arg(C). { A = list3(atom(ATOM_args_add_block), B, C); }

block_arg(A) ::= AMPER arg(B). { A = new_block_arg(p, B); }
opt_block_arg(A) ::= COMMA block_arg(B). { A = B; }
opt_block_arg(A) ::= none. { A = 0; }

args(A) ::= arg(B). { A = list3(atom(ATOM_args_add), list1(atom(ATOM_args_new)), B); }

arg(A) ::= arg(B) PLUS arg(C).   { A = call_bin_op(B, PLUS ,C); }
arg(A) ::= arg(B) MINUS arg(C).  { A = call_bin_op(B, MINUS, C); }
arg(A) ::= arg(B) TIMES arg(C).  { A = call_bin_op(B, TIMES, C); }
arg(A) ::= arg(B) DIVIDE arg(C). { A = call_bin_op(B, DIVIDE, C); }
arg ::= primary.
primary ::= literal.
primary ::= string.
literal ::= numeric.
numeric(A) ::= INTEGER(B). { A = new_int(p, B, 10, 0); }

string ::= string_fragment.
string_fragment(A) ::= STRING_BEG string_rep(C) STRING. { A = new_dstr(p, list3(atom(ATOM_string_add), list1(atom(ATOM_string_content)), C)); }

string_rep ::= string_interp.
string_rep(A) ::= string_rep(B) string_interp(C). { A = append(B, C); }

string_interp(A) ::= STRING_MID(B). { A = list2(atom(ATOM_at_tstring_content), literal(B)); }

operation(A) ::= IDENTIFIER(B). { A = list2(atom(ATOM_at_ident), literal(B)); }
operation ::= CONSTANT.
operation ::= FID.

opt_terms ::= .
opt_terms ::= terms.
terms ::= term.
terms ::= terms term.

term ::= NL.
term ::= SEMICOLON.
none(A) ::= . { A = 0; }

%code {
#ifndef Boolean
#define Boolean int
#endif
#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

  void *pointerToMalloc(void){
    return malloc;
  }

  void *pointerToFree(void){
    return free;
  }

  void freeNode(node *p) {
    if (p == NULL)
      return;
    if (p->type == CONS) {
      freeNode(p->cons.car);
      freeNode(p->cons.cdr);
    } else if (p->type == LITERAL) {
      free(p->literal.name);
    }
    free(p);
  }

  void freeAllNode(void) {
    freeNode(root);
  }

  void showNode1(node *p, Boolean isCar, int indent, Boolean isRightMost) {
    if (p == NULL) return;
    switch (p->type) {
      case CONS:
        if (isCar) {
          printf("\n");
          for (int i=0; i<indent; i++) {
            printf(" ");
          }
          printf("[");
        } else {
          printf(", ");
        }
        if (p->cons.car && p->cons.car->type != CONS && p->cons.cdr == NULL) {
          isRightMost = TRUE;
        }
        break;
      case ATOM:
        printf("%d", p->atom.type);
        if (isRightMost) {
          printf("]");
        }
        break;
      case LITERAL:
        printf("\"%s\"", p->literal.name);
        if (isRightMost) {
          printf("]");
        }
        break;
    }
    if (p->type == CONS) {
      showNode1(p->cons.car, TRUE, indent+1, isRightMost);
      showNode1(p->cons.cdr, FALSE, indent, isRightMost);
    }
  }

  void showNode2(node *p) {
    if (p == NULL) return;
    switch (p->type) {
      case ATOM:
        printf("    atom:%p", p);
        printf("  value:%d\n", p->atom.type);
        break;
      case LITERAL:
        printf("    literal:%p", p);
        printf("  name:\"%s\"\n", p->literal.name);
        break;
      case CONS:
        printf("cons:%p\n", p);
        printf(" car:%p\n", p->cons.car);
        printf(" cdr:%p\n", p->cons.cdr);
        showNode2(p->cons.car);
        showNode2(p->cons.cdr);
    }
  }

  void showAllNode(int way) {
    if (way == 1) {
      showNode1(root, TRUE, 0, FALSE);
    } else if (way == 2) {
      showNode2(root);
    }
    printf("\n");
  }

  void *pointerToRoot(void){
    return root;
  }

  Boolean hasCar(node *p) {
    if (p->type != CONS)
      return FALSE;
    if (p->cons.car) {
      return TRUE;
    }
    return FALSE;
  }

  Boolean hasCdr(node *p) {
    if (p->type != CONS)
      return FALSE;
    if (p->cons.cdr) {
      return TRUE;
    }
    return FALSE;
  }

  char *kind(node *p){
    char *type;
    switch (p->type) {
      case ATOM:
        type = "a";
        break;
      case LITERAL:
        type = "l";
        break;
      case CONS:
        type = "c";
        break;
    }
    return type;
  }

  int atom_type(node *p) {
    if (p->type != ATOM) {
      return 0;
    }
    return p->atom.type;
  }

  void *pointerToLiteral(node *p) {
    return p->literal.name;
  }

  void *pointerToCar(node *p){
    return p->cons.car;
  }

  void *pointerToCdr(node *p){
    return p->cons.cdr;
  }

}
