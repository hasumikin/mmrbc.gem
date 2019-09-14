# frozen_string_literal: true

module Mrbcc
    class Pool

      STRING = 0
      INTEGER = 1
      FLOAT = 2

      Item = Struct.new(:name, :kind, :type, :index, :stmts_index)

      def initialize
        @symbol_table = Array.new
        @literal_table = Array.new
        reset_stmts_index
      end

      def reset_stmts_index
        @stmts_index = -1
      end

      def stmts_new
        @stmts_index += 1
      end

      def show
        pp @symbol_table
        pp @literal_table
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
        end
      end
    end
end
