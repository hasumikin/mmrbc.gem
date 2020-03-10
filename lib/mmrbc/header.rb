
module Mmrbc
  File.open(File.expand_path("../../../ext/ruby-lemon-parse/parse.h", __FILE__), "r").each_line do |line|
    if data = line.chomp.match(/\A#define\s+(\w+)\s+(\d+)\z/)
      eval "#{data[1]} = #{data[2]}"
    end
  end

  atom_index = 1
  ATOM_TYPE = Array.new
  File.open(File.expand_path("../../../ext/ruby-lemon-parse/atom_type.h", __FILE__), "r").each_line do |line|
    if data = line.match(/(ATOM_\w+)/)
      eval "ATOM_TYPE[#{atom_index}] = :#{data[1]}"
      atom_index += 1
    end
  end

  TOKEN_TYPE = {
    on_ident: IDENTIFIER,
    on_tstring_beg: STRING_BEG,
    on_tstring_end: STRING_END,
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
