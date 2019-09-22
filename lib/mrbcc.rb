# frozen_string_literal: true

require "mrbcc/version"
require "thor"
require "mrbcc/header"
require "mrbcc/tokenizer"
require "mrbcc/parser"
require "mrbcc/parser/tree"
require "mrbcc/generator"
require "tempfile"

module Mrbcc
  class Error < StandardError; end

  class Main < Thor
    def self.start(args = ARGV, config = {})
      unless %w(version help compile).include?(args[0])
        args.unshift "compile"
      end
      super(args, config)
    end

    default_command :compile

    option :verbose, type: :boolean
    option :outfile, aliases: "-o", type: :string
    option :dryrun, type: :boolean
    desc "compile", "Compile a Ruby script into a mruby intermediate byte code"
    def compile(rb_path)
      unless File.exist?(rb_path)
        puts "mrbcc: No program file given"
        exit false
      end
      tokens = tokenize(rb_path, options[:verbose])
      tree = parse(tokens, options[:verbose])
      tree.show_all_node if options[:verbose]
      scope = generate(tree, options[:verbose])
      outfile = options[:outfile] || rb_path.sub(/\.\w+\z/, "") + ".mrb"
      exit if options[:dryrun]
      File.open(outfile, "w") do |f|
        f.write scope.code.flatten.pack("C*")
      end
    end

    desc "version", "Print the version"
    def version
      puts "mrbcc v#{Mrbcc::VERSION}"
    end

  private

    def tokenize(path, verbose = false)
      Tokenizer.init_classvars
      file = File.open(path, "r")
      tokenizer = Tokenizer.new(file)
      while tokenizer.hasMoreTokens?
        tokenizer.advance
      end
    ensure
      file.close
      if verbose
        pp tokenizer.tokens
        puts
      end
      return tokenizer.tokens
    end

    def parse(tokens, verbose)
      pointer_to_malloc = Parser.pointerToMalloc
      pointer_to_free = Parser.pointerToFree
      parser = Parser.ParseAlloc(pointer_to_malloc)
      begin
        tokens.each do |token|
          type = TOKEN_TYPE[token.type]
          next if type == nil
          if type == :on_op
            type = OPERATORS[token.value]
          end
          Parser.Parse(parser, type, token.value)
        end
        Parser.Parse(parser, 0, "")
        Parser.showAllNode(ENV["PARSER_DEBUG"].to_i)
        root = Parser.pointerToRoot
        return Parser::Tree.new(root)
      ensure
        Parser.freeAllNode
        Parser.ParseFree(parser, pointer_to_free)
      end
    end

    def generate(tree, verbose)
      generator = Generator.new
      scope = generator.generate(tree.root)
      return scope
    end

  end

end
