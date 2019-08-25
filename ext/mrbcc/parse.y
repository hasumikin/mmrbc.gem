%token_type { char* }
%default_type { node* }

%include {
  #include <stdlib.h>
  #include <stdint.h>
  #include <string.h>
  #include "parse.h"

enum node_type {
  NODE_METHOD,
  NODE_SCOPE,
  NODE_BLOCK,
  NODE_IF,
  NODE_CASE,
  NODE_WHEN,
  NODE_WHILE,
  NODE_UNTIL,
  NODE_ITER,
  NODE_FOR,
  NODE_BREAK,
  NODE_NEXT,
  NODE_REDO,
  NODE_RETRY,
  NODE_BEGIN,
  NODE_RESCUE,
  NODE_ENSURE,
  NODE_AND,
  NODE_OR,
  NODE_NOT,
  NODE_MASGN,
  NODE_ASGN,
  NODE_CDECL,
  NODE_CVASGN,
  NODE_CVDECL,
  NODE_OP_ASGN,
  NODE_CALL,
  NODE_SCALL,
  NODE_FCALL,
  NODE_SUPER,
  NODE_ZSUPER,
  NODE_ARRAY,
  NODE_ZARRAY,
  NODE_HASH,
  NODE_KW_HASH,
  NODE_RETURN,
  NODE_YIELD,
  NODE_LVAR,
  NODE_DVAR,
  NODE_GVAR,
  NODE_IVAR,
  NODE_CONST,
  NODE_CVAR,
  NODE_NTH_REF,
  NODE_BACK_REF,
  NODE_MATCH,
  NODE_INT,
  NODE_FLOAT,
  NODE_NEGATE,
  NODE_LAMBDA,
  NODE_SYM,
  NODE_STR,
  NODE_DSTR,
  NODE_XSTR,
  NODE_DXSTR,
  NODE_REGX,
  NODE_DREGX,
  NODE_DREGX_ONCE,
  NODE_ARG,
  NODE_ARGS_TAIL,
  NODE_KW_ARG,
  NODE_KW_REST_ARGS,
  NODE_SPLAT,
  NODE_TO_ARY,
  NODE_SVALUE,
  NODE_BLOCK_ARG,
  NODE_DEF,
  NODE_SDEF,
  NODE_ALIAS,
  NODE_UNDEF,
  NODE_CLASS,
  NODE_MODULE,
  NODE_SCLASS,
  NODE_COLON2,
  NODE_COLON3,
  NODE_DOT2,
  NODE_DOT3,
  NODE_SELF,
  NODE_NIL,
  NODE_TRUE,
  NODE_FALSE,
  NODE_DEFINED,
  NODE_POSTEXE,
  NODE_DSYM,
  NODE_HEREDOC,
  NODE_LITERAL_DELIM,
  NODE_WORDS,
  NODE_SYMBOLS,
  NODE_LAST
};

  typedef struct mrb_parser_state {
    /* see mruby/include/mruby/compile.h */
  } parser_state;

  typedef struct node {
    int type; //hh
    char *value; //hh
    struct node *car;
    struct node *cdr;
  } node;

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

  node* reduce_program(node *p1) {
    node *p;
    p = (node *)malloc(sizeof(node));
    if (p == NULL) {
      printf("Out Of Memory");
    }
    p->type = 0;
    p->value = "program";
    p->car = p1;
    p->cdr = NULL;
    root = p;
    return p;
  }

  node* new_begin(node *p1) {
    node *p;
    p = (node *)malloc(sizeof(node));
    if (p == NULL)
      printf("Out Of Memory");
    p->type = 0;
    p->value = "new";
    p->car = p1;
    p->cdr = NULL;
    return p;
  }

  static node*
  cons_gen(parser_state *p, node *car, node *cdr)
  {
    node *c;
    //if (p->cells) {
    //  c = p->cells;
    //  p->cells = p->cells->cdr;
    //}
    //else {
    //  c = (node *)parser_palloc(p, sizeof(node));
    c = (node *)malloc(sizeof(node));
    if (c == NULL) printf("Out Of Memory");
    //}
    c->car = car;
    c->cdr = cdr;
    //c->lineno = p->lineno;
    //c->filename_index = p->current_filename_index;
    /* beginning of next partial file; need to point the previous file */
    //if (p->lineno == 0 && p->current_filename_index > 0) {
    //  c->filename_index-- ;
    //}
    return c;
  }
  #define cons(a,b) cons_gen(p,(a),(b))

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
list5_gen(parser_state *p, node *a, node *b, node *c, node *d, node *e)
{
  return cons(a, cons(b, cons(c, cons(d, cons(e, 0)))));
}
#define list5(a,b,c,d,e) list5_gen(p, (a),(b),(c),(d),(e))

static node*
list6_gen(parser_state *p, node *a, node *b, node *c, node *d, node *e, node *f)
{
  return cons(a, cons(b, cons(c, cons(d, cons(e, cons(f, 0))))));
}
#define list6(a,b,c,d,e,f) list6_gen(p, (a),(b),(c),(d),(e),(f))
  #define nsym(x) ((node*)(intptr_t)(x))
  #define nint(x) ((node*)(intptr_t)(x))
  /* (:call a b c) */
  static node*
  new_call(parser_state *p, node *a, int b, node *c, int pass)
  {
    node *bin;
    bin->value = ":+";
    bin->car = NULL;
    bin->cdr = NULL;
    node *n = list4(nint(pass?NODE_CALL:NODE_SCALL), a, bin, c);
    //void_expr_error(p, a);
    //NODE_LINENO(n, a);
    return n;
  }

  static node*
  call_bin_op(node *recv, int m, node *arg1)
  {
    node *n = new_call(p, recv, m, list1(list1(arg1)), 1);
    n->value = "binary";
    return n;
  }

  /* (:int . i) */
  static node*
  new_int(parser_state *p, const char *s, int base, int suffix)
  {
    node* result = list3((node*)NODE_INT, (node*)strdup(s), nint(base));
    result->value = "@int";
    return result;
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
numeric(A) ::= INTEGER(B). { A = new_int(p, B, 10, 0); }

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

  void freeNode(node *p) {
    printf("free: %p", p);
    if (p == NULL || (uintptr_t)p < 1000)
      return;
    freeNode(p->car);
    freeNode(p->cdr);
    free(p);
  }

  void freeAllNode(void) {
    freeNode(root);
  }

  void showNode(node *p) {
    if (p == NULL || (uintptr_t)p < 1000)
      return;
    if (p->value == NULL)
      return;
    printf("id:%p, type:%d, value:%s\n", p, p->type, p->value);
    if (p->car != NULL)
      printf("  car:%p\n", p->car);
    if (p->cdr != NULL)
      printf("  cdr:%p\n", p->cdr);
    showNode(p->car);
    showNode(p->cdr);
  }

  void showAllNode(void) {
    showNode(root);
  }
}
