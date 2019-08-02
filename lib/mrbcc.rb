# frozen_string_literal: true

require "mrbcc/version"
require "thor"
require "mrbcc/tokenizer"
require "mrbcc/parser"
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
      pp tokens
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

    def parse
    end

    def generate
    end

    def optimize
    end
  end

end
