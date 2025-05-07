require 'rspec'
require 'hueby'

RSpec::Matchers.define(:have_ansi_encoding) do |text, *expected_codes|
  combined_codes = expected_codes.map(&:to_s).join(";")

  expected = ["\e[", combined_codes, "m", text, "\e[0m"].join

  match do |actual|
    actual == expected
  end
end

String.include CoreExtensions::String::Hueby

describe "Hueby" do
  let(:t) { "TEXT" }

  describe "#colors" do
    it "returns a list of defined colors"
  end

  describe "#define_color" do
    it 'returns true if no methods defined' do
      result = Hueby.define_color("nothing", [0, 0, 0])
      expect(result).to be_truthy
      expect(t).not_to respond_to("nothing")
    end

    it 'can be defined as 256 color' do
      methods = Hueby.define_color("wumbo", [19, 56, 200], create_methods: true)
      expect(methods).to eq([:wumbo, :on_wumbo])
      expect(t.in(:wumbo)).to have_ansi_encoding(t, 38, 2, 19, 56, 200)
      expect(t.wumbo).to      have_ansi_encoding(t, 38, 2, 19, 56, 200)

      expect(t.on("wumbo")).to have_ansi_encoding(t, 48, 2, 19, 56, 200)
      expect(t.on_wumbo).to    have_ansi_encoding(t, 48, 2, 19, 56, 200)
    end

    it 'can define colors as hexidecimal' do
      methods = Hueby.define_color(:hexi, "#90ee90", create_methods: true)
      expect(methods).to eq([:hexi, :on_hexi])
      expect(t.in("hexi")).to have_ansi_encoding(t, 38, 2, 144, 238, 144)
      expect(t.hexi).to       have_ansi_encoding(t, 38, 2, 144, 238, 144)

      expect(t.on(:hexi)).to have_ansi_encoding(t, 48, 2, 144, 238, 144)
      expect(t.on_hexi).to   have_ansi_encoding(t, 48, 2, 144, 238, 144)
    end

    it 'can define colors as short hexidecimal' do
      methods = Hueby.define_color(:short_hexi, "#ABC", create_methods: true)
      expect(methods).to eq([:short_hexi, :on_short_hexi])
      expect(t.in("short_hexi")).to have_ansi_encoding(t, 38, 2, 170, 187, 204)
      expect(t.short_hexi).to       have_ansi_encoding(t, 38, 2, 170, 187, 204)

      expect(t.on(:short_hexi)).to have_ansi_encoding(t, 48, 2, 170, 187, 204)
      expect(t.on_short_hexi).to   have_ansi_encoding(t, 48, 2, 170, 187, 204)
    end

    it 'can be defined as a single digit color' do
      methods = Hueby.define_color(:ninety_nine, 99, create_methods: true)
      expect(methods).to eq([:ninety_nine, :on_ninety_nine])
      expect(t.in("ninety_nine")).to have_ansi_encoding(t, 38, 5, 99)
      expect(t.on(:ninety_nine)).to have_ansi_encoding(t, 48, 5, 99)
    end

    it 'can overwrite existing named colors with new values' do
      Hueby.define_color("idk", 100, create_methods: true)
      Hueby.define_color("idk", 200, create_methods: true)
      expect(t.idk).to have_ansi_encoding(t, 38, 5, 200)
    end

    it 'raises an error when creating color method would overwrite an existing method' do
      expect{ Hueby.define_color("split", 100, create_methods: true) }.to raise_error(StandardError, /cannot define.*split/i)
    end

    it 'raises an error when passed an invalid color' do
      expect{ Hueby.define_color("epsilon", "kinda purple") }.to raise_error
      expect{ Hueby.define_color("delta", [1]) }.to raise_error
    end
  end

  describe 'safe_to_define_color_methods?' do
    it 'returns true if neither method defined' do
      expect(Hueby.safe_to_define_color_methods?("sworple")).to be_truthy
    end

    context 'if either method is defined' do
      it 'returns false' do
        String.define_method("sworple") do; nil; end
        expect(Hueby.safe_to_define_color_methods?("sworple")).to be_falsy
      end

      it 'returns false' do
        String.define_method("on_sworple") do; nil; end
        expect(Hueby.safe_to_define_color_methods?("sworple")).to be_falsy
      end

      context 'and the named color is registered in NAMED_COLORS' do
        it 'returns true' do
          String.define_method("sworple") do; nil; end
          String.define_method("on_sworple") do; nil; end
          CoreExtensions::String::Hueby::NAMED_COLORS["sworple"] = 99

          expect(Hueby.safe_to_define_color_methods?("sworple")).to be_truthy
        end
      end
    end
  end
