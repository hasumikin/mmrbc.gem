/*
** 2000-05-29
**
** The author disclaims copyright to this source code.  In place of
** a legal notice, here is a blessing:
**
**    May you do good and not evil.
**    May you find forgiveness for yourself and forgive others.
**    May you share freely, never taking more than you give.
**
*************************************************************************
** Driver template for the LEMON parser generator.
**
** The "lemon" program processes an LALR(1) input grammar file, then uses
** this template to construct a parser.  The "lemon" program inserts text
** at each "%%" line.  Also, any "P-a-r-s-e" identifer prefix (without the
** interstitial "-" characters) contained in this template is changed into
** the value of the %name directive from the grammar.  Otherwise, the content
** of this template is copied straight through into the generate parser
** source file.
**
** The following is the concatenation of all %include directives from the
** input grammar file:
*/
#include <stdio.h>
#include <assert.h>
/************ Begin %include sections from the grammar ************************/
#line 4 "./parse.y"

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
    c->type = CONS;
    if (c == NULL) printf("Out Of Memory");
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
  atom_node(const char *s)
  {
    node* a;
    a = (node *)malloc(sizeof(node));
    if (a == NULL) printf("Out Of Memory");
    a->type = ATOM;
    a->atom.type = strdup(s);
    a->atom.index = 0;
    return (node *)a;
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
  node *c = a;
  if (!a) return b;
  while (c->cons.cdr) {
    c = c->cons.cdr;
  }
  if (b) {
    c->cons.cdr = b;
  }
  node *add = list1(list1(atom_node(":stmts_add")));
  add->cons.car->cons.cdr = a;
  return add;
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
    return cons(atom_node(":stmts_add"), cons(locals_node(p), body));
    //return cons(atom_node(":program"), body);
  }

  /* (:call a b c) */
  static node*
  new_call(parser_state *p, node *a, int b, node *c, int pass)
  {
    node *n = list4(atom_node(":binary"), a, atom_node(":+"), c);
    //void_expr_error(p, a);
    //NODE_LINENO(n, a);
    return n;
  }

  /* (:begin prog...) */
  static node*
  new_begin(parser_state *p, node *body)
  {
    if (body) {
      node *add, *new;
      add = list1(atom_node(":stmts_add"));
      new = list2(list1(atom_node(":stmts_new")), body);
      add->cons.cdr = new;
      return list1(add);
    }
    return cons(atom_node(":stmts_new"), 0);
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
    node* result = list2(atom_node(":@int"), atom_node(s));
    return result;
  }

  /* (:self) */
  static node*
  new_self(parser_state *p)
  {
    return list1(atom_node(":self"));
  }

  /* (:fcall self mid args) */
  static node*
  new_fcall(parser_state *p, node *b, node *c)
  {
    node *n = new_self(p);
    n = list4(atom_node(":command"), n, b, c);
    return n;
  }

  /* (:block_arg . a) */
  static node*
  new_block_arg(parser_state *p, node *a)
  {
    return cons((node*)NODE_BLOCK_ARG, a);
  }
#line 416 "./parse.c"
/**************** End of %include directives **********************************/
/* These constants specify the various numeric values for terminal symbols
** in a format understandable to "makeheaders".  This section is blank unless
** "lemon" is run with the "-m" command-line option.
***************** Begin makeheaders token definitions *************************/
/**************** End makeheaders token definitions ***************************/

/* The next sections is a series of control #defines.
** various aspects of the generated parser.
**    YYCODETYPE         is the data type used to store the integer codes
**                       that represent terminal and non-terminal symbols.
**                       "unsigned char" is used if there are fewer than
**                       256 symbols.  Larger types otherwise.
**    YYNOCODE           is a number of type YYCODETYPE that is not used for
**                       any terminal or nonterminal symbol.
**    YYFALLBACK         If defined, this indicates that one or more tokens
**                       (also known as: "terminal symbols") have fall-back
**                       values which should be used if the original symbol
**                       would not parse.  This permits keywords to sometimes
**                       be used as identifiers, for example.
**    YYACTIONTYPE       is the data type used for "action codes" - numbers
**                       that indicate what to do in response to the next
**                       token.
**    ParseTOKENTYPE     is the data type used for minor type for terminal
**                       symbols.  Background: A "minor type" is a semantic
**                       value associated with a terminal or non-terminal
**                       symbols.  For example, for an "ID" terminal symbol,
**                       the minor type might be the name of the identifier.
**                       Each non-terminal can have a different minor type.
**                       Terminal symbols all have the same minor type, though.
**                       This macros defines the minor type for terminal 
**                       symbols.
**    YYMINORTYPE        is the data type used for all minor types.
**                       This is typically a union of many types, one of
**                       which is ParseTOKENTYPE.  The entry in the union
**                       for terminal symbols is called "yy0".
**    YYSTACKDEPTH       is the maximum depth of the parser's stack.  If
**                       zero the stack is dynamically sized using realloc()
**    ParseARG_SDECL     A static variable declaration for the %extra_argument
**    ParseARG_PDECL     A parameter declaration for the %extra_argument
**    ParseARG_PARAM     Code to pass %extra_argument as a subroutine parameter
**    ParseARG_STORE     Code to store %extra_argument into yypParser
**    ParseARG_FETCH     Code to extract %extra_argument from yypParser
**    ParseCTX_*         As ParseARG_ except for %extra_context
**    YYERRORSYMBOL      is the code number of the error symbol.  If not
**                       defined, then do no error processing.
**    YYNSTATE           the combined number of states.
**    YYNRULE            the number of rules in the grammar
**    YYNTOKEN           Number of terminal symbols
**    YY_MAX_SHIFT       Maximum value for shift actions
**    YY_MIN_SHIFTREDUCE Minimum value for shift-reduce actions
**    YY_MAX_SHIFTREDUCE Maximum value for shift-reduce actions
**    YY_ERROR_ACTION    The yy_action[] code for syntax error
**    YY_ACCEPT_ACTION   The yy_action[] code for accept
**    YY_NO_ACTION       The yy_action[] code for no-op
**    YY_MIN_REDUCE      Minimum value for reduce actions
**    YY_MAX_REDUCE      Maximum value for reduce actions
*/
#ifndef INTERFACE
# define INTERFACE 1
#endif
/************* Begin control #defines *****************************************/
#define YYCODETYPE unsigned char
#define YYNOCODE 35
#define YYACTIONTYPE unsigned char
#define ParseTOKENTYPE  char* 
typedef union {
  int yyinit;
  ParseTOKENTYPE yy0;
  node* yy43;
} YYMINORTYPE;
#ifndef YYSTACKDEPTH
#define YYSTACKDEPTH 100
#endif
#define ParseARG_SDECL
#define ParseARG_PDECL
#define ParseARG_PARAM
#define ParseARG_FETCH
#define ParseARG_STORE
#define ParseCTX_SDECL
#define ParseCTX_PDECL
#define ParseCTX_PARAM
#define ParseCTX_FETCH
#define ParseCTX_STORE
#define YYNSTATE             17
#define YYNRULE              35
#define YYNTOKEN             13
#define YY_MAX_SHIFT         16
#define YY_MIN_SHIFTREDUCE   43
#define YY_MAX_SHIFTREDUCE   77
#define YY_ERROR_ACTION      78
#define YY_ACCEPT_ACTION     79
#define YY_NO_ACTION         80
#define YY_MIN_REDUCE        81
#define YY_MAX_REDUCE        115
/************* End control #defines *******************************************/
#define YY_NLOOKAHEAD ((int)(sizeof(yy_lookahead)/sizeof(yy_lookahead[0])))

