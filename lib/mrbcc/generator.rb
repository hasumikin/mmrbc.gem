# frozen_string_literal: true

require "mrbcc/crc"

module Mrbcc
  class Generator
    HEADER_SIZE = 22
    IREP_HEADER_SIZE = 26

    def initialize
      @code = Array.new
      @symbol_table = Array.new
      @literal_pool = Array.new
      @symbol_table << "puts"
      @literal_pool << { lit: "Hello World!", type: 0 }
    end

    def save(filename)
      push_irep
      push_footer
      unshift_header
      File.open(filename, "w") do |f|
        f.write @code.flatten.pack("C*")
      end
    end

  private

    def push_irep
      irep = Array.new
      op = 0x10, 0x01, 0x4f, 0x02, 0x00, 0x2e, 0x01, 0x00, 0x01, 0x37, 0x01, 0x67
      irep.push op
      irep.push sprintf("%8x", @literal_pool.size).scan(/../).map{|s| s.to_i(16)}
      irep.push @literal_pool[0][:type]
      irep.push sprintf("%4x", @literal_pool[0][:lit].size).scan(/../).map{|s| s.to_i(16)}
      irep.push @literal_pool[0][:lit].bytes
      irep.push sprintf("%8x", @symbol_table.size).scan(/../).map{|s| s.to_i(16)}
      irep.push sprintf("%4x", @symbol_table[0].size).scan(/../).map{|s| s.to_i(16)}
      irep.push @symbol_table[0].bytes
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
