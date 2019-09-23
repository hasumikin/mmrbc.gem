# frozen_string_leteral: true

module Mmrbc
  class Token < Struct.new(:location, :type, :value, :state)
    def initialize(location, type, value, state)
      super(location, type, value, state)
    end

    def term?
      !syntax.nil?
    end

    def syntax
      s = if self.type == "integerConstant"
        :integerConstant
      elsif self.type == "stringConstant"
        :stringConstant
      elsif self.type == "keyword" && KEYWORD_CONSTANTS.include?(self.value)
        :keywordConstant
      elsif self.type == "identifier" && %w/( ./.include?(look_ahead(steps + 1).value) # enough?
        :subroutinCall
      elsif self.type == "identifier" # enough?
        :varName
      elsif self.type == "symbol" && self.value == "(" # enough?
        :nested_expression
      elsif self.type == "symbol" &&
            UNARY_OPERATORS.include?(self.value) &&
            term?(steps + 1)
        :unaryOp
      else
        nil
      end
      # puts "#{@position} #{s} #{self}"
      return s
    end
  end
end