/* Define the yytestcase() macro to be a no-op if is not already defined
** otherwise.
**
** Applications can choose to define yytestcase() in the %include section
** to a macro that can assist in verifying code coverage.  For production
** code the yytestcase() macro should be turned off.  But it is useful
** for testing.
*/
#ifndef yytestcase
# define yytestcase(X)
#endif


/* Next are the tables used to determine what action to take based on the
** current state and lookahead token.  These tables are used to implement
** functions that take a state number and lookahead value and return an
** action integer.  
**
** Suppose the action integer is N.  Then the action is determined as
** follows
**
**   0 <= N <= YY_MAX_SHIFT             Shift N.  That is, push the lookahead
**                                      token onto the stack and goto state N.
**
**   N between YY_MIN_SHIFTREDUCE       Shift to an arbitrary state then
**     and YY_MAX_SHIFTREDUCE           reduce by rule N-YY_MIN_SHIFTREDUCE.
**
**   N == YY_ERROR_ACTION               A syntax error has occurred.
**
**   N == YY_ACCEPT_ACTION              The parser accepts its input.
**
**   N == YY_NO_ACTION                  No such action.  Denotes unused
**                                      slots in the yy_action[] table.
**
**   N between YY_MIN_REDUCE            Reduce by rule N-YY_MIN_REDUCE
**     and YY_MAX_REDUCE
**
** The action table is constructed as a single large table named yy_action[].
** Given state S and lookahead X, the action is computed as either:
**
**    (A)   N = yy_action[ yy_shift_ofst[S] + X ]
**    (B)   N = yy_default[S]
**
** The (A) formula is preferred.  The B formula is used instead if
** yy_lookahead[yy_shift_ofst[S]+X] is not equal to X.
**
** The formulas above are for computing the action when the lookahead is
** a terminal symbol.  If the lookahead is a non-terminal (as occurs after
** a reduce action) then the yy_reduce_ofst[] array is used in place of
** the yy_shift_ofst[] array.
**
** The following are the tables generated in this section:
**
**  yy_action[]        A single table containing all actions.
**  yy_lookahead[]     A table containing the lookahead for each entry in
**                     yy_action.  Used to detect hash collisions.
**  yy_shift_ofst[]    For each state, the offset into yy_action for
**                     shifting terminals.
**  yy_reduce_ofst[]   For each state, the offset into yy_action for
**                     shifting non-terminals after a reduce.
**  yy_default[]       Default action for each state.
**
*********** Begin parsing tables **********************************************/
#define YY_ACTTAB_COUNT (110)
static const YYACTIONTYPE yy_action[] = {
 /*     0 */    79,   16,    8,   89,   83,   84,    3,   84,   84,   84,
 /*    10 */    13,   84,    2,   58,   59,   70,   71,   90,   13,   13,
 /*    20 */    13,   85,   12,   85,   85,   85,   13,   85,    2,   87,
 /*    30 */    12,   12,   12,   58,   13,   13,   13,  113,    7,    6,
 /*    40 */     4,    5,   11,   76,   77,   86,   86,    9,    4,    5,
 /*    50 */    11,   11,   11,   58,   59,   70,   71,   76,   77,   95,
 /*    60 */    81,   10,   80,   80,   80,   80,   94,   95,   95,   95,
 /*    70 */    14,   80,   80,   80,   94,   94,   94,   15,   14,   14,
 /*    80 */    14,   80,   80,   80,   80,   15,   15,   15,   80,   80,
 /*    90 */    80,   82,   80,   80,    1,   80,   80,   80,   80,   80,
 /*   100 */    80,   80,   80,   80,   80,   80,   80,   80,   80,    1,
};
static const YYCODETYPE yy_lookahead[] = {
 /*     0 */    13,   14,   15,   30,   17,   18,    5,   20,   21,   22,
 /*    10 */    23,   24,   25,    7,    8,    9,   10,   17,   31,   32,
 /*    20 */    33,   18,   23,   20,   21,   22,   23,   24,   25,   29,
 /*    30 */    31,   32,   33,    7,   31,   32,   33,   34,    1,    2,
 /*    40 */     3,    4,   23,   11,   12,   26,   27,   28,    3,    4,
 /*    50 */    31,   32,   33,    7,    8,    9,   10,   11,   12,   23,
 /*    60 */     0,    6,   35,   35,   35,   35,   23,   31,   32,   33,
 /*    70 */    23,   35,   35,   35,   31,   32,   33,   23,   31,   32,
 /*    80 */    33,   35,   35,   35,   35,   31,   32,   33,   35,   35,
 /*    90 */    35,   16,   35,   35,   19,   35,   35,   35,   35,   35,
 /*   100 */    35,   35,   35,   35,   35,   35,   35,   35,   35,   34,
};
#define YY_SHIFT_COUNT    (16)
#define YY_SHIFT_MIN      (0)
#define YY_SHIFT_MAX      (60)
static const unsigned char yy_shift_ofst[] = {
 /*     0 */     6,   46,   26,   26,   26,   26,   26,   26,   32,   55,
 /*    10 */     1,   37,   37,   37,   45,   45,   60,
};
#define YY_REDUCE_COUNT (10)
#define YY_REDUCE_MIN   (-27)
#define YY_REDUCE_MAX   (75)
static const signed char yy_reduce_ofst[] = {
 /*     0 */   -13,    3,   19,   -1,   36,   43,   47,   54,   75,    0,
 /*    10 */   -27,
};
static const YYACTIONTYPE yy_default[] = {
 /*     0 */    98,  111,   78,   78,   78,   78,   78,   78,  110,   98,
 /*    10 */    78,   91,   88,  102,   93,   92,   78,
};
/********** End of lemon-generated parsing tables *****************************/

/* The next table maps tokens (terminal symbols) into fallback tokens.  
** If a construct like the following:
** 
**      %fallback ID X Y Z.
**
** appears in the grammar, then ID becomes a fallback token for X, Y,
** and Z.  Whenever one of the tokens X, Y, or Z is input to the parser
** but it does not parse, the type of the token is changed to ID and
** the parse is retried before an error is thrown.
**
** This feature can be used, for example, to cause some keywords in a language
** to revert to identifiers if they keyword does not apply in the context where
** it appears.
*/
#ifdef YYFALLBACK
static const YYCODETYPE yyFallback[] = {
};
#endif /* YYFALLBACK */

/* The following structure represents a single element of the
** parser's stack.  Information stored includes:
**
**   +  The state number for the parser at this level of the stack.
**
**   +  The value of the token stored at this level of the stack.
**      (In other words, the "major" token.)
**
**   +  The semantic value stored at this level of the stack.  This is
**      the information used by the action routines in the grammar.
**      It is sometimes called the "minor" token.
**
** After the "shift" half of a SHIFTREDUCE action, the stateno field
** actually contains the reduce action for the second half of the
** SHIFTREDUCE.
*/
struct yyStackEntry {
  YYACTIONTYPE stateno;  /* The state-number, or reduce action in SHIFTREDUCE */
  YYCODETYPE major;      /* The major token value.  This is the code
                         ** number for the token at this stack level */
  YYMINORTYPE minor;     /* The user-supplied minor token value.  This
                         ** is the value of the token  */
};
typedef struct yyStackEntry yyStackEntry;

