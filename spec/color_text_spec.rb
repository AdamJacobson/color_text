require 'rspec'
require 'color_text'

def expect_codes(*codes)
  combined_codes = codes.map(&:to_s).join(";")
  expected = ["\e[", combined_codes, "m", text, "\e[0m"].join
  expect(yield).to eq(expected)
end

RSpec::Matchers.define(:have_ansi_encoding) do |text, *expected_codes|
  combined_codes = expected_codes.map(&:to_s).join(";")

  expected = ["\e[", combined_codes, "m", text, "\e[0m"].join

  match do |actual|
    actual == expected
  end
end

describe String do
  let(:t) { "TEXT" }

  it 'applies basic colors to text' do
    expect(t.black).to          have_ansi_encoding(t, 30)
    expect(t.red).to            have_ansi_encoding(t, 31)
    expect(t.green).to          have_ansi_encoding(t, 32)
    expect(t.yellow).to         have_ansi_encoding(t, 33)
    expect(t.blue).to           have_ansi_encoding(t, 34)
    expect(t.magenta).to        have_ansi_encoding(t, 35)
    expect(t.cyan).to           have_ansi_encoding(t, 36)
    expect(t.white).to          have_ansi_encoding(t, 37)
    expect(t.bright_black).to   have_ansi_encoding(t, 90)
    expect(t.bright_red).to     have_ansi_encoding(t, 91)
    expect(t.bright_green).to   have_ansi_encoding(t, 92)
    expect(t.bright_yellow).to  have_ansi_encoding(t, 93)
    expect(t.bright_blue).to    have_ansi_encoding(t, 94)
    expect(t.bright_magenta).to have_ansi_encoding(t, 95)
    expect(t.bright_cyan).to    have_ansi_encoding(t, 96)
    expect(t.bright_white).to   have_ansi_encoding(t, 97)
  end

  it 'applies basic background colors to text' do
    expect(t.on_black).to          have_ansi_encoding(t, 40)
    expect(t.on_red).to            have_ansi_encoding(t, 41)
    expect(t.on_green).to          have_ansi_encoding(t, 42)
    expect(t.on_yellow).to         have_ansi_encoding(t, 43)
    expect(t.on_blue).to           have_ansi_encoding(t, 44)
    expect(t.on_magenta).to        have_ansi_encoding(t, 45)
    expect(t.on_cyan).to           have_ansi_encoding(t, 46)
    expect(t.on_white).to          have_ansi_encoding(t, 47)
    expect(t.on_bright_black).to   have_ansi_encoding(t, 100)
    expect(t.on_bright_red).to     have_ansi_encoding(t, 101)
    expect(t.on_bright_green).to   have_ansi_encoding(t, 102)
    expect(t.on_bright_yellow).to  have_ansi_encoding(t, 103)
    expect(t.on_bright_blue).to    have_ansi_encoding(t, 104)
    expect(t.on_bright_magenta).to have_ansi_encoding(t, 105)
    expect(t.on_bright_cyan).to    have_ansi_encoding(t, 106)
    expect(t.on_bright_white).to   have_ansi_encoding(t, 107)
  end

  it 'is chainable and combines base color text with base color backgrounds' do
    expect(t.red.on_white).to        have_ansi_encoding(t, 31, 47)
    expect(t.black.on_bright_red).to have_ansi_encoding(t, 30, 101)
    expect(t.magenta.on_green).to    have_ansi_encoding(t, 35, 42)
  end

  it 'applies text styles' do
    expect(t.bold).to      have_ansi_encoding(t, 1)
    expect(t.underline).to have_ansi_encoding(t, 4)
  end

  describe '#in' do
    it 'can colorize a string with a named color as symbol or string' do
      expect(t.in(:red)).to           have_ansi_encoding(t, 31)
      expect(t.in("green")).to        have_ansi_encoding(t, 32)
      expect(t.in(:yellow)).to        have_ansi_encoding(t, 33)
      expect(t.in("cyan")).to         have_ansi_encoding(t, 36)
      expect(t.in(:bright_cyan)).to   have_ansi_encoding(t, 96)
      expect(t.in("bright_blue")).to  have_ansi_encoding(t, 94)
    end

    it 'can apply styles' do
      expect(t.in(:bold)).to       have_ansi_encoding(t, 1)
      expect(t.in("underline")).to have_ansi_encoding(t, 4)
    end

    it 'accepts multiple distinct basic styles' do
      expect(t.in("red", :bold)).to have_ansi_encoding(t, 31, 1)
    end

    it 'accepts multiple complex styles' do
      expect(t.in("italic", [52, 144, 6])).to have_ansi_encoding(t, 3, 38, 2, 52, 144, 6)
    end

    it 'can colorize a string with an arbitrary 256 color' do
      expect(t.in(99)).to have_ansi_encoding(t, 38, 5, 99)
    end

    it 'can colorize a string with an arbirtary RGB code' do
      expect(t.in([99, 15, 187])).to   have_ansi_encoding(t, 38, 2, 99, 15, 187)
      expect(t.in([0, 255, 0])).to     have_ansi_encoding(t, 38, 2, 0, 255, 0)
      expect(t.in([900, 800, 700])).to have_ansi_encoding(t, 38, 2, 900, 800, 700)
    end

    it 'raises error for unrecognized colors' do
      expect{ t.in(:banana) }.to       raise_error(ArgumentError, /banana/)
      expect{ t.in(:bright_flarg) }.to raise_error(ArgumentError, /bright_flarg/)
    end
    
    it 'recognizes other named colors'
    # Test "orange", "brown", "indigo"

    it 'raises an error with invalid arguments' do
      expect{ t.in }.to raise_error(ArgumentError)
      expect{ t.in(14.8) }.to raise_error(ArgumentError)
    end
  end

  describe '#on' do
    it 'can colorize a string background with an arbitrary 256 color' do
      expect(t.on(99)).to have_ansi_encoding(t, 48, 5, 99)
    end

    it 'can colorize a string background with an arbirtary RGB code' do
      expect(t.on([99, 15, 187])).to   have_ansi_encoding(t, 48, 2, 99, 15, 187)
      expect(t.on([0, 255, 0])).to     have_ansi_encoding(t, 48, 2, 0, 255, 0)
      expect(t.on([900, 800, 700])).to have_ansi_encoding(t, 48, 2, 900, 800, 700)
    end

    it 'can colorize a string background with a named color as symbol or string' do
      expect(t.on(:red)).to           have_ansi_encoding(t, 41)
      expect(t.on("green")).to        have_ansi_encoding(t, 42)
      expect(t.on(:yellow)).to        have_ansi_encoding(t, 43)
      expect(t.on("cyan")).to         have_ansi_encoding(t, 46)
      expect(t.on(:bright_cyan)).to   have_ansi_encoding(t, 106)
      expect(t.on("bright_blue")).to  have_ansi_encoding(t, 104)
    end

    it 'raises error for unrecognized colors' do
      expect{ t.on(:banana) }.to       raise_error(ArgumentError, /banana/)
      expect{ t.on(:bright_flarg) }.to raise_error(ArgumentError, /bright_flarg/)
    end

    it 'raises error for invalid backgrounds' do
      expect{ t.on(:bold) }.to raise_error(ArgumentError)
      expect{ t.on(:italic) }.to raise_error(ArgumentError)
    end

    it 'raises an error with invalid arguments' do
      expect{ t.on }.to raise_error(ArgumentError)
      # expect{ t.on(199, 0) }.to raise_error(ArgumentError)
    end
  end

  describe "#default" do
    it "removes any encoding"
  end

  describe "#rainbow" do
    it "colorizes each character" do
      expect(t.rainbow).to match(/(\e\[\d{2}m\w{1}\e\[0m)+/)
    end
  end

  describe '#text_color' do
    it 'can colorize a string with an arbitrary color' do
      expect(t.text_color(99)).to have_ansi_encoding(t, 38, 5, 99)
    end
  end

  describe '#bg_color' do
    it 'can colorize a string with an arbitrary color' do
      expect(t.bg_color(99)).to have_ansi_encoding(t, 48, 5, 99)
    end
  end

  describe '#text_color_rgb' do
    it 'can colorize a string with an arbirtary RGB code' do
      expect(t.text_color_rgb(99, 15, 187)).to   have_ansi_encoding(t, 38, 2, 99, 15, 187)
      expect(t.text_color_rgb(0, 255, 0)).to     have_ansi_encoding(t, 38, 2, 0, 255, 0)
      expect(t.text_color_rgb(900, 800, 700)).to have_ansi_encoding(t, 38, 2, 900, 800, 700)
    end
  end

  describe '#bg_color_rgb' do
    it 'can colorize a string with an arbirtary RGB code' do
      expect(t.bg_color_rgb(99, 15, 187)).to   have_ansi_encoding(t, 48, 2, 99, 15, 187)
      expect(t.bg_color_rgb(0, 255, 0)).to     have_ansi_encoding(t, 48, 2, 0, 255, 0)
      expect(t.bg_color_rgb(900, 800, 700)).to have_ansi_encoding(t, 48, 2, 900, 800, 700)
    end

    it 'can be chained' do
      expect(t.bg_color_rgb(99, 15, 187).bold).to have_ansi_encoding(t, 48, 2, 99, 15, 187, 1)
    end
  end

  describe 'combining effects' do
    it 'combines code additively' do
      string = t.text_color(99).bg_color(127)
      expect(string).to have_ansi_encoding(t, 38, 5, 99, 48, 5, 127)
    end
  end
end
