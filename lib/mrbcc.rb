# frozen_string_literal: true

require "mrbcc/version"
require "thor"
require "mrbcc/tokenizer"
require "mrbcc/parser"
require "mrbcc/parser/tree"
require "mrbcc/generator"
require "mrbcc/optimizer"
require "tempfile"

module Mrbcc
  class Error < StandardError; end

  class Main < Thor
    def self.start(given_args = ARGV, config = {})
      args = ["compile"] + given_args
      super(args, config)
    end

    default_command :compile

    desc "compile", "Compile a Ruby script into mruby intermediate byte code"
    def compile(rb_path)
      unless File.exist?(rb_path)
        puts "mrbcc: No program file given"
        exit false
      end
      tokens = tokenize(rb_path)
      parse(tokens)
    end

    desc "version", "Print the version"
    def version
      puts "mrbcc v#{Mrbcc::VERSION}"
    end

  private

    def tokenize(path)
      Tokenizer.init_classvars
      file = File.open(path, "r")
      tokenizer = Tokenizer.new(file)
      while tokenizer.hasMoreTokens?
        tokenizer.advance
      end
    ensure
      file.close
      return tokenizer.tokens
    end

    def parse(tokens)
      File.open(File.expand_path("../../ext/mrbcc/parse.h", __FILE__), "r").each_line do |line|
        if data = line.chomp.match(/\A#define\s+(\w+)\s+(\d+)\z/)
          eval "#{data[1]} = #{data[2]}"
        end
      end
      pointer_to_malloc = Parser.pointerToMalloc
      pointer_to_free = Parser.pointerToFree
      parser = Parser.ParseAlloc(pointer_to_malloc)
      begin
        Parser.Parse(parser, IDENTIFIER, "puts")
        Parser.Parse(parser, STRING_BEG, "")
        Parser.Parse(parser, STRING_MID, "Hello World!")
        Parser.Parse(parser, STRING, "")
 #       Parser.Parse(parser, INTEGER, "1")
 #       Parser.Parse(parser, PLUS, "")
 #       Parser.Parse(parser, INTEGER, "2")
 #       Parser.Parse(parser, TIMES, "")
 #       Parser.Parse(parser, INTEGER, "3")
        #Parser.Parse(parser, PLUS, "")
        #Parser.Parse(parser, INTEGER, "22")
        #Parser.Parse(parser, NL, "")
        #Parser.Parse(parser, INTEGER, "111")
        #Parser.Parse(parser, PLUS, "")
        #Parser.Parse(parser, INTEGER, "222")
        Parser.Parse(parser, 0, "")

        root = Parser.pointerToRoot
        tree = Parser::Tree.new(root)
        tree.show_all_node
        puts
        tree.traverse
        puts
      ensure
        #Parser.showAllNode
        Parser.freeAllNode
        Parser.ParseFree(parser, pointer_to_free)
      end
    end

    def generate
    end

    def optimize
    end
  end

end
