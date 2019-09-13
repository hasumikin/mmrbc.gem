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

  typedef enum {
    ATOM,
    CONS
  } NodeType;

  typedef struct node node;

  typedef struct {
    struct node *car;
    struct node *cdr;
  } Cons;

  typedef struct {
    char *type;
    int index;
  } Atom;

  struct node {
    NodeType type;
    union {
      Atom atom;
      Cons cons;
    };
  };

///* parser structure */
//struct mrb_parser_state {
//  mrb_state *mrb;
//  struct mrb_pool *pool;
//  mrb_ast_node *cells;
//  const char *s, *send;
//#ifndef MRB_DISABLE_STDIO
//  FILE *f;
//#endif
//  mrbc_context *cxt;
//  mrb_sym filename_sym;
//  uint16_t lineno;
//  int column;
//
//  enum mrb_lex_state_enum lstate;
//  mrb_ast_node *lex_strterm; /* (type nest_level beg . end) */
//
//  unsigned int cond_stack;
//  unsigned int cmdarg_stack;
//  int paren_nest;
//  int lpar_beg;
//  int in_def, in_single;
//  mrb_bool cmd_start:1;
//  mrb_ast_node *locals;
//
//  mrb_ast_node *pb;
//  char *tokbuf;
//  char buf[MRB_PARSER_TOKBUF_SIZE];
//  int tidx;
//  int tsiz;
//
//  mrb_ast_node *all_heredocs; /* list of mrb_parser_heredoc_info* */
//  mrb_ast_node *heredocs_from_nextline;
//  mrb_ast_node *parsing_heredoc;
//  mrb_ast_node *lex_strterm_before_heredoc;
//
//  void *ylval;
//
//  size_t nerr;
//  size_t nwarn;
//  mrb_ast_node *tree;
//
//  mrb_bool no_optimize:1;
//  mrb_bool on_eval:1;
//  mrb_bool capture_errors:1;
//  struct mrb_parser_message error_buffer[10];
//  struct mrb_parser_message warn_buffer[10];
//
//  mrb_sym* filename_table;
//  uint16_t filename_table_length;
//  uint16_t current_filename_index;
//
//  struct mrb_jmpbuf* jmp;
//};
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
    char *b = (char *)malloc(len+1);//TODO リテラルプールへ
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
    //if (p->cells) {
    //  c = p->cells;
    //  p->cells = p->cells->cdr;
    //}
    //else {
    //  c = (node *)parser_palloc(p, sizeof(node));
    c = (node *)malloc(sizeof(node));
    if (c == NULL) printf("Out Of Memory");
    c->type = CONS;
    //}
    c->cons.car = car;
    c->cons.cdr = cdr;
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
  atom(const char *s)
  {
    node* a;
    a = (node *)malloc(sizeof(node));
    if (a == NULL) printf("Out Of Memory");
    a->type = ATOM;
    a->atom.type = strdup(s);
    a->atom.index = 0;
    return a;
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

static node*
append_gen(parser_state *p, node *a, node *b)
{
//  node *c = a;
//  if (!a) return b;
//  while (c->cons.cdr) {
//    c = c->cons.cdr;
//  }
//  if (b) {
//    c->cons.cdr = b;
//  }
//  return a;
  return list3(atom(":stmts_add"), a, b);
}
#define append(a,b) append_gen(p,(a),(b))
#define push(a,b) append_gen(p,(a),list1(b))

  #define nsym(x) ((node*)(intptr_t)(x))
  #define nint(x) ((node*)(intptr_t)(x))

  static node*
  locals_node(parser_state *p)
  {
    //return p->locals->cons.car;
    //return p->locals ? p->locals->cons.car : NULL;
  }

  /* (:scope (vars..) (prog...)) */
  static node*
  new_scope(parser_state *p, node *body)
  {
    return cons(atom(":stmts_add"), cons(locals_node(p), body));
  }

  /* (:call a b c) */
  static node*
  new_call(parser_state *p, node *a, int b, node *c, int pass)
  {
    //void_expr_error(p, a);
    //NODE_LINENO(n, a);
    node *n;
    switch (b) {
      case PLUS:
        n = list4(atom(":binary"), a, atom(":+"), c);
        break;
      case TIMES:
        n = list4(atom(":binary"), a, atom(":*"), c);
        break;
    }
    return n;
  }

  /* (:begin prog...) */
  static node*
  new_begin(parser_state *p, node *body)
  {
    if (body) {
      node *add, *new;
      //add = list1(atom(":stmts_add"));
      //new = list2(atom(":stmts_new"), body);
      //add->cons.cdr = new;
      add = list3(atom(":stmts_add"), list1(atom(":stmts_new")), body);
      return add;
    }
    return cons(atom(":stmts_new"), 0);//TODO ここおかしい
  }

  #define newline_node(n) (n)

  static node*
  call_bin_op(node *recv, int m, node *arg1)
  {
    //node *n = new_call(p, recv, m, list1(list1(arg1)), 1);
    node *n = new_call(p, recv, m, arg1, 1);
    return n;
  }

  /* (:int . i) */
  static node*
  new_int(parser_state *p, const char *s, int base, int suffix)
  { // base は10進法などを表す
    //node* result = list3((node*)NODE_INT, (node*)strdup(s), nint(base));
    node* result = list2(atom(":@int"), atom(s));
    return result;
  }

  /* (:self) */
  static node*
  new_self(parser_state *p)
  {
    return list1(atom(":self"));
  }

  /* (:fcall self mid args) */
  static node*
  new_fcall(parser_state *p, node *b, node *c)
  {
    //node *n = new_self(p);
    node *n = list3(atom(":command"), b, c);
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
    return list2(atom(":string_literal"), a);
    //return cons((node*)NODE_DSTR, a);
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
//  if (!p->locals) p->locals = cons(atom(":program"),0);
  //if (!p->locals) {node *a = cons(atom(":program"),0);}
  root = list2(atom(":program"), B); }
top_compstmt(A) ::= top_stmts(B) opt_terms. { A = B; }
top_stmts(A) ::= none. { A = new_begin(p, 0); }
top_stmts(A) ::= top_stmt(B). { A = new_begin(p, B); }
top_stmts(A) ::= top_stmts(B) terms top_stmt(C). {
  A = append(B, newline_node(C)); // TODO mrubyのparse.yではpushになっている。。。
  }
top_stmt ::= stmt.
//stmts(A) ::= stmt(B). { A = new_begin(B); }
stmt ::= expr.
expr ::= command_call.
expr ::= arg.

command_call ::= command.

command(A) ::= operation(B) command_args(C). [LOWEST] { A = new_fcall(p, B, C); }

command_args ::= call_args.

call_args(A) ::= args(B) opt_block_arg(C). { A = list3(atom(":args_add_block"), B, C); }

block_arg(A) ::= AMPER arg(B). { A = new_block_arg(p, B); }
opt_block_arg(A) ::= COMMA block_arg(B). { A = B; }
opt_block_arg(A) ::= none. { A = 0; }

args(A) ::= arg(B). { A = list3(atom(":args_add"), list1(atom(":args_new")), B); }

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
//string ::= string string_fragment. { A = concat_string(p, B, C); }
string_fragment(A) ::= STRING_BEG string_rep(C) STRING. { A = new_dstr(p, list3(atom(":string_add"), list1(atom(":string_content")), C)); }

string_rep ::= string_interp.
string_rep(A) ::= string_rep(B) string_interp(C). { A = append(B, C); }

string_interp(A) ::= STRING_MID(B). { A = list2(atom(":@tstring_content"), atom(B)); }

operation(A) ::= IDENTIFIER(B). { A = list2(atom(":@ident"), atom(B)); }
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
#ifndef Boolean         /* Boolean が定義されていなかったら */
#define Boolean int
#endif
#ifndef TRUE            /* TRUE が定義されていなかったら */
#define TRUE 1
#endif
#ifndef FALSE           /* FALSE が定義されていなかったら */
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
    } else {
      if (p->atom.type != NULL) {
        // printf("free atom: %p\n", p);
        free(p->atom.type);
      }
    }
    // printf("free cons: %p\n", p);
    free(p);
  }

  void freeAllNode(void) {
    freeNode(root);
  }

  void showNode1(node *p, Boolean isCar, int indent, Boolean isRightMost) {
    if (p == NULL) return;
    if (p->type == CONS) {
      if (isCar) {
        printf("\n");
        for (int i=0; i<indent; i++) {
          printf(" ");
        }
        printf("[");
      } else {
        printf(", ");
      }
      if (p->cons.car && p->cons.car->type == ATOM && p->cons.cdr == NULL) {
        isRightMost = TRUE;
      }
    }
    if (p->type == ATOM) {
      printf("%s", p->atom.type);
      if (isRightMost) {
        printf("]");
      }
    } else {
      showNode1(p->cons.car, TRUE, indent+1, isRightMost);
      showNode1(p->cons.cdr, FALSE, indent, isRightMost);
    }
  }

  void showNode2(node *p) {
    if (p == NULL) return;
    if (p->type == ATOM) {
      printf("    atom:%p", p);
      printf("  value:%s\n", p->atom.type);
    } else {
      printf("cons:%p\n", p);
      printf(" car:%p\n", p->cons.car);
      printf(" cdr:%p\n", p->cons.cdr);
      showNode2(p->cons.car);
      showNode2(p->cons.cdr);
    }
  }

  void showAllNode(void) {
    showNode1(root, TRUE, 0, FALSE);
    //showNode2(root);
  }

  void *pointerToRoot(void){
    return root;
  }

  Boolean hasCar(node *p) {
    if (p->type == ATOM)
      return FALSE;
    if (p->cons.car) {
      return TRUE;
    }
    return FALSE;
  }

  Boolean hasCdr(node *p) {
    if (p->type == ATOM)
      return FALSE;
    if (p->cons.cdr) {
      return TRUE;
    }
    return FALSE;
  }

  Boolean isAtom(node *p){
    if (p->type == ATOM) {
      return TRUE;
    }
    return FALSE;
  }

  void *pointerToType(node *p) {
    return p->atom.type;
  }

  void *pointerToCar(node *p){
    return p->cons.car;
  }

  void *pointerToCdr(node *p){
    return p->cons.cdr;
  }

}
