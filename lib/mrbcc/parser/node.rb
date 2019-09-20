# frozen_string_literal: true

module Mrbcc
  module Parser
    class Node < Struct.new(:car, :cdr, :isAtom, :type)
      def atom
        if car.isAtom
          car.type
        else
          nil
        end
      end
    end
  end
end
