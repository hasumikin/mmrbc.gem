require "test_helper"

module Mrbcc
  class PoolTest < Test::Unit::TestCase

    def setup
      @pool = Pool.new
    end

    def test_define
      lit_a = "abcdef"
      lit_b = "abcdefg"
      assert_equal 0, @pool.count(:literal)
      @pool.define(lit_a, :literal)
      assert_equal 1, @pool.count(:literal)
      @pool.define(lit_b, :literal)
      assert_equal 2, @pool.count(:literal)
      @pool.define(lit_a, :literal)
      assert_equal 2, @pool.count(:literal)
    end

  end
end
