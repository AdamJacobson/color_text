require_relative './named_colors'

module CoreExtensions
  module String
    module Hueby
      include NamedColors

      TEXT_STYLES = {
        "default" =>       0,
        "bold" =>          1,
        "dim" =>           2,
        "italic" =>        3,
        "underline" =>     4,
        "inverse" =>       7,
        "invisible" =>     8,
        "strikethrough" => 9,
      }

      BASE_COLORS = {
        "black" =>          30,
        "red" =>            31,
        "green" =>          32,
        "yellow" =>         33,
        "blue" =>           34,
        "magenta" =>        35,
        "cyan" =>           36,
        "white" =>          37,
        "bright_black" =>   90,
        "bright_red" =>     91,
        "bright_green" =>   92,
        "bright_yellow" =>  93,
        "bright_blue" =>    94,
        "bright_magenta" => 95,
        "bright_cyan" =>    96,
        "bright_white" =>   97,
      }

      BACKGROUND_COLORS = {
        "on_black" =>          40,
        "on_red" =>            41,
        "on_green" =>          42,
        "on_yellow" =>         43,
        "on_blue" =>           44,
        "on_magenta" =>        45,
        "on_cyan" =>           46,
        "on_white" =>          47,
        "on_bright_black" =>   100,
        "on_bright_red" =>     101,
        "on_bright_green" =>   102,
        "on_bright_yellow" =>  103,
        "on_bright_blue" =>    104,
        "on_bright_magenta" => 105,
        "on_bright_cyan" =>    106,
        "on_bright_white" =>   107,
      }

      START_CODE = "\e["
      END_CODE = "\e[0m"

      BACKGROUND = {
        "256_PREFIX" => "48;5",
        "RGB_PREFIX" => "48;2",
        "OFFSET" => 10,
        "VALID_CODES" => BASE_COLORS,
      }

      FOREGROUND = {
        "256_PREFIX" => "38;5",
        "RGB_PREFIX" => "38;2",
        "OFFSET" => 0,
        "VALID_CODES" => BASE_COLORS.merge(TEXT_STYLES),
      }

      def self.included(base)
        base.extend(ClassMethods)

        NAMED_COLORS.each do |name, color|
          define_method(name) do
            self.in(color)
          end
          
          define_method("on_#{name}") do
            self.on(color)
          end
        end

        TEXT_STYLES.each do |style, _|
          define_method(style) do
            self.in(style)
          end
        end

        BASE_COLORS.each do |color, _|
          define_method(color) do
            self.in(color)
          end

          define_method("on_#{color}") do
            self.on(color)
          end
        end
      end

      def in(*args)
        case args.length
        when 0
          raise ArgumentError.new("Requires at least one argument.")
        when 1
          colorize_with_argument(FOREGROUND, args[0])
        else
          args.reduce(self) { |combined, arg| combined = combined.in(arg) }
        end
      end

      def on(*args)
        case args.length
        when 0
          raise ArgumentError.new("Requires at least one argument.")
        when 1
          colorize_with_argument(BACKGROUND, args[0])
        else
          args.reduce(self) { |combined, arg| combined = combined.on(arg) }
        end
      end

      def rainbow(delimiter = "")
        colors = %i[ red green yellow blue magenta cyan ]
        self.split(delimiter).map.with_index { |char, i| char.send(colors[i % colors.length]) }.join(delimiter)
      end

      def pad_to(length)
        remaining = length - self.length
        return self if remaining < 1
        " " * remaining + self
      end

      module ClassMethods
        def define_color(name, color)
          CoreExtensions::String::Hueby::NAMED_COLORS[name.to_s.downcase] = color
          define_method(name) do
            self.in(color)
          end

          define_method("on_#{name}") do
            self.on(color)
          end
        end

        def color_table
          padded_string = proc { |n| n.to_s.pad_to(5) + " " }

          puts (0..7).to_a.map { |i| padded_string[i].on(i) }.join
          puts (8..15).to_a.map { |i| padded_string[i].on(i).in(0) }.join

          puts "\n"

          starts = [
            16, 52, 88, 124, 160, 196,
            22, 58, 94, 130, 166, 202,
            28, 64, 100, 136, 172, 208
          ]

          starts.each.with_index do |s, row|
            x = s

            6.times do
              print padded_string[x].on(x)
              x += 1
            end

            print "   "

            x += 12

            6.times do
              print padded_string[x].on(x).in(0)
              x += 1
            end

            puts "\n"
            puts "\n" if (row + 1) % 6 == 0
          end

          puts (232..243).to_a.map { |i| padded_string[i].on(i) }.join
          puts (244..255).to_a.map { |i| padded_string[i].on(i).in(0) }.join

          print "\n"
        end
      end

      private

      def ansi_code_indices
        matches = self.to_enum(:scan, /\e\[(?:\d+)(?:;\d+)*m/).map { Regexp.last_match }
        codes = matches.select { |md| md[0] != END_CODE }
        codes.map { |code| code.begin(0) + code[0].length - 1 }
      end

      def append_to_existing_ansi_codes(code)
        modified = self
        ansi_code_indices.reverse.each do |index|
          modified = modified[0...index] + ";#{code}" + modified[index..-1]
        end
        modified
      end

      def colorize_with_argument(type, argument)
        case argument
        when nil
          raise ArgumentError.new("Missing argument.")
        when Integer
          ansify(type["256_PREFIX"], argument.to_s)
        when Array
          raise ArgumentError.new("Invalid RGB color code: '#{argument.join(", ")}'") unless argument.length == 3 && argument.all?(Integer)
          ansify(type["RGB_PREFIX"], *argument)
        when ::String, Symbol
          colorize_with_string(type, argument)
        else
          raise ArgumentError.new("Invalid argument: '#{argument.inspect}'")
        end
      end

      def colorize_with_string(type, string_arg)
        normalized = string_arg.to_s.downcase

        named_color = NAMED_COLORS[normalized]
        return colorize_with_argument(type, named_color) if named_color

        from_hex = rgb_255_from_hexidecimal(normalized)
        return colorize_with_argument(type, from_hex) if from_hex

        style = type["VALID_CODES"][normalized]
        if style
          ansify(style + type["OFFSET"])
        else
          raise ArgumentError.new("Unrecognized style: '#{string_arg}'")
        end
      end

      def rgb_255_from_hexidecimal(hex)
        match = hex.match(/^#([a-zA-Z0-9]{6})$/)
        if match
          nums = match[1]
          [
            nums[0..1].to_i(16),
            nums[2..3].to_i(16),
            nums[4..5].to_i(16),
          ]
        else
          nil
        end
      end

      ENCODED_STRING_PATTERN = /^\e\[\d+(?:;\d*)*/

      # Will attempt to add to the existing ANSI code instead of just wrapping the string in another.
      def ansify(*codes)
        code = codes.join(";")

        if self.match(ENCODED_STRING_PATTERN)
          append_to_existing_ansi_codes(code.to_s)
        else
          "#{START_CODE}#{code.to_s}m#{self}#{END_CODE}"
        end
      end
    end
  end
end


