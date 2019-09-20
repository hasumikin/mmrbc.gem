
module Mrbcc
  File.open(File.expand_path("../../../ext/mrbcc/parse.h", __FILE__), "r").each_line do |line|
    if data = line.chomp.match(/\A#define\s+(\w+)\s+(\d+)\z/)
      eval "#{data[1]} = #{data[2]}"
    end
  end

  TOKEN_TYPE = {
    on_ident: IDENTIFIER,
    on_tstring_beg: STRING_BEG,
    on_tstring_end: STRING,
    on_tstring_content: STRING_MID,
    on_int: INTEGER,
    on_comma: COMMA,
    on_nl: NL,
    on_sp: nil, # FIXME
    on_op: :on_op
  }

  OPERATORS = {
    "+" => PLUS,
    "-" => MINUS,
    "*" => TIMES,
    "/" => DIVIDE,
  }
end
