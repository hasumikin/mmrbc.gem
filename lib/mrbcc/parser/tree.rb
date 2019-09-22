# frozen_string_literal: true

require "mrbcc/parser/node"

module Mrbcc
  module Parser
    class Tree

      attr_reader :root

      def initialize(root)
        @root = make_node(root)
      end

      def make_node(pointer)
        return nil if pointer.nil?
        node = Node.new
        node.car = Parser.hasCar(pointer) ? make_node(Parser.pointerToCar(pointer)) : nil
        node.cdr = Parser.hasCdr(pointer) ? make_node(Parser.pointerToCdr(pointer)) : nil
        node.kind = case Parser.kind(pointer)
        when 'a'
          :atom
        when 'l'
          :literal
        when 'c'
          :cons
        end
        node.atom_type = Parser.atom_type(pointer)
        if node.literal?
          ptr = Parser.pointerToLiteral(pointer)
          if ptr.address > 0
            node.literal = ptr.read_string
          end
        end
        return node
      end

      def show_all_node
        show_node(@root, true, 0, false)
        puts
      end

      private

      def show_node(node, isCar, indent, isRightMost)
        return unless node
        if node.cons?
          if isCar
            print "\n"
            print " " * indent
            print "["
          else
            print ", "
          end
          if node.car && !node.car.cons? && node.cdr == nil
            isRightMost = true
          end
        elsif node.atom?
          print ATOM_TYPE[node.atom_type].to_s.sub("ATOM_", ":").sub(/\A:at_/, ":@")
          if isRightMost
            print "]"
          end
        elsif node.literal?
          print '"' + node.literal + '"'
          if isRightMost
            print "]"
          end
        end
        if node.cons?
          show_node(node.car, true, indent+1, isRightMost)
          show_node(node.cdr, false, indent, isRightMost)
        end
      end

    end
  end
end
