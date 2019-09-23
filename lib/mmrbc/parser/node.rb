# frozen_string_literal: true

module Mmrbc
  module Parser
    class Node < Struct.new(:kind, :car, :cdr, :atom_type, :literal)
      def cons?
        self.kind == :cons
      end

      def atom?
        self.kind == :atom
      end

      def literal?
        self.kind == :literal
      end

      def atom_name
        return nil unless self.car&.atom?
        ATOM_TYPE[self.car.atom_type]
      end

      def literal_name
        return nil unless self.car&.literal?
        self.car.literal
      end
    end
  end
end
