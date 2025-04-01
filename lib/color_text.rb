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
    "256" => "48;5",
    "RGB" => "48;2",
    "OFFSET" => 10,
    "VALID_CODES" => BASE_COLORS,
  }

  FOREGROUND = {
    "256" => "38;5",
    "RGB" => "38;2",
    "OFFSET" => 0,
    "VALID_CODES" => BASE_COLORS.merge(TEXT_STYLES),
  }

  INVALID_ARGUMENTS_ERROR = [
    "Invalid Arguments",
    "Must be one of the following:",
    "\t- Array of 3 integers, 0 to 255, denoting Red, Green and Blue values",
    "\t- Integer, 0 to 255",
    "\t- One color name as a string or symbol",
  ]

  def in(*args)
    raise ArgumentError.new("Missing argument.") if args.length.zero?
    colorize_with_arguments(FOREGROUND, *args)
  end

  def on(*args)
    raise ArgumentError.new("Missing argument.") if args.length.zero?
    colorize_with_arguments(BACKGROUND, *args)
  end

  def text_color_rgb(red, green, blue)
    ansify(FOREGROUND["RGB"], red, green, blue)
  end

  def bg_color_rgb(red, green, blue)
    ansify(BACKGROUND["RGB"], red, green, blue)
  end

  # Set background to an arbitrary color defined by a number of 0 to 255
  def bg_color(color_code)
    ansify(BACKGROUND["256"], color_code.to_s)
  end

  # Set text to an arbitrary color defined by a number of 0 to 255
  def text_color(color_code)
    ansify(FOREGROUND["256"], color_code.to_s)
  end

  def rainbow
    colors = %i[ red green yellow blue magenta cyan ]
    self.chars.map.with_index { |char, i| char.send(colors[i % colors.length]) }.join
  end

  def method_missing(method, *args, &block)
    code = ALL_ANSI_CODES[method.to_s]
    return ansify(code) if code

    super
  end

  private

  def colorize_with_arguments(type, *args)
    if args.length > 1
      return args.reduce(self) { |sum, arg| sum = sum.colorize_with_argument(type, arg) }
    end

    colorize_with_argument(type, args[0])
  end

  def colorize_with_argument(type, argument)
    case argument
    when nil
      raise ArgumentError.new("Missing argument.")
    when Integer
      ansify(type["256"], argument.to_s)
    when Array
      raise ArgumentError.new("Invalid RGB color code: '#{argument.join(", ")}'") unless argument.length == 3 && argument.all?(Integer)
      ansify(type["RGB"], *argument)
    when String, Symbol
      style = type["VALID_CODES"][argument.to_s]
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

    match = self.match(ENCODED_STRING_PATTERN)
    if match
      index = match[0].length
      self.insert(index, ";#{code.to_s}")
    else
      "#{START_CODE}#{code.to_s}m#{self}#{END_CODE}"
    end
  end
end
