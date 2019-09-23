# frozen_string_literal: true

require "ffi"

module Mmrbc
  module Parser
    extend FFI::Library
    ffi_lib File.expand_path("../../../ext/mmrbc/libparse.so", __FILE__)

    attach_function :pointerToMalloc, [], :pointer
    attach_function :pointerToFree, [], :pointer
    attach_function :showAllNode, [:int], :void
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

    attach_function :pointerToRoot, [], :pointer
    attach_function :kind, [:pointer], :string
    attach_function :atom_type, [:pointer], :int
    attach_function :hasCar, [:pointer], :bool
    attach_function :hasCdr, [:pointer], :bool
    attach_function :pointerToLiteral, [:pointer], :pointer
    attach_function :pointerToCar, [:pointer], :pointer
    attach_function :pointerToCdr, [:pointer], :pointer
  end
end
