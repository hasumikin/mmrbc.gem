require "mrbcc/tokenizer/token"
require "mrbcc/tokenizer/token_array"

module Mrbcc
  EXPR_NONE   = 0b0000000000000
  EXPR_BEG    = 0b0000000000001
  EXPR_VALUE  = 0b0000000000001
  EXPR_END    = 0b0000000000010
  EXPR_ENDARG = 0b0000000000100
  EXPR_ENDFN  = 0b0000000001000
  EXPR_END_ANY= 0b0000000001110
  EXPR_ARG    = 0b0000000010000
  EXPR_CMDARG = 0b0000000100000
  EXPR_ARG_ANY= 0b0000000110000
  EXPR_MID    = 0b0000001000000
  EXPR_FNAME  = 0b0000010000000
  EXPR_DOT    = 0b0000100000000
  EXPR_CLASS  = 0b0001000000000
  EXPR_BEG_ANY= 0b0001001000001
  EXPR_LABEL  = 0b0010000000000
  EXPR_LABELED= 0b0100000000000
  EXPR_FITEM  = 0b1000000000000

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

    def self.init_classvars
      @@tokens = TokenArray.new
      @@line = ""
      @@line_num = 0
      @@pos = 0
      @@paren_stack = Array.new
    end

    def tokens
      @@tokens
    end

    def initialize(file, paren = nil)
      @f = file
      @@paren_stack << paren
      @mode = nil
      @mode_terminator = nil
      @state = nil
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
      elsif %i(qwords words qsymbols symbols).include?(@mode)
        while true
          read_line
          token = ""
          type = nil
          if @@line[@@pos] == @mode_terminater
            lazy_token = [
              [@@line_num, @@pos],
              :on_tstring_end,
              @mode_terminater,
              EXPR_END
            ]
            @@pos += 1
            @mode = nil
            break
          elsif [" ", "\n"].include?(@@line[@@pos])
            token = @@line[@@pos..].match(/\A([\s\n]+)/)[1]
            type = :on_words_sep
          else
            i = 0
            while true
              c = @@line[@@pos + i]
              break if c.nil?
              unless ["\s", "\n", @mode_terminator].include?(c)
                token << c
                i += 1
              else
                break
              end
            end
            type = :on_tstring_content
          end
          if token.size > 0
            if type == :on_words_sep && @@tokens.last[1] == :on_words_sep
              @@tokens.last[2] += token
            else
              @@tokens << [
                [@@line_num, @@pos],
                type,
                token,
                EXPR_BEG
              ]
            end
            @@pos += token.size
          end
        end
        @@pos -= 1
      elsif @mode == :tstring_double
        while true
          read_line
          return nil if @@line.nil?
          if @@line[@@pos] == @mode_terminater
            lazy_token = [
              [@@line_num, @@pos],
              :on_tstring_end,
              @mode_terminater,
              EXPR_END
            ]
            @@pos += 1
            @mode = nil
            break
          elsif @@line[@@pos..@@pos+1] == '#{'
            @@tokens << [ [@@line_num, @@pos - token.size], :on_tstring_content, token, EXPR_BEG ]
            token = ""
            c = ""
            @@tokens << [ [@@line_num, @@pos], :on_embexpr_beg, '#{', EXPR_BEG ]
            @@pos += 2
            tokenizer = Tokenizer.new(@f, :brace)
            while tokenizer.hasMoreTokens?
              ret = tokenizer.advance
              break if ret == :exit
            end
            @@tokens << [ [@@line_num, @@pos], :on_embexpr_end, ?}, EXPR_CMDARG ]
            @@pos += 1
          elsif @@line[@@pos..@@pos+1] == '\\' + @mode_terminater
            c = '\\' + @mode_terminater
          else
            c = @@line[@@pos]
          end
          @@pos += c.size
          token << c
        end
        @@pos -= 1
        type = :on_tstring_content if token.size > 0
      elsif @mode == :tstring_single
        while true
          read_line
          return nil if @@line == ""
          if @@line[@@pos] == ?'
            lazy_token = [
              [@@line_num, @@pos],
              :on_tstring_end,
              ?',
              EXPR_END
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
        type = :on_nl
      elsif @@line[@@pos..@@pos+1] == "\r\n"
        token = "\r\n"
        type = :on_nl
      elsif OPERATORS_3.include?(@@line[@@pos..@@pos+2])
        token = @@line[@@pos..@@pos+2]
        type = :on_op
      elsif OPERATORS_2.include?(@@line[@@pos..@@pos+1])
        token = @@line[@@pos..@@pos+1]
        type = :on_op
      elsif data = @@line[@@pos..].match(/\A(@\w+)/)
        token = data[1]
        type = :on_ivar
      elsif data = @@line[@@pos..].match(/\A(\$\w+)/)
        token = data[1]
        type = :on_gvar
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
          when ")"
            @state = EXPR_ENDFN
            :on_rparen
          when "["; :on_lbracket
          when "]"; :on_rbracket
          when "{"
            @state = EXPR_BEG|EXPR_LABEL
            :on_lbrace
          when "}"
            if @@paren_stack.last == :brace
              @@paren_stack.pop
              return :exit
            end
            :on_rbrace
          end
        when *OPERATORS_1
          if data = @@line[@@pos..].match(/\A(%[iIwWq][~!@#$%^&*()_\-=+\[{\]};:'"?])/)
            token = data[1]
            case token[1]
            when "w"
              type = :on_qwords_beg
              @mode = :qwords
            when "W"
              type = :on_words_beg
              @mode = :words
            when "q"
              type = :on_tstring_beg
              @mode = :tstring_single
            when "Q"
              type = :on_tstring_beg
              @mode = :tstring_double
            when "i"
              type = :on_qsymbols_beg
              @mode = :qsymbols
            when "I"
              type = :on_symbols_beg
              @mode = :symbols
            end
            @mode_terminater = case token[2]
            when ?[
              ?]
            when ?{
              ?}
            when ?(
              ?)
            else
              token[2]
            end
          else
            token = @@line[@@pos]
            type = :on_op
          end
        when *SEMICOLON
          token = @@line[@@pos]
          type = :on_semicolon
          @state = EXPR_BEG
        when *COMMA
          token = @@line[@@pos]
          type = :on_comma
          @state = EXPR_BEG|EXPR_LABEL
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
          if data = @@line[@@pos..].match(/\A([A-Za-z0-9_?!]+:)/)
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
          @mode = :tstring_double
          @mode_terminater = ?"
          type = :on_tstring_beg
        when ?'
          token = ?'
          @mode = :tstring_single
          @mode_terminater = ?'
          type = :on_tstring_beg
        else
          puts "ERROR error"
          binding.irb
        end
      end
      @@pos += token.size unless lazy_token
      if type
        if %i(on_ident on_const).include?(type) && KEYWORDS.include?(token)
          type = :on_kw
          @state = case token
          when "class"
            EXPR_CLASS
          when "return", "break", "next", "rescue"
            EXPR_MID
          when "def", "alias", "undef"
            EXPR_FNAME
          end
        else # on_ident
          @state = case @state
          when EXPR_CLASS
            EXPR_ARG
          when EXPR_FNAME
            EXPR_ENDFN
          end
        end
        tokens = [ [@@line_num, @@pos - token.size], type, token, @state ]
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

  end
end
