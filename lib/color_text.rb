class String
  BASE_COLORS = {
    black:          30,
    red:            31,
    green:          32,
    yellow:         33,
    blue:           34,
    magenta:        35,
    cyan:           36,
    white:          37,
    bright_black:   90,
    bright_red:     91,
    bright_green:   92,
    bright_yellow:  93,
    bright_blue:    94,
    bright_magenta: 95,
    bright_cyan:    96,
    bright_white:   97,
  }

  ANSI_CODES = {
    default:           0,
    bold:              1,
    dim:               2,
    italic:            3,
    underline:         4,
    inverse:           7,
    invisible:         8,
    strikethrough:     9,
    on_black:          40,
    on_red:            41,
    on_green:          42,
    on_yellow:         43,
    on_blue:           44,
    on_magenta:        45,
    on_cyan:           46,
    on_white:          47,
    on_bright_black:   100,
    on_bright_red:     101,
    on_bright_green:   102,
    on_bright_yellow:  103,
    on_bright_blue:    104,
    on_bright_magenta: 105,
    on_bright_cyan:    106,
    on_bright_white:   107,
  }.merge(BASE_COLORS)

  BACKGROUND_OFFSET = 10

  START_CODE = "\e["
  END_CODE = "\e[0m"
  BACKGROUND_256 = "48;5"
  FOREGROUND_256 = "38;5"
  BACKGROUND_RGB = "48;2"
  FOREGROUND_RGB = "38;2"
  INVALID_ARGUMENTS_ERROR = [
    "Invalid Arguments",
    "Must be one of the following:",
    "\t- 3 integers, 0 to 255, denoting Red, Green and Blue values",
    "\t- 1 integer, 0 to 255",
    "\t- One color name as a string or symbol"
  ]

  # Accepts arguments in the following forms:
  # named colors: "".in(:red), "".in("bright_green")
  # RGB: "".in(37, 19, 128)
  # 256: "".in(99)
  def in(*args)
    if args.length == 3 && args.all?(Integer)
      ansify(FOREGROUND_RGB, *args)
    elsif args.length == 1
      case args[0]
      when Integer
        ansify(FOREGROUND_256, args[0].to_s)
      when String, Symbol
        if BASE_COLORS[args[0].to_sym]
          ansify(BASE_COLORS[args[0].to_sym])
        else
          raise ArgumentError.new("Unrecognized color: #{args[0]}")
        end
      else
        ansify(ANSI_CODES[args[0].to_sym])
      end
    else
      raise ArgumentError.new(INVALID_ARGUMENTS_ERROR.join("\n"))
    end
  end

  # Accepts arguments in the following forms:
  # named colors: "".on(:red), "".on("bright_green")
  # RGB: "".on(37, 19, 128)
  # 256: "".on(99)
  def on(*args)
    if args.length == 3 && args.all?(Integer)
      ansify(BACKGROUND_RGB, *args)
    elsif args.length == 1
      case args[0]
      when Integer
        ansify(BACKGROUND_256, args[0].to_s)
      when String, Symbol
        if BASE_COLORS[args[0].to_sym]
          ansify(BASE_COLORS[args[0].to_sym] + BACKGROUND_OFFSET)
        else
          raise ArgumentError.new("Unrecognized color: #{args[0]}")
        end
      else
        ansify(ANSI_CODES[args[0].to_sym])
      end
    else
      raise ArgumentError.new(INVALID_ARGUMENTS_ERROR.join("\n"))
    end
  end

  def text_color_rgb(red, green, blue)
    ansify(FOREGROUND_RGB, red, green, blue)
  end

  def bg_color_rgb(red, green, blue)
    ansify(BACKGROUND_RGB, red, green, blue)
  end

  # Set background to an arbitrary color defined by a number of 0 to 255
  def bg_color(color_code)
    ansify(BACKGROUND_256, color_code.to_s)
  end

  # Set text to an arbitrary color defined by a number of 0 to 255
  def text_color(color_code)
    ansify(FOREGROUND_256, color_code.to_s)
  end

  def rainbow
    colors = %i[ red green yellow blue magenta cyan ]
    self.chars.map.with_index { |char, i| char.send(colors[i % colors.length]) }.join
  end

  def method_missing(method, *args, &block)
    code = ANSI_CODES[method.to_sym]
    return ansify(code) if code

    super
  end

  private

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
