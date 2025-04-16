require 'rspec'
require 'ansi_string_parser'
require 'color_text'

describe AnsiStringParser do
  subject {  }

  describe 'parse' do
    let(:string) { '' }

    it 'parses empty string' do
      expect(AnsiStringParser.new("").parse).to eq([])
    end

    it 'parses unencoded string' do
      expect(AnsiStringParser.new("something").parse).to eq([ "something" ])
    end
  end

  describe 'tokenize' do
    it 'works' do
      expect(AnsiStringParser.new("idk").send(:tokenize)).to eq(["idk"])
    end

    it 'works with encoded strings' do
      expect(AnsiStringParser.new("\e[31mTEXT\e[0m").send(:tokenize)).to eq([[31], "TEXT", [0]])
      expect(AnsiStringParser.new("\e[31;99mTEXT\e[0m").send(:tokenize)).to eq([[31, 99], "TEXT", [0]])
    end

    it 'works with multiple encoded strings combined' do
      string = "RED".red.bold + "BLUE".blue
      expect(AnsiStringParser.new(string).send(:tokenize)).to eq([[31, 1], "RED", [0], [34], "BLUE", [0]])
    end

    it 'handles complex nested cases' do
      string = "\e[33mYELLOW\e[0m\e[31;33mRED\e[0m\e[34;33mBLUE\e[0m"
      # should be the result of ("YELLOW" + "RED".red + "BLUE".blue).yellow once fully working
      expect(AnsiStringParser.new(string).send(:tokenize)).to eq([[33], "YELLOW", [0], [31, 33], "RED", [0], [34, 33], "BLUE", [0]])
    end
  end

  describe 'extract_codes_at' do
    it 'returns the code and end index' do
      expect(AnsiStringParser.new("\e[31mTEXT\e[0m").send(:extract_codes_at, 0)).to eq([[31], 4])
    end

    it 'returns the code and end index' do
      expect(AnsiStringParser.new("\e[31;99mTEXT\e[0m").send(:extract_codes_at, 0)).to eq([[31, 99], 7])
    end
  end
end