/* The state of the parser is completely contained in an instance of
** the following structure */
struct yyParser {
  yyStackEntry *yytos;          /* Pointer to top element of the stack */
#ifdef YYTRACKMAXSTACKDEPTH
  int yyhwm;                    /* High-water mark of the stack */
#endif
#ifndef YYNOERRORRECOVERY
  int yyerrcnt;                 /* Shifts left before out of the error */
#endif
  ParseARG_SDECL                /* A place to hold %extra_argument */
  ParseCTX_SDECL                /* A place to hold %extra_context */
#if YYSTACKDEPTH<=0
  int yystksz;                  /* Current side of the stack */
  yyStackEntry *yystack;        /* The parser's stack */
  yyStackEntry yystk0;          /* First stack entry */
#else
  yyStackEntry yystack[YYSTACKDEPTH];  /* The parser's stack */
  yyStackEntry *yystackEnd;            /* Last entry in the stack */
#endif
};
typedef struct yyParser yyParser;

#ifndef NDEBUG
#include <stdio.h>
static FILE *yyTraceFILE = 0;
static char *yyTracePrompt = 0;
#endif /* NDEBUG */

#ifndef NDEBUG
/* 
** Turn parser tracing on by giving a stream to which to write the trace
** and a prompt to preface each trace message.  Tracing is turned off
** by making either argument NULL 
**
** Inputs:
** <ul>
** <li> A FILE* to which trace output should be written.
**      If NULL, then tracing is turned off.
** <li> A prefix string written at the beginning of every
**      line of trace output.  If NULL, then tracing is
**      turned off.
** </ul>
**
** Outputs:
** None.
*/
void ParseTrace(FILE *TraceFILE, char *zTracePrompt){
  yyTraceFILE = TraceFILE;
  yyTracePrompt = zTracePrompt;
  if( yyTraceFILE==0 ) yyTracePrompt = 0;
  else if( yyTracePrompt==0 ) yyTraceFILE = 0;
}
#endif /* NDEBUG */

#if defined(YYCOVERAGE) || !defined(NDEBUG)
/* For tracing shifts, the names of all terminals and nonterminals
** are required.  The following table supplies these names */
static const char *const yyTokenName[] = { 
  /*    0 */ "$",
  /*    1 */ "PLUS",
  /*    2 */ "MINUS",
  /*    3 */ "DIVIDE",
  /*    4 */ "TIMES",
  /*    5 */ "AMPER",
  /*    6 */ "COMMA",
  /*    7 */ "INTEGER",
  /*    8 */ "IDENTIFIER",
  /*    9 */ "CONSTANT",
  /*   10 */ "FID",
  /*   11 */ "NL",
  /*   12 */ "SEMICOLON",
  /*   13 */ "program",
  /*   14 */ "top_compstmt",
  /*   15 */ "top_stmts",
  /*   16 */ "opt_terms",
  /*   17 */ "none",
  /*   18 */ "top_stmt",
  /*   19 */ "terms",
  /*   20 */ "stmt",
  /*   21 */ "expr",
  /*   22 */ "command_call",
  /*   23 */ "arg",
  /*   24 */ "command",
  /*   25 */ "operation",
  /*   26 */ "command_args",
  /*   27 */ "call_args",
  /*   28 */ "args",
  /*   29 */ "opt_block_arg",
  /*   30 */ "block_arg",
  /*   31 */ "primary",
  /*   32 */ "literal",
  /*   33 */ "numeric",
  /*   34 */ "term",
};
#endif /* defined(YYCOVERAGE) || !defined(NDEBUG) */

#ifndef NDEBUG
/* For tracing reduce actions, the names of all rules are required.
*/
static const char *const yyRuleName[] = {
 /*   0 */ "program ::= top_compstmt",
 /*   1 */ "top_compstmt ::= top_stmts opt_terms",
 /*   2 */ "top_stmts ::= none",
 /*   3 */ "top_stmts ::= top_stmt",
 /*   4 */ "top_stmts ::= top_stmts terms top_stmt",
 /*   5 */ "command ::= operation command_args",
 /*   6 */ "call_args ::= args opt_block_arg",
 /*   7 */ "block_arg ::= AMPER arg",
 /*   8 */ "opt_block_arg ::= COMMA block_arg",
 /*   9 */ "opt_block_arg ::= none",
 /*  10 */ "args ::= arg",
 /*  11 */ "arg ::= arg PLUS arg",
 /*  12 */ "arg ::= arg MINUS arg",
 /*  13 */ "arg ::= arg TIMES arg",
 /*  14 */ "arg ::= arg DIVIDE arg",
 /*  15 */ "numeric ::= INTEGER",
 /*  16 */ "operation ::= IDENTIFIER",
 /*  17 */ "none ::=",
 /*  18 */ "top_stmt ::= stmt",
 /*  19 */ "stmt ::= expr",
 /*  20 */ "expr ::= command_call",
 /*  21 */ "expr ::= arg",
 /*  22 */ "command_call ::= command",
 /*  23 */ "command_args ::= call_args",
 /*  24 */ "arg ::= primary",
 /*  25 */ "primary ::= literal",
 /*  26 */ "literal ::= numeric",
 /*  27 */ "operation ::= CONSTANT",
 /*  28 */ "operation ::= FID",
 /*  29 */ "opt_terms ::=",
 /*  30 */ "opt_terms ::= terms",
 /*  31 */ "terms ::= term",
 /*  32 */ "terms ::= terms term",
 /*  33 */ "term ::= NL",
 /*  34 */ "term ::= SEMICOLON",
};
#endif /* NDEBUG */


#if YYSTACKDEPTH<=0
/*
** Try to increase the size of the parser stack.  Return the number
** of errors.  Return 0 on success.
*/
static int yyGrowStack(yyParser *p){
  int newSize;
  int idx;
  yyStackEntry *pNew;

  newSize = p->yystksz*2 + 100;
  idx = p->yytos ? (int)(p->yytos - p->yystack) : 0;
  if( p->yystack==&p->yystk0 ){
    pNew = malloc(newSize*sizeof(pNew[0]));
    if( pNew ) pNew[0] = p->yystk0;
  }else{
    pNew = realloc(p->yystack, newSize*sizeof(pNew[0]));
  }
  if( pNew ){
    p->yystack = pNew;
    p->yytos = &p->yystack[idx];
#ifndef NDEBUG
    if( yyTraceFILE ){
      fprintf(yyTraceFILE,"%sStack grows from %d to %d entries.\n",
              yyTracePrompt, p->yystksz, newSize);
    }
#endif
    p->yystksz = newSize;
  }
  return pNew==0; 
}
#endif

/* Datatype of the argument to the memory allocated passed as the
** second argument to ParseAlloc() below.  This can be changed by
** putting an appropriate #define in the %include section of the input
** grammar.
*/
#ifndef YYMALLOCARGTYPE
# define YYMALLOCARGTYPE size_t
#endif

/* Initialize a new parser that has already been allocated.
*/
void ParseInit(void *yypRawParser ParseCTX_PDECL){
  yyParser *yypParser = (yyParser*)yypRawParser;
  ParseCTX_STORE
#ifdef YYTRACKMAXSTACKDEPTH
  yypParser->yyhwm = 0;
#endif
#if YYSTACKDEPTH<=0
  yypParser->yytos = NULL;
  yypParser->yystack = NULL;
  yypParser->yystksz = 0;
  if( yyGrowStack(yypParser) ){
    yypParser->yystack = &yypParser->yystk0;
    yypParser->yystksz = 1;
  }
#endif
#ifndef YYNOERRORRECOVERY
  yypParser->yyerrcnt = -1;
#endif
  yypParser->yytos = yypParser->yystack;
  yypParser->yystack[0].stateno = 0;
  yypParser->yystack[0].major = 0;
#if YYSTACKDEPTH>0
  yypParser->yystackEnd = &yypParser->yystack[YYSTACKDEPTH-1];
#endif
}

