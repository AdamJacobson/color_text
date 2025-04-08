class String
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

  ALL_ANSI_CODES = BACKGROUND_COLORS.merge(TEXT_STYLES).merge(BASE_COLORS)

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

  def method_missing(method, *args, &block)
    code = ALL_ANSI_CODES[method.to_s.downcase]
    return ansify(code) if code

    super
  end

  def self.color_table
    puts (0..7).to_a.map { |i| "  #{i} ".on(i) }.join
    puts (8..15).to_a.map { |i| "  #{i} ".on(i) }.join

    (16..231).each_slice(30) do |slice|
      # puts slice.map { |i| "  #{i} ".on(i) }.join
      puts slice.map { |i| (i.to_s.pad_to(5) + " ").on(i) }.join
    end

    print "\n"
    nil
  end

  def pad_to(length)
    remaining = length - self.length
    return self if remaining < 1
    " " * remaining + self
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
    when String, Symbol
      style = type["VALID_CODES"][argument.to_s.downcase]
      if style
        ansify((style) + type["OFFSET"])
      else
        raise ArgumentError.new("Unrecognized style: '#{argument}'")
      end
    else
      raise ArgumentError.new("Invalid argument: '#{argument}'")
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
