# frozen_string_literal: true

require "mrbcc/generator/crc"
require "mrbcc/generator/pool"

module Mrbcc
  class Generator
    HEADER_SIZE = 22
    IREP_HEADER_SIZE = 26

    # state
    NONE = 0
    WAIT_SEND = 1

    def initialize
      @pool = Pool.new
      @pool.reset_stmts_index
      @operation_stack = Array.new
      @code = Array.new
    end

    def prepare(tree_root)
      traverse(tree_root, [], 0)
      pp @pool
      pp @operation_stack
    end

    def generate
      push_irep
      push_footer
      unshift_header
      save "../test/mruby/out"
    end

    def save(filename)
      File.open(filename, "w") do |f|
        f.write @code.flatten.pack("C*")
      end
    end

  private

    # postorder
    @wait_send = nil
    def traverse(node, cdrs, depth)
      return if node.nil?
      traverse(node.car, [], 0) unless node.car&.isAtom
      cdrs << node.car.type if node.car&.isAtom
      traverse(node.cdr, cdrs, depth + 1)
      if node.car&.isAtom && depth == 0
        @operation_stack << cdrs
        define_table(cdrs)
      end
    end

    def define_table(cdrs)
      if cdrs.size == 2
        case cdrs[0]
        when ":@tstring_content"
          @pool.define(cdrs[1], :literal, Pool::STRING)
        when ":@ident"
          @pool.define(cdrs[1], :symbol, nil)
        end
      elsif cdrs == [":stmts_new"]
        @pool.stmts_new
      end
    end

    def stmts_new
      @pool.stmts_new
      @nlocals = 1 # starts from 1, I don't know why
      @state = NONE
      @reg = 1
      @wait_send = nil
      @nargs = 0
    end

    def push_irep
      irep = Array.new
      @operation_stack.each do |op|
        case op.size
        when 1
          case op[0]
          when ":stmts_new"
            stmts_new
          when ":command"
            irep.push OP_SEND, @reg, @pool.index_of(@wait_send, :symbol), @nargs
            @wait_send = nil
            @nargs = 0
          end
        when 2
          case op[0]
          when ":@ident"
            if @state == NONE
              @state = WAIT_SEND
              @wait_send = op[1]
            end
          end
        end
      end
      hello = "Hello World!"
      sym = "puts"
      op = 0x10, 0x01, 0x4f, 0x02, 0x00, 0x2e, 0x01, 0x00, 0x01, 0x37, 0x01, 0x67
      irep.push op
      irep.push sprintf("%8x", @pool.count(:literal)).scan(/../).map{|s| s.to_i(16)}
      irep.push @pool.index_of(hello, :literal, Pool::STRING)
      irep.push sprintf("%4x", hello.size).scan(/../).map{|s| s.to_i(16)}
      irep.push hello.bytes
      irep.push sprintf("%8x", @pool.count(:symbol)).scan(/../).map{|s| s.to_i(16)}
      irep.push sprintf("%4x", sym.size).scan(/../).map{|s| s.to_i(16)}
      irep.push sym.bytes
      irep.push 0 # ?
      irep.unshift irep_header(irep.flatten.size, op.size)
      @code.push irep
    end

    def irep_header(size, op_size)
      h = Array.new
      h.push "IREP".bytes # section ID
      h.push sprintf("%8x", size + IREP_HEADER_SIZE).scan(/../).map{|s| s.to_i(16)} # size of the section
      h.push "0002".bytes # instruction version
      h.push 0,0,0,0 # record length
      h.push 0,1     # num LCL
      h.push 0,4     # num REG
      h.push 0,0     # num CHILDREN
      h.push sprintf("%8x", op_size).scan(/../).map{|s| s.to_i(16)}
      return h
    end

    def push_footer
      @code.push "END\0".bytes # section name
      @code.push 0x00, 0x00, 0x00, 0x08 # section size
    end

    def unshift_header
      code_size = @code.flatten.size
      @code.unshift "0000".bytes # compiler version
      @code.unshift "MATZ".bytes # compiler name
      @code.unshift sprintf("%8x", code_size + HEADER_SIZE).scan(/../).map{|s| s.to_i(16)} # total size of the binary
      @code.unshift sprintf("%4x", crc).scan(/../).map{|s| s.to_i(16)} # CRC
      @code.unshift "0006".bytes # binary format version
      @code.unshift "RITE".bytes # binary ID
    end

    def crc
      data = @code.flatten.pack("C*")
      memBuf = FFI::MemoryPointer.new(:char, data.bytesize)
      memBuf.put_bytes(0, data)
      return Mrbcc::CRC.calc_crc_16_ccitt(memBuf, data.size, 0)
    end

  end
end
