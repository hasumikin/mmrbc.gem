# frozen_string_literal: true

require "ffi"

module Mrbcc
  module Parser
    extend FFI::Library
    ffi_lib File.expand_path("../../../ext/mrbcc/libparse.so", __FILE__)

    attach_function :pointerToMalloc, [], :pointer
    attach_function :pointerToFree, [], :pointer
    attach_function :showAllNode, [], :void
    attach_function :freeAllNode, [], :void

    # void *ParseAlloc(
    #   void *(*mallocProc)(YYMALLOCARGTYPE) ParseCTX_PDECL
    # ){
    attach_function :ParseAlloc, [:pointer], :pointer

    # void ParseFree(
    #   void *p,                    /* The parser to be deleted */
    #   void (*freeProc)(void*)     /* Function used to reclaim memory */
    # ){
    attach_function :ParseFree, [:pointer, :pointer], :void

    # void Parse(
    #   void *yyp,                   /* The parser */
    #   int yymajor,                 /* The major token code number */
    #   ParseTOKENTYPE yyminor       /* The value for the token */
    #   ParseARG_PDECL               /* Optional %extra_argument parameter */
    # ){
    attach_function :Parse, [:pointer, :int, :string], :void
  end
end
