require "test_helper"
require "ripper"

class TokenizerTest < Test::Unit::TestCase

  def test_hello
    execute "hello*"
  end

  def test_operator
    execute "operator*"
  end

  def test_array
    execute "array*"
  end

  def test_case
    execute "case*"
  end

  def test_class
    execute "class*"
  end

  def test_co2
    execute "co2*"
  end

  def test_hash
    execute "hash*"
  end

  def test_led
    execute "led*"
  end

  def test_method
    execute "method*"
  end

  def test_primary
    execute "primary*"
  end

  def test_secondary
    execute "secondary*"
  end

  def test_qwords
    execute "*qwords"
  end

  def test_space_semicolon
    execute "space*"
  end

  def test_thermistor
    execute "thermistor*"
  end

  def test_while
    execute "while*"
  end

  def test_wifi
    execute "wifi*"
  end

  def test_interpolation
    execute "interpolation*"
  end

  private

  def execute(name)
    Dir.glob("test/fixtures/#{name}.rb").shuffle.each do |f|
      main = Mmrbc::Main.new
      tokens = main.send(:tokenize, f)
      Ripper.lex(File.read(f)).each_with_index do |line, i|
        line.pop
        line[1] = :on_nl if line[1] == :on_ignored_nl
        assert_equal line, tokens[i].to_a[0..2]
      end
    end
  end

end
