# frozen_string_literal: true

module Mrbcc
  class Parser
    def initialize(tokens)
      @tokens = tokens
    end

    def reduce_program(e)
      e.programm do |f|
        f
      end
    end
  end
end