#ifndef Parse_ENGINEALWAYSONSTACK
/* 
** This function allocates a new parser.
** The only argument is a pointer to a function which works like
** malloc.
**
** Inputs:
** A pointer to the function used to allocate memory.
**
** Outputs:
** A pointer to a parser.  This pointer is used in subsequent calls
** to Parse and ParseFree.
*/
void *ParseAlloc(void *(*mallocProc)(YYMALLOCARGTYPE) ParseCTX_PDECL){
  yyParser *yypParser;
  yypParser = (yyParser*)(*mallocProc)( (YYMALLOCARGTYPE)sizeof(yyParser) );
  if( yypParser ){
    ParseCTX_STORE
    ParseInit(yypParser ParseCTX_PARAM);
  }
  return (void*)yypParser;
}
#endif /* Parse_ENGINEALWAYSONSTACK */


/* The following function deletes the "minor type" or semantic value
** associated with a symbol.  The symbol can be either a terminal
** or nonterminal. "yymajor" is the symbol code, and "yypminor" is
** a pointer to the value to be deleted.  The code used to do the 
** deletions is derived from the %destructor and/or %token_destructor
** directives of the input grammar.
*/
static void yy_destructor(
  yyParser *yypParser,    /* The parser */
  YYCODETYPE yymajor,     /* Type code for object to destroy */
  YYMINORTYPE *yypminor   /* The object to be destroyed */
){
  ParseARG_FETCH
  ParseCTX_FETCH
  switch( yymajor ){
    /* Here is inserted the actions which take place when a
    ** terminal or non-terminal is destroyed.  This can happen
    ** when the symbol is popped from the stack during a
    ** reduce or during error processing or when a parser is 
    ** being destroyed before it is finished parsing.
    **
    ** Note: during a reduce, the only symbols destroyed are those
    ** which appear on the RHS of the rule, but which are *not* used
    ** inside the C code.
    */
/********* Begin destructor definitions ***************************************/
/********* End destructor definitions *****************************************/
    default:  break;   /* If no destructor action specified: do nothing */
  }
}

/*
** Pop the parser's stack once.
**
** If there is a destructor routine associated with the token which
** is popped from the stack, then call it.
*/
static void yy_pop_parser_stack(yyParser *pParser){
  yyStackEntry *yytos;
  assert( pParser->yytos!=0 );
  assert( pParser->yytos > pParser->yystack );
  yytos = pParser->yytos--;
#ifndef NDEBUG
  if( yyTraceFILE ){
    fprintf(yyTraceFILE,"%sPopping %s\n",
      yyTracePrompt,
      yyTokenName[yytos->major]);
  }
#endif
  yy_destructor(pParser, yytos->major, &yytos->minor);
}

/*
** Clear all secondary memory allocations from the parser
*/
void ParseFinalize(void *p){
  yyParser *pParser = (yyParser*)p;
  while( pParser->yytos>pParser->yystack ) yy_pop_parser_stack(pParser);
#if YYSTACKDEPTH<=0
  if( pParser->yystack!=&pParser->yystk0 ) free(pParser->yystack);
#endif
}

#ifndef Parse_ENGINEALWAYSONSTACK
/* 
** Deallocate and destroy a parser.  Destructors are called for
** all stack elements before shutting the parser down.
**
** If the YYPARSEFREENEVERNULL macro exists (for example because it
** is defined in a %include section of the input grammar) then it is
** assumed that the input pointer is never NULL.
*/
void ParseFree(
  void *p,                    /* The parser to be deleted */
  void (*freeProc)(void*)     /* Function used to reclaim memory */
){
#ifndef YYPARSEFREENEVERNULL
  if( p==0 ) return;
#endif
  ParseFinalize(p);
  (*freeProc)(p);
}
#endif /* Parse_ENGINEALWAYSONSTACK */

/*
** Return the peak depth of the stack for a parser.
*/
#ifdef YYTRACKMAXSTACKDEPTH
int ParseStackPeak(void *p){
  yyParser *pParser = (yyParser*)p;
  return pParser->yyhwm;
}
#endif

/* This array of booleans keeps track of the parser statement
** coverage.  The element yycoverage[X][Y] is set when the parser
** is in state X and has a lookahead token Y.  In a well-tested
** systems, every element of this matrix should end up being set.
*/
#if defined(YYCOVERAGE)
static unsigned char yycoverage[YYNSTATE][YYNTOKEN];
#endif

/*
** Write into out a description of every state/lookahead combination that
**
**   (1)  has not been used by the parser, and
**   (2)  is not a syntax error.
**
** Return the number of missed state/lookahead combinations.
*/
#if defined(YYCOVERAGE)
int ParseCoverage(FILE *out){
  int stateno, iLookAhead, i;
  int nMissed = 0;
  for(stateno=0; stateno<YYNSTATE; stateno++){
    i = yy_shift_ofst[stateno];
    for(iLookAhead=0; iLookAhead<YYNTOKEN; iLookAhead++){
      if( yy_lookahead[i+iLookAhead]!=iLookAhead ) continue;
      if( yycoverage[stateno][iLookAhead]==0 ) nMissed++;
      if( out ){
        fprintf(out,"State %d lookahead %s %s\n", stateno,
                yyTokenName[iLookAhead],
                yycoverage[stateno][iLookAhead] ? "ok" : "missed");
      }
    }
  }
  return nMissed;
}
#endif

/*
** Find the appropriate action for a parser given the terminal
** look-ahead token iLookAhead.
*/
static YYACTIONTYPE yy_find_shift_action(
  YYCODETYPE iLookAhead,    /* The look-ahead token */
  YYACTIONTYPE stateno      /* Current state number */
){
  int i;

  if( stateno>YY_MAX_SHIFT ) return stateno;
  assert( stateno <= YY_SHIFT_COUNT );
#if defined(YYCOVERAGE)
  yycoverage[stateno][iLookAhead] = 1;
#endif
  do{
    i = yy_shift_ofst[stateno];
    assert( i>=0 );
    /* assert( i+YYNTOKEN<=(int)YY_NLOOKAHEAD ); */
    assert( iLookAhead!=YYNOCODE );
    assert( iLookAhead < YYNTOKEN );
    i += iLookAhead;
    if( i>=YY_NLOOKAHEAD || yy_lookahead[i]!=iLookAhead ){
#ifdef YYFALLBACK
      YYCODETYPE iFallback;            /* Fallback token */
      if( iLookAhead<sizeof(yyFallback)/sizeof(yyFallback[0])
             && (iFallback = yyFallback[iLookAhead])!=0 ){
#ifndef NDEBUG
        if( yyTraceFILE ){
          fprintf(yyTraceFILE, "%sFALLBACK %s => %s\n",
             yyTracePrompt, yyTokenName[iLookAhead], yyTokenName[iFallback]);
        }
#endif
        assert( yyFallback[iFallback]==0 ); /* Fallback loop must terminate */
        iLookAhead = iFallback;
        continue;
      }
#endif
#ifdef YYWILDCARD
      {
        int j = i - iLookAhead + YYWILDCARD;
        if( 
#if YY_SHIFT_MIN+YYWILDCARD<0
          j>=0 &&
#endif
#if YY_SHIFT_MAX+YYWILDCARD>=YY_ACTTAB_COUNT
          j<YY_ACTTAB_COUNT &&
#endif
          j<(int)(sizeof(yy_lookahead)/sizeof(yy_lookahead[0])) &&
          yy_lookahead[j]==YYWILDCARD && iLookAhead>0
        ){
#ifndef NDEBUG
          if( yyTraceFILE ){
            fprintf(yyTraceFILE, "%sWILDCARD %s => %s\n",
               yyTracePrompt, yyTokenName[iLookAhead],
               yyTokenName[YYWILDCARD]);
          }
#endif /* NDEBUG */
          return yy_action[j];
        }
      }
#endif /* YYWILDCARD */
      return yy_default[stateno];
    }else{
      assert( i>=0 && i<sizeof(yy_action)/sizeof(yy_action[0]) );
      return yy_action[i];
    }
  }while(1);
}

