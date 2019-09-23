require "test_helper"

module Mmrbc
  class ScopeTest < Test::Unit::TestCase

    def setup
      @scope = Scope.new(nil)
    end

    def test_new_sym
      sym_a = "abcdef"
      sym_b = "abcdefg"
      assert_equal 0, @scope.new_sym(sym_a)
      assert_equal 1, @scope.new_sym(sym_b)
      assert_equal 0, @scope.new_sym(sym_a)
    end

    def test_new_lit
      lit_a = "abcdef"
      lit_b = "abcdefg"
      assert_equal 0, @scope.new_lit(lit_a)
      assert_equal 1, @scope.new_lit(lit_b)
      assert_equal 0, @scope.new_lit(lit_a)
    end

  end
end
