require 'rspec'
require 'color_text'

def expect_codes(*codes)
  combined_codes = codes.map(&:to_s).join(";")
  expected = ["\e[", combined_codes, "m", text, "\e[0m"].join
  expect(yield).to eq(expected)
end

describe String do
  let(:text) { "TEXT" }

  it 'uses helper method' do
    expect_codes(31) { text.red }
  end

  it 'applies basic colors to text' do
    expect(text.black).to          eq("\e[30mTEXT\e[0m")
    expect(text.red).to            eq("\e[31mTEXT\e[0m")
    expect(text.green).to          eq("\e[32mTEXT\e[0m")
    expect(text.yellow).to         eq("\e[33mTEXT\e[0m")
    expect(text.blue).to           eq("\e[34mTEXT\e[0m")
    expect(text.magenta).to        eq("\e[35mTEXT\e[0m")
    expect(text.cyan).to           eq("\e[36mTEXT\e[0m")
    expect(text.white).to          eq("\e[37mTEXT\e[0m")
    expect(text.bright_black).to   eq("\e[90mTEXT\e[0m")
    expect(text.bright_red).to     eq("\e[91mTEXT\e[0m")
    expect(text.bright_green).to   eq("\e[92mTEXT\e[0m")
    expect(text.bright_yellow).to  eq("\e[93mTEXT\e[0m")
    expect(text.bright_blue).to    eq("\e[94mTEXT\e[0m")
    expect(text.bright_magenta).to eq("\e[95mTEXT\e[0m")
    expect(text.bright_cyan).to    eq("\e[96mTEXT\e[0m")
    expect(text.bright_white).to   eq("\e[97mTEXT\e[0m")
  end

  it 'applies basic background colors to X' do
    expect(text.on_black).to          eq("\e[40mTEXT\e[0m")
    expect(text.on_red).to            eq("\e[41mTEXT\e[0m")
    expect(text.on_green).to          eq("\e[42mTEXT\e[0m")
    expect(text.on_yellow).to         eq("\e[43mTEXT\e[0m")
    expect(text.on_blue).to           eq("\e[44mTEXT\e[0m")
    expect(text.on_magenta).to        eq("\e[45mTEXT\e[0m")
    expect(text.on_cyan).to           eq("\e[46mTEXT\e[0m")
    expect(text.on_white).to          eq("\e[47mTEXT\e[0m")
    expect(text.on_bright_black).to   eq("\e[100mTEXT\e[0m")
    expect(text.on_bright_red).to     eq("\e[101mTEXT\e[0m")
    expect(text.on_bright_green).to   eq("\e[102mTEXT\e[0m")
    expect(text.on_bright_yellow).to  eq("\e[103mTEXT\e[0m")
    expect(text.on_bright_blue).to    eq("\e[104mTEXT\e[0m")
    expect(text.on_bright_magenta).to eq("\e[105mTEXT\e[0m")
    expect(text.on_bright_cyan).to    eq("\e[106mTEXT\e[0m")
    expect(text.on_bright_white).to   eq("\e[107mTEXT\e[0m")
  end

  it 'is chainable and combines base color text with base color backgrounds' do
    expect(text.red.on_white).to        eq("\e[31;47mTEXT\e[0m")
    expect(text.black.on_bright_red).to eq("\e[30;101mTEXT\e[0m")
    expect(text.magenta.on_green).to    eq("\e[35;42mTEXT\e[0m")
  end

  it 'applies text styles' do
    expect(text.bold).to      eq("\e[1mTEXT\e[0m")
    expect(text.underline).to eq("\e[4mTEXT\e[0m")
  end

  describe '#in' do
    it 'can colorize a string with an arbitrary 256 color' do
      expect(text.in(99)).to eq("\e[38;5;99mTEXT\e[0m")
    end

    it 'can colorize a string with an arbirtary RGB code' do
      expect(text.in(99, 15, 187)).to   eq("\e[38;2;99;15;187mTEXT\e[0m")
      expect(text.in(0, 255, 0)).to     eq("\e[38;2;0;255;0mTEXT\e[0m")
      expect(text.in(900, 800, 700)).to eq("\e[38;2;900;800;700mTEXT\e[0m")
    end

    it 'can colorize a string with a named color as symbol or string' do
      expect(text.in(:red)).to           eq("\e[31mTEXT\e[0m")
      expect(text.in("green")).to        eq("\e[32mTEXT\e[0m")
      expect(text.in(:yellow)).to        eq("\e[33mTEXT\e[0m")
      expect(text.in("cyan")).to         eq("\e[36mTEXT\e[0m")
      expect(text.in(:bright_cyan)).to   eq("\e[96mTEXT\e[0m")
      expect(text.in("bright_blue")).to  eq("\e[94mTEXT\e[0m")
    end

    it 'raises error for unrecognized colors' do
      expect{ text.in(:banana) }.to       raise_error(ArgumentError, /banana/)
      expect{ text.in(:bright_flarg) }.to raise_error(ArgumentError, /bright_flarg/)
    end

    it 'recognizes other named colors'
    # Test "orange", "brown", "indigo"

    it 'raises an error with invalid arguments' do
      expect{ text.in(199, 0) }.to raise_error(ArgumentError)
    end
  end

  describe '#on' do
    it 'can colorize a string background with an arbitrary 256 color' do
      expect(text.on(99)).to eq("\e[48;5;99mTEXT\e[0m")
    end

    it 'can colorize a string background with an arbirtary RGB code' do
      expect(text.on(99, 15, 187)).to   eq("\e[48;2;99;15;187mTEXT\e[0m")
      expect(text.on(0, 255, 0)).to     eq("\e[48;2;0;255;0mTEXT\e[0m")
      expect(text.on(900, 800, 700)).to eq("\e[48;2;900;800;700mTEXT\e[0m")
    end

    it 'can colorize a string background with a named color as symbol or string' do
      expect(text.on(:red)).to           eq("\e[41mTEXT\e[0m")
      expect(text.on("green")).to        eq("\e[42mTEXT\e[0m")
      expect(text.on(:yellow)).to        eq("\e[43mTEXT\e[0m")
      expect(text.on("cyan")).to         eq("\e[46mTEXT\e[0m")
      expect(text.on(:bright_cyan)).to   eq("\e[106mTEXT\e[0m")
      expect(text.on("bright_blue")).to  eq("\e[104mTEXT\e[0m")
    end

    it 'raises error for unrecognized colors' do
      expect{ text.on(:banana) }.to       raise_error(ArgumentError, /banana/)
      expect{ text.on(:bright_flarg) }.to raise_error(ArgumentError, /bright_flarg/)
    end

    it 'raises an error with invalid arguments' do
      expect{ text.on(199, 0) }.to raise_error(ArgumentError)
    end
  end

  describe "#default" do
    it "removes any encoding"
  end

  describe "#rainbow" do
    it "colorizes each character" do
      expect(text.rainbow).to match(/(\e\[\d{2}m\w{1}\e\[0m)+/)
    end
  end

  describe '#text_color' do
    it 'can colorize a string with an arbitrary color' do
      expect(text.text_color(99)).to eq("\e[38;5;99mTEXT\e[0m")
    end
  end

  describe '#bg_color' do
    it 'can colorize a string with an arbitrary color' do
      expect(text.bg_color(99)).to eq("\e[48;5;99mTEXT\e[0m")
    end
  end

  describe '#text_color_rgb' do
    it 'can colorize a string with an arbirtary RGB code' do
      expect(text.text_color_rgb(99, 15, 187)).to   eq("\e[38;2;99;15;187mTEXT\e[0m")
      expect(text.text_color_rgb(0, 255, 0)).to     eq("\e[38;2;0;255;0mTEXT\e[0m")
      expect(text.text_color_rgb(900, 800, 700)).to eq("\e[38;2;900;800;700mTEXT\e[0m")
    end
  end

  describe '#bg_color_rgb' do
    it 'can colorize a string with an arbirtary RGB code' do
      expect(text.bg_color_rgb(99, 15, 187)).to   eq("\e[48;2;99;15;187mTEXT\e[0m")
      expect(text.bg_color_rgb(0, 255, 0)).to     eq("\e[48;2;0;255;0mTEXT\e[0m")
      expect(text.bg_color_rgb(900, 800, 700)).to eq("\e[48;2;900;800;700mTEXT\e[0m")
    end

    it 'can be chained' do
      expect(text.bg_color_rgb(99, 15, 187).bold).to eq("\e[48;2;99;15;187;1mTEXT\e[0m")
    end
  end

  describe 'combining effects' do
    it 'combines code additively' do
      string = text.text_color(99).bg_color(127)
      expect(string).to eq("\e[38;5;99;48;5;127mTEXT\e[0m")
    end
  end
end