/*
** Find the appropriate action for a parser given the non-terminal
** look-ahead token iLookAhead.
*/
static YYACTIONTYPE yy_find_reduce_action(
  YYACTIONTYPE stateno,     /* Current state number */
  YYCODETYPE iLookAhead     /* The look-ahead token */
){
  int i;
#ifdef YYERRORSYMBOL
  if( stateno>YY_REDUCE_COUNT ){
    return yy_default[stateno];
  }
#else
  assert( stateno<=YY_REDUCE_COUNT );
#endif
  i = yy_reduce_ofst[stateno];
  assert( iLookAhead!=YYNOCODE );
  i += iLookAhead;
#ifdef YYERRORSYMBOL
  if( i<0 || i>=YY_ACTTAB_COUNT || yy_lookahead[i]!=iLookAhead ){
    return yy_default[stateno];
  }
#else
  assert( i>=0 && i<YY_ACTTAB_COUNT );
  assert( yy_lookahead[i]==iLookAhead );
#endif
  return yy_action[i];
}

/*
** The following routine is called if the stack overflows.
*/
static void yyStackOverflow(yyParser *yypParser){
   ParseARG_FETCH
   ParseCTX_FETCH
#ifndef NDEBUG
   if( yyTraceFILE ){
     fprintf(yyTraceFILE,"%sStack Overflow!\n",yyTracePrompt);
   }
#endif
   while( yypParser->yytos>yypParser->yystack ) yy_pop_parser_stack(yypParser);
   /* Here code is inserted which will execute if the parser
   ** stack every overflows */
/******** Begin %stack_overflow code ******************************************/
/******** End %stack_overflow code ********************************************/
   ParseARG_STORE /* Suppress warning about unused %extra_argument var */
   ParseCTX_STORE
}

/*
** Print tracing information for a SHIFT action
*/
#ifndef NDEBUG
static void yyTraceShift(yyParser *yypParser, int yyNewState, const char *zTag){
  if( yyTraceFILE ){
    if( yyNewState<YYNSTATE ){
      fprintf(yyTraceFILE,"%s%s '%s', go to state %d\n",
         yyTracePrompt, zTag, yyTokenName[yypParser->yytos->major],
         yyNewState);
    }else{
      fprintf(yyTraceFILE,"%s%s '%s', pending reduce %d\n",
         yyTracePrompt, zTag, yyTokenName[yypParser->yytos->major],
         yyNewState - YY_MIN_REDUCE);
    }
  }
}
#else
# define yyTraceShift(X,Y,Z)
#endif

/*
** Perform a shift action.
*/
static void yy_shift(
  yyParser *yypParser,          /* The parser to be shifted */
  YYACTIONTYPE yyNewState,      /* The new state to shift in */
  YYCODETYPE yyMajor,           /* The major token to shift in */
  ParseTOKENTYPE yyMinor        /* The minor token to shift in */
){
  yyStackEntry *yytos;
  yypParser->yytos++;
#ifdef YYTRACKMAXSTACKDEPTH
  if( (int)(yypParser->yytos - yypParser->yystack)>yypParser->yyhwm ){
    yypParser->yyhwm++;
    assert( yypParser->yyhwm == (int)(yypParser->yytos - yypParser->yystack) );
  }
#endif
#if YYSTACKDEPTH>0 
  if( yypParser->yytos>yypParser->yystackEnd ){
    yypParser->yytos--;
    yyStackOverflow(yypParser);
    return;
  }
#else
  if( yypParser->yytos>=&yypParser->yystack[yypParser->yystksz] ){
    if( yyGrowStack(yypParser) ){
      yypParser->yytos--;
      yyStackOverflow(yypParser);
      return;
    }
  }
#endif
  if( yyNewState > YY_MAX_SHIFT ){
    yyNewState += YY_MIN_REDUCE - YY_MIN_SHIFTREDUCE;
  }
  yytos = yypParser->yytos;
  yytos->stateno = yyNewState;
  yytos->major = yyMajor;
  yytos->minor.yy0 = yyMinor;
  yyTraceShift(yypParser, yyNewState, "Shift");
}

/* For rule J, yyRuleInfoLhs[J] contains the symbol on the left-hand side
** of that rule */
static const YYCODETYPE yyRuleInfoLhs[] = {
    13,  /* (0) program ::= top_compstmt */
    14,  /* (1) top_compstmt ::= top_stmts opt_terms */
    15,  /* (2) top_stmts ::= none */
    15,  /* (3) top_stmts ::= top_stmt */
    15,  /* (4) top_stmts ::= top_stmts terms top_stmt */
    24,  /* (5) command ::= operation command_args */
    27,  /* (6) call_args ::= args opt_block_arg */
    30,  /* (7) block_arg ::= AMPER arg */
    29,  /* (8) opt_block_arg ::= COMMA block_arg */
    29,  /* (9) opt_block_arg ::= none */
    28,  /* (10) args ::= arg */
    23,  /* (11) arg ::= arg PLUS arg */
    23,  /* (12) arg ::= arg MINUS arg */
    23,  /* (13) arg ::= arg TIMES arg */
    23,  /* (14) arg ::= arg DIVIDE arg */
    33,  /* (15) numeric ::= INTEGER */
    25,  /* (16) operation ::= IDENTIFIER */
    17,  /* (17) none ::= */
    18,  /* (18) top_stmt ::= stmt */
    20,  /* (19) stmt ::= expr */
    21,  /* (20) expr ::= command_call */
    21,  /* (21) expr ::= arg */
    22,  /* (22) command_call ::= command */
    26,  /* (23) command_args ::= call_args */
    23,  /* (24) arg ::= primary */
    31,  /* (25) primary ::= literal */
    32,  /* (26) literal ::= numeric */
    25,  /* (27) operation ::= CONSTANT */
    25,  /* (28) operation ::= FID */
    16,  /* (29) opt_terms ::= */
    16,  /* (30) opt_terms ::= terms */
    19,  /* (31) terms ::= term */
    19,  /* (32) terms ::= terms term */
    34,  /* (33) term ::= NL */
    34,  /* (34) term ::= SEMICOLON */
};

/* For rule J, yyRuleInfoNRhs[J] contains the negative of the number
** of symbols on the right-hand side of that rule. */
static const signed char yyRuleInfoNRhs[] = {
   -1,  /* (0) program ::= top_compstmt */
   -2,  /* (1) top_compstmt ::= top_stmts opt_terms */
   -1,  /* (2) top_stmts ::= none */
   -1,  /* (3) top_stmts ::= top_stmt */
   -3,  /* (4) top_stmts ::= top_stmts terms top_stmt */
   -2,  /* (5) command ::= operation command_args */
   -2,  /* (6) call_args ::= args opt_block_arg */
   -2,  /* (7) block_arg ::= AMPER arg */
   -2,  /* (8) opt_block_arg ::= COMMA block_arg */
   -1,  /* (9) opt_block_arg ::= none */
   -1,  /* (10) args ::= arg */
   -3,  /* (11) arg ::= arg PLUS arg */
   -3,  /* (12) arg ::= arg MINUS arg */
   -3,  /* (13) arg ::= arg TIMES arg */
   -3,  /* (14) arg ::= arg DIVIDE arg */
   -1,  /* (15) numeric ::= INTEGER */
   -1,  /* (16) operation ::= IDENTIFIER */
    0,  /* (17) none ::= */
   -1,  /* (18) top_stmt ::= stmt */
   -1,  /* (19) stmt ::= expr */
   -1,  /* (20) expr ::= command_call */
   -1,  /* (21) expr ::= arg */
   -1,  /* (22) command_call ::= command */
   -1,  /* (23) command_args ::= call_args */
   -1,  /* (24) arg ::= primary */
   -1,  /* (25) primary ::= literal */
   -1,  /* (26) literal ::= numeric */
   -1,  /* (27) operation ::= CONSTANT */
   -1,  /* (28) operation ::= FID */
    0,  /* (29) opt_terms ::= */
   -1,  /* (30) opt_terms ::= terms */
   -1,  /* (31) terms ::= term */
   -2,  /* (32) terms ::= terms term */
   -1,  /* (33) term ::= NL */
   -1,  /* (34) term ::= SEMICOLON */
};