end

describe String do
  let(:t) { "TEXT" }

  describe "basic terminal defined ANSI styles" do
    it "can be applied to text foreground" do
      expect(t.term_black).to          have_ansi_encoding(t, 30)
      expect(t.term_red).to            have_ansi_encoding(t, 31)
      expect(t.term_green).to          have_ansi_encoding(t, 32)
      expect(t.term_yellow).to         have_ansi_encoding(t, 33)
      expect(t.term_blue).to           have_ansi_encoding(t, 34)
      expect(t.term_magenta).to        have_ansi_encoding(t, 35)
      expect(t.term_cyan).to           have_ansi_encoding(t, 36)
      expect(t.term_white).to          have_ansi_encoding(t, 37)
      expect(t.term_bright_black).to   have_ansi_encoding(t, 90)
      expect(t.term_bright_red).to     have_ansi_encoding(t, 91)
      expect(t.term_bright_green).to   have_ansi_encoding(t, 92)
      expect(t.term_bright_yellow).to  have_ansi_encoding(t, 93)
      expect(t.term_bright_blue).to    have_ansi_encoding(t, 94)
      expect(t.term_bright_magenta).to have_ansi_encoding(t, 95)
      expect(t.term_bright_cyan).to    have_ansi_encoding(t, 96)
      expect(t.term_bright_white).to   have_ansi_encoding(t, 97)
    end

    it "can be applied to text background" do
      expect(t.on_term_black).to          have_ansi_encoding(t, 40)
      expect(t.on_term_red).to            have_ansi_encoding(t, 41)
      expect(t.on_term_green).to          have_ansi_encoding(t, 42)
      expect(t.on_term_yellow).to         have_ansi_encoding(t, 43)
      expect(t.on_term_blue).to           have_ansi_encoding(t, 44)
      expect(t.on_term_magenta).to        have_ansi_encoding(t, 45)
      expect(t.on_term_cyan).to           have_ansi_encoding(t, 46)
      expect(t.on_term_white).to          have_ansi_encoding(t, 47)
      expect(t.on_term_bright_black).to   have_ansi_encoding(t, 100)
      expect(t.on_term_bright_red).to     have_ansi_encoding(t, 101)
      expect(t.on_term_bright_green).to   have_ansi_encoding(t, 102)
      expect(t.on_term_bright_yellow).to  have_ansi_encoding(t, 103)
      expect(t.on_term_bright_blue).to    have_ansi_encoding(t, 104)
      expect(t.on_term_bright_magenta).to have_ansi_encoding(t, 105)
      expect(t.on_term_bright_cyan).to    have_ansi_encoding(t, 106)
      expect(t.on_term_bright_white).to   have_ansi_encoding(t, 107)
    end

    it 'are chainable and combine foreground and background' do
      expect(t.term_red.on_term_white).to        have_ansi_encoding(t, 31, 47)
      expect(t.term_black.on_term_bright_red).to have_ansi_encoding(t, 30, 101)
      expect(t.term_magenta.on_term_green).to    have_ansi_encoding(t, 35, 42)
    end

    it 'applies text styles' do
      expect(t.bold).to      have_ansi_encoding(t, 1)
      expect(t.underline).to have_ansi_encoding(t, 4)
    end
  end

  it "doesn't alter the original string" do
    x = "X"
    x.red
    expect(x).to eq("X")

    red = "X".red
    red.blue
    expect(red).to eq("X".red)
  end

  it 'inteligently adds codes to existing ones when there are more than one' do
    x = "X".red
    y = "Y".blue

    expect((x + y).bold).to eq(x.bold + y.bold)
  end

  it "handles very complex cases" # do
  #   base = ("YELLOW" + "RED".red + "BLUE".blue).yellow
  #   expect(base).to eq("\e[33mYELLOW\e[31;33mRED\e[0m\e[34;33mBLUE\e[0m\e[0m")
  # end

  it "simplifies codes by removing ones that are overridden" # do
  #   expect(t.red.yellow).to eq(t.yellow)
  #   expect(t.bold.red.yellow).to eq(t.bold.yellow)
  # end

  it "simplifies codes by combining codes when possible" # do
  #   expect(t.red + t.red).to eq((t + t).red)
  # end

  it 'recognizes other named colors as foreground or background' do
    expect(t.gold).to       have_ansi_encoding(t, 38, 2, 255, 215, 0)
    expect(t.crimson).to    have_ansi_encoding(t, 38, 2, 220, 20, 60)
    expect(t.on_gold).to    have_ansi_encoding(t, 48, 2, 255, 215, 0)
    expect(t.on_crimson).to have_ansi_encoding(t, 48, 2, 220, 20, 60)
  end

  describe '#in' do
    it 'can colorize a string with a named color as symbol or string' do
      expect(t.in(:term_red)).to      have_ansi_encoding(t, 31)
      expect(t.in("TERM_bright_RED")).to      have_ansi_encoding(t, 91)
      expect(t.in(:term_WHITE)).to      have_ansi_encoding(t, 37)
      expect(t.in("TERM_bright_white")).to      have_ansi_encoding(t, 97)

      expect(t.in(:red)).to           have_ansi_encoding(t, 38, 2, 255, 0, 0)
      expect(t.in("green")).to        have_ansi_encoding(t, 38, 2, 0, 255, 0)
      expect(t.in(:yellow)).to        have_ansi_encoding(t, 38, 2, 255, 255, 0)
      expect(t.in("bLUe")).to         have_ansi_encoding(t, 38, 2, 0, 0, 255)
      expect(t.in(:MaGenTa)).to       have_ansi_encoding(t, 38, 2, 255, 0, 255)
      expect(t.in("cyan")).to         have_ansi_encoding(t, 38, 2, 0, 255, 255)
    end

    it 'can apply styles' do
      expect(t.in(:bold)).to       have_ansi_encoding(t, 1)
      expect(t.in("underline")).to have_ansi_encoding(t, 4)
    end

    it 'accepts multiple distinct basic styles' do
      expect(t.in("term_red", :bold)).to have_ansi_encoding(t, 31, 1)
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

    context 'other named colors' do
      it 'are recognized as string or symbol regardless of case' do
        expect(t.in("orange")).to have_ansi_encoding(t, 38, 2, 255, 165, 0)
        expect(t.in("oRaNgE")).to have_ansi_encoding(t, 38, 2, 255, 165, 0)
        expect(t.in(:orange)).to  have_ansi_encoding(t, 38, 2, 255, 165, 0)
        expect(t.in(:orAnGe)).to  have_ansi_encoding(t, 38, 2, 255, 165, 0)
      end
    end

    it 'accepts hex colors' do
      expect(t.in("#F29C0A")).to have_ansi_encoding(t, 38, 2, 242, 156, 10)
    end

    it 'accepts short hex colors' do
      expect(t.in("#F20")).to have_ansi_encoding(t, 38, 2, 255, 34, 0)
    end

    it 'raises an error with invalid arguments' do
      expect{ t.in }.to            raise_error(ArgumentError)
      expect{ t.in(false) }.to     raise_error(ArgumentError)
      expect{ t.in(14.8) }.to      raise_error(ArgumentError)
      expect{ t.in("F29C0A") }.to  raise_error(ArgumentError)
    end
  end

  describe '#in?' do
    describe 'checks if the text is the given color' do
      it 'returns false if none of the string is'
      it 'returns false only some of the string is'
      it 'returns true only all of the string is'

      it 'for hex codes'
      it 'for RGB arrays'
    end
  end

  describe '#on?' do
    describe 'checks if the text background is the given color' do
      it 'for hex codes'
      it 'for RGB arrays'
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
      expect(t.on(:term_red)).to           have_ansi_encoding(t, 41)
      expect(t.on("term_green")).to        have_ansi_encoding(t, 42)
      expect(t.on(:term_yellow)).to        have_ansi_encoding(t, 43)
      expect(t.on("term_cyan")).to         have_ansi_encoding(t, 46)
      expect(t.on(:term_bright_cyan)).to   have_ansi_encoding(t, 106)
      expect(t.on("term_bright_blue")).to  have_ansi_encoding(t, 104)
    end

    context 'other named colors' do
      it 'are recognized as string or symbol regardless of case' do
        expect(t.on("forestgreen")).to have_ansi_encoding(t, 48, 2, 34, 139, 34)
        expect(t.on("foReSTgrEEn")).to have_ansi_encoding(t, 48, 2, 34, 139, 34)
        expect(t.on(:forestgreen)).to  have_ansi_encoding(t, 48, 2, 34, 139, 34)
        expect(t.on(:fOREstgREen)).to  have_ansi_encoding(t, 48, 2, 34, 139, 34)
      end
    end

    it 'accepts hex colors' do
      expect(t.on("#F20CAA")).to have_ansi_encoding(t, 48, 2, 242, 12, 170)
    end

    it 'accepts short hex colors' do
      expect(t.on("#F20")).to have_ansi_encoding(t, 48, 2, 255, 34, 0)
    end

    it 'raises error for unrecognized colors' do
      expect{ t.on(:banana) }.to       raise_error(ArgumentError, /banana/)
      expect{ t.on(:bright_flarg) }.to raise_error(ArgumentError, /bright_flarg/)
    end

    it 'raises error for invalid backgrounds' do
      expect{ t.on(:bold) }.to   raise_error(ArgumentError)
      expect{ t.on(:italic) }.to raise_error(ArgumentError)
    end

    it 'raises an error with invalid arguments' do
      expect{ t.on }.to raise_error(ArgumentError)
      expect{ t.on(false) }.to raise_error(ArgumentError)
      expect{ t.on(199.8) }.to raise_error(ArgumentError)
    end
  end

  describe "#default" do
    it "removes any encoding"
  end

  describe "#rainbow" do
    it "colorizes each character" do
      expect(t.rainbow).to match(/(\e\[38;2;\d{1,3};\d{1,3};\d{1,3}m\w{1}\e\[0m){4}/)
    end

    it "colorizes each word" do
      input = "LOREM IPSUM DOLOR"
      result = input.rainbow(" ").split(" ")

      expect(result[0]).to have_ansi_encoding("LOREM", 38, 2, 255, 0, 0)
      expect(result[1]).to have_ansi_encoding("IPSUM", 38, 2, 0, 255, 0)
      expect(result[2]).to have_ansi_encoding("DOLOR", 38, 2, 255, 255, 0)
    end

    it "accepts a list of any named colors" do
      input = "LOREM IPSUM DOLOR"
      colors = %i[chocolate gold lightskyblue]
      result = input.rainbow(" ", colors: colors).split(" ")

      expect(result[0]).to have_ansi_encoding("LOREM", 38, 2, 210, 105, 30)
      expect(result[1]).to have_ansi_encoding("IPSUM", 38, 2, 255, 215, 0)
      expect(result[2]).to have_ansi_encoding("DOLOR", 38, 2, 135, 206, 250)
    end
  end

  describe "pad" do
    it "does nothing if 0 or less padding required" do
      expect(t.pad(0)).to eq(t)
    end

    it "uses the given spacer" do
      expect(t.pad(2, spacer: "_")).to eq("__" + t)
      expect(t.pad(2, :right, spacer: "_")).to eq(t + "__")
      expect(t.pad(2, :center, spacer: "_")).to eq("_" + t + "_")
    end

    it "handles complex cases" do
      a = "X".pad(2, :center)
      expect(a).to eq(" X ")

      b = a.pad(2, :center, spacer: "|")
      expect(b).to eq("| X |")

      c = b.pad(4, :center, spacer: "-")
      expect(c).to eq("--| X |--")
    end

    it "adds padding to the left by default" do
      expect(t.pad(1)).to eq(" " + t)
      expect(t.pad(2)).to eq("  " + t)
    end

    it "adds padding to the right when specified" do
      expect(t.pad(1, :right)).to eq(t + " ")
      expect(t.pad(2, :right)).to eq(t + "  ")
    end

    it "adds padding on both sides favoring the left first" do
      expect(t.pad(1, :center)).to eq(" " + t)
      expect(t.pad(2, :center)).to eq(" " + t + " ")
    end

    it "adds padding on both sides favoring the right first" do
      expect(t.pad(1, :center_right)).to eq(t + " ")
      expect(t.pad(2, :center_right)).to eq(" " + t + " ")
    end
  end

  describe "pad_to" do
    it "does nothing if already at given length" do
      padded = t.pad_to(4)
      expect(padded.length).to eq(4)
      expect(padded).to eq(t)
    end

    it "adds as many spaces on the left as needed to reach the given length" do
      padded = t.pad_to(6)
      expect(padded.length).to eq(6)
      expect(padded).to eq("  " + t)
    end

    it "can pad strings on the right" do
      padded = t.pad_to(6, :right)
      expect(padded.length).to eq(6)
      expect(padded).to eq(t + "  ")
    end

    describe "centering with :center" do
      it "pads strings evenly when there is an even number of spaces required" do
        padded = t.pad_to(6, :center)
        expect(padded.length).to eq(6)
        expect(padded).to eq(" " + t + " ")
      end

      it "pads strings favoring the left when odd number of spaces required" do
        padded = t.pad_to(7, :center)
        expect(padded.length).to eq(7)
        expect(padded).to eq("  " + t + " ")
      end
    end

    describe "centering with :center_right" do
      it "pads strings evenly when there is an even number of spaces required" do
        padded = t.pad_to(6, :center_right)
        expect(padded.length).to eq(6)
        expect(padded).to eq(" " + t + " ")
      end

      it "pads strings favoring the right when odd number of spaces required" do
        padded = t.pad_to(7, :center_right)
        expect(padded.length).to eq(7)
        expect(padded).to eq(" " + t + "  ")
      end
    end

    it "can pad strings with a given spacer"
  end

  describe "helper methods" do
    describe "ansi_code_indices" do
      it "returns the ending indicies of all starting codes" do
        expect("R".term_red.send(:ansi_code_indices)).to eq([4])
        expect(("R".term_red + "B".term_blue).send(:ansi_code_indices)).to eq([4, 14])
        expect("IDKLOL".send(:ansi_code_indices)).to eq([])
      end
    end

    describe "append_to_existing_ansi_codes" do
      it "modifies all existing codes" do
        ex = "RED".term_red + "BLUE".term_blue
        expect(ex.send(:append_to_existing_ansi_codes, "99")).to eq("\e[31;99mRED\e[0m\e[34;99mBLUE\e[0m")
      end

      it "changes nothing if no indicies" do
        ex = "RED"
        expect(ex.send(:append_to_existing_ansi_codes, "99")).to eq(ex)
      end
    end
  end
end
