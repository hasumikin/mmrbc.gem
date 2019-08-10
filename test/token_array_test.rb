require "test_helper"

module Mrbcc
  class TokenArrayTest < Test::Unit::TestCase

    def setup
      @tokens = TokenArray.new
      @tokens << [[1, 0], :on_int, "1", EXPR_END]
      @tokens << [[1, 1], :on_op, "+", EXPR_BEG]
      @tokens << [[1, 2], :on_int, "2", EXPR_END]
    end

    def test_fetch
      token = @tokens.fetch
      assert_equal [[1, 0], :on_int, "1", EXPR_END], token.to_a
      token = @tokens.fetch
      assert_equal [[1, 1], :on_op, "+", EXPR_BEG], token.to_a
    end

    def test_look_ahead
      token = @tokens.fetch
      assert_equal [[1, 1], :on_op, "+", EXPR_BEG], @tokens.look_ahead.to_a
      assert_equal [[1, 2], :on_int, "2", EXPR_END], @tokens.look_ahead(2).to_a
    end
  end
end