static void yy_accept(yyParser*);  /* Forward Declaration */

/*
** Perform a reduce action and the shift that must immediately
** follow the reduce.
**
** The yyLookahead and yyLookaheadToken parameters provide reduce actions
** access to the lookahead token (if any).  The yyLookahead will be YYNOCODE
** if the lookahead token has already been consumed.  As this procedure is
** only called from one place, optimizing compilers will in-line it, which
** means that the extra parameters have no performance impact.
*/
static YYACTIONTYPE yy_reduce(
  yyParser *yypParser,         /* The parser */
  unsigned int yyruleno,       /* Number of the rule by which to reduce */
  int yyLookahead,             /* Lookahead token, or YYNOCODE if none */
  ParseTOKENTYPE yyLookaheadToken  /* Value of the lookahead token */
  ParseCTX_PDECL                   /* %extra_context */
){
  int yygoto;                     /* The next state */
  YYACTIONTYPE yyact;             /* The next action */
  yyStackEntry *yymsp;            /* The top of the parser's stack */
  int yysize;                     /* Amount to pop the stack */
  ParseARG_FETCH
  (void)yyLookahead;
  (void)yyLookaheadToken;
  yymsp = yypParser->yytos;
#ifndef NDEBUG
  if( yyTraceFILE && yyruleno<(int)(sizeof(yyRuleName)/sizeof(yyRuleName[0])) ){
    yysize = yyRuleInfoNRhs[yyruleno];
    if( yysize ){
      fprintf(yyTraceFILE, "%sReduce %d [%s], go to state %d.\n",
        yyTracePrompt,
        yyruleno, yyRuleName[yyruleno], yymsp[yysize].stateno);
    }else{
      fprintf(yyTraceFILE, "%sReduce %d [%s].\n",
        yyTracePrompt, yyruleno, yyRuleName[yyruleno]);
    }
  }
#endif /* NDEBUG */

  /* Check that the stack is large enough to grow by a single entry
  ** if the RHS of the rule is empty.  This ensures that there is room
  ** enough on the stack to push the LHS value */
  if( yyRuleInfoNRhs[yyruleno]==0 ){
#ifdef YYTRACKMAXSTACKDEPTH
    if( (int)(yypParser->yytos - yypParser->yystack)>yypParser->yyhwm ){
      yypParser->yyhwm++;
      assert( yypParser->yyhwm == (int)(yypParser->yytos - yypParser->yystack));
    }
#endif
#if YYSTACKDEPTH>0 
    if( yypParser->yytos>=yypParser->yystackEnd ){
      yyStackOverflow(yypParser);
      /* The call to yyStackOverflow() above pops the stack until it is
      ** empty, causing the main parser loop to exit.  So the return value
      ** is never used and does not matter. */
      return 0;
    }
#else
    if( yypParser->yytos>=&yypParser->yystack[yypParser->yystksz-1] ){
      if( yyGrowStack(yypParser) ){
        yyStackOverflow(yypParser);
        /* The call to yyStackOverflow() above pops the stack until it is
        ** empty, causing the main parser loop to exit.  So the return value
        ** is never used and does not matter. */
        return 0;
      }
      yymsp = yypParser->yytos;
    }
#endif
  }

  switch( yyruleno ){
  /* Beginning here are the reduction cases.  A typical example
  ** follows:
  **   case 0:
  **  #line <lineno> <grammarfile>
  **     { ... }           // User supplied code
  **  #line <lineno> <thisfile>
  **     break;
  */
/********** Begin reduce actions **********************************************/
        YYMINORTYPE yylhsminor;
      case 0: /* program ::= top_compstmt */
#line 401 "./parse.y"
{
//  if (!p->locals) p->locals = cons(atom_node(":program"),0);
  //if (!p->locals) {node *a = cons(atom_node(":program"),0);}
  root = cons(atom_node(":program"), yymsp[0].minor.yy43); }
#line 1388 "./parse.c"
        break;
      case 1: /* top_compstmt ::= top_stmts opt_terms */
#line 405 "./parse.y"
{ yylhsminor.yy43 = yymsp[-1].minor.yy43; }
#line 1393 "./parse.c"
  yymsp[-1].minor.yy43 = yylhsminor.yy43;
        break;
      case 2: /* top_stmts ::= none */
#line 406 "./parse.y"
{ yymsp[0].minor.yy43 = new_begin(p, 0); }
#line 1399 "./parse.c"
        break;
      case 3: /* top_stmts ::= top_stmt */
#line 407 "./parse.y"
{ yylhsminor.yy43 = new_begin(p, yymsp[0].minor.yy43); }
#line 1404 "./parse.c"
  yymsp[0].minor.yy43 = yylhsminor.yy43;
        break;
      case 4: /* top_stmts ::= top_stmts terms top_stmt */
#line 408 "./parse.y"
{ yylhsminor.yy43 = push(yymsp[-2].minor.yy43, newline_node(yymsp[0].minor.yy43)); }
#line 1410 "./parse.c"
  yymsp[-2].minor.yy43 = yylhsminor.yy43;
        break;
      case 5: /* command ::= operation command_args */
#line 417 "./parse.y"
{ yylhsminor.yy43 = new_fcall(p, yymsp[-1].minor.yy43, yymsp[0].minor.yy43); }
#line 1416 "./parse.c"
  yymsp[-1].minor.yy43 = yylhsminor.yy43;
        break;
      case 6: /* call_args ::= args opt_block_arg */
#line 421 "./parse.y"
{ yylhsminor.yy43 = cons(yymsp[-1].minor.yy43, yymsp[0].minor.yy43); }
#line 1422 "./parse.c"
  yymsp[-1].minor.yy43 = yylhsminor.yy43;
        break;
      case 7: /* block_arg ::= AMPER arg */
#line 423 "./parse.y"
{ yymsp[-1].minor.yy43 = new_block_arg(p, yymsp[0].minor.yy43); }
#line 1428 "./parse.c"
        break;
      case 8: /* opt_block_arg ::= COMMA block_arg */
#line 424 "./parse.y"
{ yymsp[-1].minor.yy43 = yymsp[0].minor.yy43; }
#line 1433 "./parse.c"
        break;
      case 9: /* opt_block_arg ::= none */
#line 425 "./parse.y"
{ yymsp[0].minor.yy43 = 0; }
#line 1438 "./parse.c"
        break;
      case 10: /* args ::= arg */
#line 427 "./parse.y"
{ yylhsminor.yy43 = cons(yymsp[0].minor.yy43, 0); }
#line 1443 "./parse.c"
  yymsp[0].minor.yy43 = yylhsminor.yy43;
        break;
      case 11: /* arg ::= arg PLUS arg */
#line 429 "./parse.y"
{ yylhsminor.yy43 = call_bin_op(yymsp[-2].minor.yy43, PLUS ,yymsp[0].minor.yy43); }
#line 1449 "./parse.c"
  yymsp[-2].minor.yy43 = yylhsminor.yy43;
        break;
      case 12: /* arg ::= arg MINUS arg */
#line 430 "./parse.y"
{ yylhsminor.yy43 = call_bin_op(yymsp[-2].minor.yy43, MINUS, yymsp[0].minor.yy43); }
#line 1455 "./parse.c"
  yymsp[-2].minor.yy43 = yylhsminor.yy43;
        break;
      case 13: /* arg ::= arg TIMES arg */
#line 431 "./parse.y"
{ yylhsminor.yy43 = call_bin_op(yymsp[-2].minor.yy43, TIMES, yymsp[0].minor.yy43); }
#line 1461 "./parse.c"
  yymsp[-2].minor.yy43 = yylhsminor.yy43;
        break;
      case 14: /* arg ::= arg DIVIDE arg */
#line 432 "./parse.y"
{ yylhsminor.yy43 = call_bin_op(yymsp[-2].minor.yy43, DIVIDE, yymsp[0].minor.yy43); }
#line 1467 "./parse.c"
  yymsp[-2].minor.yy43 = yylhsminor.yy43;
        break;
      case 15: /* numeric ::= INTEGER */
#line 436 "./parse.y"
{ yylhsminor.yy43 = new_int(p, yymsp[0].minor.yy0, 10, 0); }
#line 1473 "./parse.c"
  yymsp[0].minor.yy43 = yylhsminor.yy43;
        break;
      case 16: /* operation ::= IDENTIFIER */
#line 438 "./parse.y"
{ yylhsminor.yy43 = list1(atom_node(yymsp[0].minor.yy0)); }
#line 1479 "./parse.c"
  yymsp[0].minor.yy43 = yylhsminor.yy43;
        break;
      case 17: /* none ::= */
#line 449 "./parse.y"
{ yymsp[1].minor.yy43 = 0; }
#line 1485 "./parse.c"
        break;
      default:
      /* (18) top_stmt ::= stmt (OPTIMIZED OUT) */ assert(yyruleno!=18);
      /* (19) stmt ::= expr (OPTIMIZED OUT) */ assert(yyruleno!=19);
      /* (20) expr ::= command_call (OPTIMIZED OUT) */ assert(yyruleno!=20);
      /* (21) expr ::= arg */ yytestcase(yyruleno==21);
      /* (22) command_call ::= command (OPTIMIZED OUT) */ assert(yyruleno!=22);
      /* (23) command_args ::= call_args (OPTIMIZED OUT) */ assert(yyruleno!=23);
      /* (24) arg ::= primary (OPTIMIZED OUT) */ assert(yyruleno!=24);
      /* (25) primary ::= literal (OPTIMIZED OUT) */ assert(yyruleno!=25);
      /* (26) literal ::= numeric (OPTIMIZED OUT) */ assert(yyruleno!=26);
      /* (27) operation ::= CONSTANT */ yytestcase(yyruleno==27);
      /* (28) operation ::= FID */ yytestcase(yyruleno==28);
      /* (29) opt_terms ::= */ yytestcase(yyruleno==29);
      /* (30) opt_terms ::= terms */ yytestcase(yyruleno==30);
      /* (31) terms ::= term (OPTIMIZED OUT) */ assert(yyruleno!=31);
      /* (32) terms ::= terms term */ yytestcase(yyruleno==32);
      /* (33) term ::= NL */ yytestcase(yyruleno==33);
      /* (34) term ::= SEMICOLON */ yytestcase(yyruleno==34);
        break;
/********** End reduce actions ************************************************/
  };
  assert( yyruleno<sizeof(yyRuleInfoLhs)/sizeof(yyRuleInfoLhs[0]) );
  yygoto = yyRuleInfoLhs[yyruleno];
  yysize = yyRuleInfoNRhs[yyruleno];
  yyact = yy_find_reduce_action(yymsp[yysize].stateno,(YYCODETYPE)yygoto);

  /* There are no SHIFTREDUCE actions on nonterminals because the table
  ** generator has simplified them to pure REDUCE actions. */
  assert( !(yyact>YY_MAX_SHIFT && yyact<=YY_MAX_SHIFTREDUCE) );

  /* It is not possible for a REDUCE to be followed by an error */
  assert( yyact!=YY_ERROR_ACTION );

  yymsp += yysize+1;
  yypParser->yytos = yymsp;
  yymsp->stateno = (YYACTIONTYPE)yyact;
  yymsp->major = (YYCODETYPE)yygoto;
  yyTraceShift(yypParser, yyact, "... then shift");
  return yyact;
}

