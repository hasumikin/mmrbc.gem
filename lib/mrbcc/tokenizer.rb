module Mrbcc
  class Tokenizer
    KEYWORDS = %w(
      BEGIN
      class
      ensure
      nil
      self
      when
      END
      def
      false
      not
      super
      while
      alias
      defined?
      for
      or
      then
      yield
      and
      do
      if
      redo
      true
      __LINE__
      begin
      else
      in
      rescue
      undef
      __FILE__
      break
      elsif
      module
      retry
      unless
      __ENCODING__
      case
      end
      next
      return
      until
    )

    OP_1 = %w(
      !  ~
      >  <
      =
      ? :
    )
    OP_EQ_1 = %w(
      + -
      *  /  %
      &
      |  ^
    )
    OP_EQ_1_2 = OP_EQ_1.map{|e| "#{e}="}
    OP_2 = %w(
      ::
      >=  <=
      ==  !=  =~  !~
      ..
      =>
    )
    OP_EQ_2 = %w(
      **
      << >>
      && ||
    )
    OP_EQ_2_3 = OP_EQ_2.map{|e| "#{e}="}
    OP_3 = %w(
      <=> === ...
    )
    OPERATORS_3 = OP_3 + OP_EQ_2_3
    OPERATORS_2 = OP_EQ_2 + OP_2 + OP_EQ_1_2
    OPERATORS_1 = OP_EQ_1 + OP_1

    PARENS = %w/( ) [ ] { }/
    COMMA = %w(,)
    SEMICOLON = %w(;)

    attr_reader :tokens

    @@tokens = Array.new
    @@line = ""
    @@line_num = 0
    @@pos = 0
    @@paren_stack = Array.new

    def initialize(file, paren = nil)
      @f = file
      @@paren_stack << paren
    end

    def hasMoreTokens?
      !@f.eof? || (!@@line.nil? && !@@line.empty?)
    end

    def read_line
      if @@pos >= @@line.size
        @@line = @f.gets
        @@line_num += 1
        @@pos = 0
      end
    end

    def advance(recursive = nil)
      token = ""
      lazy_token = nil
      read_line
      return nil if @@line.nil?
      if @mode == :comment
        type = @@line.match?(/\A=end(\s|\z)/) ? :on_embdoc_end : :on_embdoc
        @mode = nil
        token = @@line + "\n"
      elsif @mode == :string_double
        while true
          read_line
          return nil if @@line.nil?
          if @@line[@@pos] == ?"
            lazy_token = [
              [@@line_num, @@pos],
              :on_tstring_end,
              ?",
            ]
            @@pos += 1
            @mode = nil
            break
          elsif @@line[@@pos..@@pos+1] == '#{'
            @@tokens << [ [@@line_num, @@pos - token.size], :on_tstring_content, token ]
            token = ""
            c = ""
            @@tokens << [ [@@line_num, @@pos], :on_embexpr_beg, '#{' ]
            @@pos += 2
            tokenizer = Tokenizer.new(@f, :brace)
            while tokenizer.hasMoreTokens?
              ret = tokenizer.advance
              break if ret == :exit
            end
            @@tokens << [ [@@line_num, @@pos], :on_embexpr_end, ?} ]
            @@pos += 1
          elsif @@line[@@pos..@@pos+1] == '\"'
            c = '\"'
          else
            c = @@line[@@pos]
          end
          @@pos += c.size
          token << c
        end
        @@pos -= 1
        type = :on_tstring_content if token.size > 0
      elsif @mode == :string_single
        while true
          read_line
          return nil if @@line == ""
          if @@line[@@pos] == ?'
            lazy_token = [
              [@@line_num, @@pos],
              :on_tstring_end,
              ?',
            ]
            @@pos += 1
            @mode = nil
            break
          elsif @@line[@@pos..@@pos+1] == "\'"
            c = "\'"
          else
            c = @@line[@@pos]
          end
          @@pos += c.size
          token << c
        end
        @@pos -= 1
        type = :on_tstring_content if token.size > 0
      elsif @@line.match?(/\A=begin(\s|\z)/) # multi lines comment
        @mode = :comment
        token = @@line + "\n"
        type = :on_embdoc_beg
      elsif @@line[@@pos] == "\n"
        token = "\n"
        type = :on_ignored_nl
      elsif @@line[@@pos..@@pos+1] == "\r\n"
        token = "\r\n"
        type = :on_ignored_nl
      elsif OPERATORS_3.include?(@@line[@@pos..@@pos+2])
        token = @@line[@@pos..@@pos+2]
        type = :on_op
      elsif OPERATORS_2.include?(@@line[@@pos..@@pos+1])
        token = @@line[@@pos..@@pos+1]
        type = :on_op
      elsif data = @@line[@@pos..].match(/\A(\?.)/)
        token = data[1]
        type = :on_CHAR
      elsif @@line[@@pos..@@pos+1] == "->"
        token = "->"
        type = :on_tlambda
      else
        case @@line[@@pos]
        when ?\
          # ignore
          @@pos += 1
        when ?:
          if @@line[@@pos..@@pos+1].match?(/\A:[A-Za-z0-9_]?/)
            token = ?:
            type = :on_symbeg
          else
            # nothing todo?
          end
        when ?#
          token = @@line[@@pos..]
          type = :on_comment
        when /\s/
          token = @@line[@@pos..].match(/\A(\s+)/)[1]
          type = :on_sp
        when *PARENS
          token = @@line[@@pos]
          type = case token
          when "("; :on_lparen
          when ")"; :on_rparen
          when "["; :on_lbracket
          when "]"; :on_rbracket
          when "{"; :on_lbrace
          when "}"
            if @@paren_stack.last == :brace
              @@paren_stack.pop
              return :exit
            end
            :on_rbrace
          end
        when *OPERATORS_1
          token = @@line[@@pos]
          type = :on_op
        when *SEMICOLON
          token = @@line[@@pos]
          type = :on_semicolon
        when *COMMA
          token = @@line[@@pos]
          type = :on_comma
        when /\d/
          if data = @@line[@@pos..].match(/\A([0-9_]+\.[0-9][0-9_]*)/)
            token = data[1]
            type = :on_float
          elsif data = @@line[@@pos..].match(/\A([0-9_]+)/)
            token = data[1]
            type = :on_int
          else
            raise
          end
        when ?.
          token = "."
          type = :on_period
        when /[A-Za-z_]/
          if data = @@line[@@pos..].match(/\A([A-Za-z0-9_?!]:)/)
            token = data[1]
            type = :on_label
          elsif data = @@line[@@pos..].match(/\A([A-Z]\w*[!?])/)
            token = data[1]
            type = :on_ident
          elsif data = @@line[@@pos..].match(/\A([A-Z]\w*)/)
            token = data[1]
            type = :on_const
          elsif data = @@line[@@pos..].match(/\A(\w+[!?]?)/)
            token = data[1]
            type = :on_ident
          end
        when ?"
          token = ?"
          @mode = :string_double
          type = :on_tstring_beg
        when ?'
          token = ?'
          @mode = :string_single
          type = :on_tstring_beg
        else
          puts "ERROR error"
          sleep 1
        end
      end
      @@pos += token.size unless lazy_token
      if type
        if %i(on_ident on_const).include?(type) && KEYWORDS.include?(token)
          type = :on_kw
        end
        tokens = [ [@@line_num, @@pos - token.size], type, token ]
        @@tokens << tokens
      end
      if lazy_token
        @@tokens << lazy_token
        @@pos += 1
      end
      raise "too deep" if @@tokens.size > 1000
    rescue => e
      puts "\nFailed to tokenize"
      raise e
    end

    def poplastnl
      if %i(on_nl on_ignored_nl).include?(@@tokens.last[1])
        @@tokens.pop
      end
    end

    def close
      @f.close
    end

    def show_tokens
      pp @@tokens
    end
  end
end
