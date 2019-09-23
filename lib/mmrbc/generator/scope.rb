# frozen_string_literal: true

require "mmrbc/generator/integer_bytes"

module Mmrbc
  class Scope < Struct.new(:prev, :code, :nlocals, :nirep, :symbols, :literals, :sp, :max_sp)

    using IntegerBytes

    Literal = Struct.new(:value, :type)
    STRING = 0
    INTEGER = 1
    FLOAT = 2

    IREP_HEADER_SIZE = 26

    def initialize(prev, code = [], nlocals = 1, nirep = 0, symbols = [], literals = [], sp = 1, max_sp = 1)
      super(prev, code, nlocals, nirep, symbols, literals, sp, max_sp)
    end

    def new_lit(lit)
      index = self.literals.find_index{|l| l.value == lit}
      return index if index
      self.literals << Literal.new(lit, STRING)
      return self.literals.size - 1
    end

    def new_sym(sym)
      index = self.symbols.find_index(sym)
      return index if index
      self.symbols << sym
      return self.symbols.size - 1
    end

    def push
      self.sp += 1
      self.max_sp = self.sp if self.max_sp < self.sp
    end

    def pop
      self.sp -= 1
    end

    def finish
      op_size = self.code.flatten.size
      # literal
      self.code.push self.literals.size.bytes(4)
      self.literals.each do |lit|
        self.code.push lit.type
        self.code.push lit.value.size.bytes(2)
        self.code.push lit.value.bytes
      end
      # symbol
      self.code.push self.symbols.size.bytes(4)
      self.symbols.each do |sym|
        self.code.push sym.size.bytes(2)
        self.code.push sym.bytes
        self.code.push 0 # NULL終端？
      end
      # header
      h = Array.new
      h.push "IREP".bytes # section ID
      h.push (self.code.flatten.size + IREP_HEADER_SIZE).bytes(4) # size of the section
      h.push "0002".bytes # instruction version
      h.push 0,0,0,0 # record length. but what ever it works because of mruby VM bug
      h.push self.nlocals.bytes(2)
      h.push self.max_sp.bytes(2)
      h.push self.nirep.bytes(2)
      h.push op_size.bytes(4)
      self.code.unshift h
    end

    def show
    end

    def define(name, kind, type = STRING)
      unless find_item(name, kind, type)
        table = select_table(kind)
        table << Item.new(name, kind, type, count(kind), @stmts_index)
      end
    end

    def count(kind)
      table = select_table(kind)
      table.count {|i| i.stmts_index = @stmts_index}
    end

    def index_of(name, kind, type = STRING)
      find_item(name, kind, type).index
    end

  private

    def find_item(name, kind, type = STRING)
      table = select_table(kind)
      table.find do |item|
        item.name == name &&
          item.stmts_index == @stmts_index &&
          item.type = type
      end
    end

    def select_table(kind)
      case kind
      when :symbol
        @symbol_table
      when :literal
        @literal_table
      when :local
        @local_table
      end
    end
  end
end