/*
** The following code executes when the parse fails
*/
#ifndef YYNOERRORRECOVERY
static void yy_parse_failed(
  yyParser *yypParser           /* The parser */
){
  ParseARG_FETCH
  ParseCTX_FETCH
#ifndef NDEBUG
  if( yyTraceFILE ){
    fprintf(yyTraceFILE,"%sFail!\n",yyTracePrompt);
  }
#endif
  while( yypParser->yytos>yypParser->yystack ) yy_pop_parser_stack(yypParser);
  /* Here code is inserted which will be executed whenever the
  ** parser fails */
/************ Begin %parse_failure code ***************************************/
#line 394 "./parse.y"
 fprintf(stderr, "Parse failure\n"); exit(1); 
#line 1548 "./parse.c"
/************ End %parse_failure code *****************************************/
  ParseARG_STORE /* Suppress warning about unused %extra_argument variable */
  ParseCTX_STORE
}
#endif /* YYNOERRORRECOVERY */

/*
** The following code executes when a syntax error first occurs.
*/
static void yy_syntax_error(
  yyParser *yypParser,           /* The parser */
  int yymajor,                   /* The major type of the error token */
  ParseTOKENTYPE yyminor         /* The minor type of the error token */
){
  ParseARG_FETCH
  ParseCTX_FETCH
#define TOKEN yyminor
/************ Begin %syntax_error code ****************************************/
#line 393 "./parse.y"
 fprintf(stderr, "Syntax error\n"); exit(1); 
#line 1569 "./parse.c"
/************ End %syntax_error code ******************************************/
  ParseARG_STORE /* Suppress warning about unused %extra_argument variable */
  ParseCTX_STORE
}

/*
** The following is executed when the parser accepts
*/
static void yy_accept(
  yyParser *yypParser           /* The parser */
){
  ParseARG_FETCH
  ParseCTX_FETCH
#ifndef NDEBUG
  if( yyTraceFILE ){
    fprintf(yyTraceFILE,"%sAccept!\n",yyTracePrompt);
  }
#endif
#ifndef YYNOERRORRECOVERY
  yypParser->yyerrcnt = -1;
#endif
  assert( yypParser->yytos==yypParser->yystack );
  /* Here code is inserted which will be executed whenever the
  ** parser accepts */
/*********** Begin %parse_accept code *****************************************/
#line 392 "./parse.y"
 printf("Parse has completed successfully.\n"); 
#line 1597 "./parse.c"
/*********** End %parse_accept code *******************************************/
  ParseARG_STORE /* Suppress warning about unused %extra_argument variable */
  ParseCTX_STORE
}

