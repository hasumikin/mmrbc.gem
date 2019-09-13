# frozen_string_literal: true

require "mrbcc/parser/node"

module Mrbcc
  module Parser
    class Tree

      def initialize(root)
        @root = make_node(root)
      end

      def make_node(pointer)
        return nil if pointer.nil?
        node = Node.new
        node.car = Parser.hasCar(pointer) ? make_node(Parser.pointerToCar(pointer)) : nil
        node.cdr = Parser.hasCdr(pointer) ? make_node(Parser.pointerToCdr(pointer)) : nil
        node.isAtom = Parser.isAtom(pointer)
        if node.isAtom
          ptr = Parser.pointerToType(pointer)
          if ptr.address > 0
            node.type = ptr.read_string
          end
        end
        return node
      end

      def show_all_node
        show_node(@root, true, 0, false)
      end

      def traverse
        postorder(@root, [], 0)
      end

      private

      def postorder(node, cdrs, depth)
        return if node.nil?
        postorder(node.car, [], 0) unless node.car&.isAtom
        cdrs << node.car.type if node.car&.isAtom
        postorder(node.cdr, cdrs, depth + 1)
        puts cdrs.join(", ") if node.car&.isAtom && depth == 0
      end

      # def postorder(node, cdr_depth)
      #   return if node.nil?
      #   postorder(node.car, 0) unless node.car&.isAtom
      #   postorder(node.cdr, cdr_depth + 1)
      #   puts node.car.type + "(#{cdr_depth})" if node.car&.isAtom
      # end

      def show_node(node, isCar, indent, isRightMost)
        return unless node
        unless node.isAtom
          if isCar
            print "\n"
            print " " * indent
            print "["
          else
            print ", "
          end
          if node.car && node.car.isAtom && node.cdr == nil
            isRightMost = true
          end
        end
        if node.isAtom
          if node.type[0] == ":"
            print node.type
          else
            print '"' + node.type + '"'
          end
          if isRightMost
            print "]"
          end
        else
          show_node(node.car, true, indent+1, isRightMost)
          show_node(node.cdr, false, indent, isRightMost)
        end
      end

    end
  end
end
