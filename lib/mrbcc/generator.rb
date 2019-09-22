# frozen_string_literal: true

require "mrbcc/generator/crc"
require "mrbcc/generator/scope"
require "mrbcc/generator/opcode"
require "mrbcc/generator/integer_bytes"

module Mrbcc
  class Generator
    using IntegerBytes

    HEADER_SIZE = 22

    def generate(root)
      scope = new_scope(nil)
      codegen(scope, root)
      scope.code.push footer
      code_size = scope.code.flatten.size
      scope.code.unshift "0000".bytes # compiler version
      scope.code.unshift "MATZ".bytes # compiler name
      scope.code.unshift (code_size + HEADER_SIZE).bytes(4) # total size of the binary
      scope.code.unshift crc(scope.code).bytes(2) # CRC
      scope.code.unshift header(scope.code.flatten.size)
      return scope
    end

  private

    def new_scope(prev)
      scope = Scope.new(prev)
      prev.nirep += 1 if prev
      return scope
    end

    def gen_self(scope)
      scope.code.push OP_LOADSELF, scope.sp
      scope.push
    end

    def gen_call(scope, tree)
      nargs = gen_values(scope, tree.cdr.cdr.car) # args_add_block
      nargs.times { scope.pop }
      scope.code.push OP_SEND, scope.sp - nargs, scope.new_sym(tree.cdr.car.cdr.literal_name), nargs
      scope.pop
    end

    def gen_values(scope, tree)
      nargs = 0
      node = tree
      while (node) do
        if node&.cdr&.car&.atom_name == :ATOM_args_add
          nargs += 1
        end
        node = node.cdr&.car
      end
      codegen(scope, tree.cdr.car)
      return nargs
    end

    def gen_str(scope, node)
      scope.code.push OP_STRING, scope.sp, scope.new_lit(node.literal_name)
      scope.push
    end

    def codegen(scope, tree)
      return if tree.nil? || tree.atom?
      case tree.atom_name
      when nil
        codegen(scope, tree.car)
        codegen(scope, tree.cdr)
      when :ATOM_program
        codegen(scope, tree.cdr.car)
        scope.code.push OP_RETURN, scope.sp
        scope.code.push OP_STOP
        scope.finish
      when :ATOM_stmts_add
        codegen(scope, tree.car)
        codegen(scope, tree.cdr)
      when :ATOM_stmts_new # NEW_BEGIN
        return
      when :ATOM_command
        gen_self(scope)
        gen_call(scope, tree)
      when :ATOM_args_add
        codegen(scope, tree.car)
        codegen(scope, tree.cdr)
      when :ATOM_args_new
        return
      when :ATOM_string_literal
        codegen(scope, tree.cdr.car.cdr) # skip the first :string_add
      when :ATOM_string_add
        scope.pop
        scope.pop
        gen_2 OP_STRCAT, scope.sp
        scope.push
      when :ATOM_string_content
        return
      when :ATOM_at_tstring_content
        gen_str(scope, tree.cdr)
      end
    end

    def footer
       "END\0".bytes + # section name
       [0x00, 0x00, 0x00, 0x08] # section size
    end

    def header(code_size)
      "RITE".bytes + # binary ID
      "0006".bytes # binary format version

    end

    def crc(code)
      data = code.flatten.pack("C*")
      memBuf = FFI::MemoryPointer.new(:char, data.bytesize)
      memBuf.put_bytes(0, data)
      return Mrbcc::CRC.calc_crc_16_ccitt(memBuf, data.size, 0)
    end

  end
end
