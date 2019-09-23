# frozen_string_leteral: true

module Mmrbc

  class TokenArray < Array
    def initialize
      @position = -1
      @call_stack = []
    end

    def <<(ary)
      self.push Token.new(ary[0], ary[1], ary[2], ary[3])
    end

    def fetch
      @call_stack << {
        caller: caller_locations(1, 1),
        location: @position,
        current: look_ahead
      }
      @position += 1
      check_infinite_loop
      self[@position]
    end

    def check_infinite_loop
      return if @call_stack[-1].nil? || @call_stack[-2].nil?
      if @call_stack[-1][:location] == @call_stack[-2][:location]
        raise "InfiniteLoopError!"
      end
    end

    def current
      look_ahead(0)
    end

    def look_ahead(steps = 1)
      self[@position + steps]
    end

  end
end