/* The main parser program.
** The first argument is a pointer to a structure obtained from
** "ParseAlloc" which describes the current state of the parser.
** The second argument is the major token number.  The third is
** the minor token.  The fourth optional argument is whatever the
** user wants (and specified in the grammar) and is available for
** use by the action routines.
**
** Inputs:
** <ul>
** <li> A pointer to the parser (an opaque structure.)
** <li> The major token number.
** <li> The minor token number.
** <li> An option argument of a grammar-specified type.
** </ul>
**
** Outputs:
** None.
*/
void Parse(
  void *yyp,                   /* The parser */
  int yymajor,                 /* The major token code number */
  ParseTOKENTYPE yyminor       /* The value for the token */
  ParseARG_PDECL               /* Optional %extra_argument parameter */
){
  YYMINORTYPE yyminorunion;
  YYACTIONTYPE yyact;   /* The parser action. */
#if !defined(YYERRORSYMBOL) && !defined(YYNOERRORRECOVERY)
  int yyendofinput;     /* True if we are at the end of input */
#endif
#ifdef YYERRORSYMBOL
  int yyerrorhit = 0;   /* True if yymajor has invoked an error */
#endif
  yyParser *yypParser = (yyParser*)yyp;  /* The parser */
  ParseCTX_FETCH
  ParseARG_STORE

  assert( yypParser->yytos!=0 );
#if !defined(YYERRORSYMBOL) && !defined(YYNOERRORRECOVERY)
  yyendofinput = (yymajor==0);
#endif

  yyact = yypParser->yytos->stateno;
#ifndef NDEBUG
  if( yyTraceFILE ){
    if( yyact < YY_MIN_REDUCE ){
      fprintf(yyTraceFILE,"%sInput '%s' in state %d\n",
              yyTracePrompt,yyTokenName[yymajor],yyact);
    }else{
      fprintf(yyTraceFILE,"%sInput '%s' with pending reduce %d\n",
              yyTracePrompt,yyTokenName[yymajor],yyact-YY_MIN_REDUCE);
    }
  }
#endif

  do{
    assert( yyact==yypParser->yytos->stateno );
    yyact = yy_find_shift_action((YYCODETYPE)yymajor,yyact);
    if( yyact >= YY_MIN_REDUCE ){
      yyact = yy_reduce(yypParser,yyact-YY_MIN_REDUCE,yymajor,
                        yyminor ParseCTX_PARAM);
    }else if( yyact <= YY_MAX_SHIFTREDUCE ){
      yy_shift(yypParser,yyact,(YYCODETYPE)yymajor,yyminor);
#ifndef YYNOERRORRECOVERY
      yypParser->yyerrcnt--;
#endif
      break;
    }else if( yyact==YY_ACCEPT_ACTION ){
      yypParser->yytos--;
      yy_accept(yypParser);
      return;
    }else{
      assert( yyact == YY_ERROR_ACTION );
      yyminorunion.yy0 = yyminor;
#ifdef YYERRORSYMBOL
      int yymx;
#endif
#ifndef NDEBUG
      if( yyTraceFILE ){
        fprintf(yyTraceFILE,"%sSyntax Error!\n",yyTracePrompt);
      }
#endif
#ifdef YYERRORSYMBOL
      /* A syntax error has occurred.
      ** The response to an error depends upon whether or not the
      ** grammar defines an error token "ERROR".  
      **
      ** This is what we do if the grammar does define ERROR:
      **
      **  * Call the %syntax_error function.
      **
      **  * Begin popping the stack until we enter a state where
      **    it is legal to shift the error symbol, then shift
      **    the error symbol.
      **
      **  * Set the error count to three.
      **
      **  * Begin accepting and shifting new tokens.  No new error
      **    processing will occur until three tokens have been
      **    shifted successfully.
      **
      */
      if( yypParser->yyerrcnt<0 ){
        yy_syntax_error(yypParser,yymajor,yyminor);
      }
      yymx = yypParser->yytos->major;
      if( yymx==YYERRORSYMBOL || yyerrorhit ){
#ifndef NDEBUG
        if( yyTraceFILE ){
          fprintf(yyTraceFILE,"%sDiscard input token %s\n",
             yyTracePrompt,yyTokenName[yymajor]);
        }
#endif
        yy_destructor(yypParser, (YYCODETYPE)yymajor, &yyminorunion);
        yymajor = YYNOCODE;
      }else{
        while( yypParser->yytos >= yypParser->yystack
            && (yyact = yy_find_reduce_action(
                        yypParser->yytos->stateno,
                        YYERRORSYMBOL)) > YY_MAX_SHIFTREDUCE
        ){
          yy_pop_parser_stack(yypParser);
        }
        if( yypParser->yytos < yypParser->yystack || yymajor==0 ){
          yy_destructor(yypParser,(YYCODETYPE)yymajor,&yyminorunion);
          yy_parse_failed(yypParser);
#ifndef YYNOERRORRECOVERY
          yypParser->yyerrcnt = -1;
#endif
          yymajor = YYNOCODE;
        }else if( yymx!=YYERRORSYMBOL ){
          yy_shift(yypParser,yyact,YYERRORSYMBOL,yyminor);
        }
      }
      yypParser->yyerrcnt = 3;
      yyerrorhit = 1;
      if( yymajor==YYNOCODE ) break;
      yyact = yypParser->yytos->stateno;
#elif defined(YYNOERRORRECOVERY)
      /* If the YYNOERRORRECOVERY macro is defined, then do not attempt to
      ** do any kind of error recovery.  Instead, simply invoke the syntax
      ** error routine and continue going as if nothing had happened.
      **
      ** Applications can set this macro (for example inside %include) if
      ** they intend to abandon the parse upon the first syntax error seen.
      */
      yy_syntax_error(yypParser,yymajor, yyminor);
      yy_destructor(yypParser,(YYCODETYPE)yymajor,&yyminorunion);
      break;
#else  /* YYERRORSYMBOL is not defined */
      /* This is what we do if the grammar does not define ERROR:
      **
      **  * Report an error message, and throw away the input token.
      **
      **  * If the input token is $, then fail the parse.
      **
      ** As before, subsequent error messages are suppressed until
      ** three input tokens have been successfully shifted.
      */
      if( yypParser->yyerrcnt<=0 ){
        yy_syntax_error(yypParser,yymajor, yyminor);
      }
      yypParser->yyerrcnt = 3;
      yy_destructor(yypParser,(YYCODETYPE)yymajor,&yyminorunion);
      if( yyendofinput ){
        yy_parse_failed(yypParser);
#ifndef YYNOERRORRECOVERY
        yypParser->yyerrcnt = -1;
#endif
      }
      break;
#endif
    }
  }while( yypParser->yytos>yypParser->yystack );
#ifndef NDEBUG
  if( yyTraceFILE ){
    yyStackEntry *i;
    char cDiv = '[';
    fprintf(yyTraceFILE,"%sReturn. Stack=",yyTracePrompt);
    for(i=&yypParser->yystack[1]; i<=yypParser->yytos; i++){
      fprintf(yyTraceFILE,"%c%s", cDiv, yyTokenName[i->major]);
      cDiv = ' ';
    }
    fprintf(yyTraceFILE,"]\n");
  }
#endif
  return;
}

/*
** Return the fallback token corresponding to canonical token iToken, or
** 0 if iToken has no fallback.
*/
int ParseFallback(int iToken){
#ifdef YYFALLBACK
  if( iToken<(int)(sizeof(yyFallback)/sizeof(yyFallback[0])) ){
    return yyFallback[iToken];
  }
#else
  (void)iToken;
#endif
  return 0;
}
#line 451 "./parse.y"

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

  void showNode(node *p) {
    if (p == NULL) {
    //  printf("\n");
      return;
    }
    if (p->type == ATOM) {
      printf("atom:%p\n", p);
      printf("  type:%s\n", p->atom.type);
    } else {
      printf("cons:%p\n", p);
      if (p->cons.car != NULL)
        printf("  car:%p\n", p->cons.car);
      if (p->cons.cdr != NULL)
        printf("  cdr:%p\n", p->cons.cdr);
      showNode(p->cons.car);
      showNode(p->cons.cdr);
    }
  }

  void showAllNode(void) {
    showNode(root);
  }
#line 1858 "./parse.c"
