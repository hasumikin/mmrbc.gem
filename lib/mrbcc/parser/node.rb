# frozen_string_literal: true

module Mrbcc
  module Parser
    class Node < Struct.new(:car, :cdr, :isAtom, :type)
    end
  end
end
