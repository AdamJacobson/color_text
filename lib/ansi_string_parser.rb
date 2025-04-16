class AnsiStringParser
  def initialize(source)
    @source = source
  end

  def parse
    @tokenized = tokenize
  end

  private

  def tokenize
    tokens = []
    current_token = nil

    puts "tokenizing: #{@source.inspect}"

    i = 0
    while i < @source.length
      puts "i: #{i}"
      char = @source[i]
      if char == "\e" && @source[i + 1] == "["
        if current_token
          tokens += [current_token] 
          current_token = nil
        end
        puts "\tFound code start"
        codes, i = extract_codes_at(i)
        tokens += [codes]
        p tokens
      else
        current_token ||= ""
        current_token += char
        puts "other char: #{char}"
        i += 1
      end
    end

    tokens += [current_token] if current_token

    tokens
  end

  # Get the code starting at the given index. Returns the index after the code ends.
  def extract_codes_at(code_start)
    codes = []
    current_code = ""

    puts "extract_codes_at(#{code_start})"
    i = code_start
    char = @source[i]
    while char != "m"
      puts "extract_codes_at: #{char.inspect}"
      case char
      when ";"
        codes += [current_code.to_i]
        current_code = ""
      when /\d/
        current_code += char
      end

      i += 1
      char = @source[i]
    end

    codes += [current_code.to_i] if current_code

    puts "returning: [#{codes}, #{i + 1}]"
    [codes, i + 1]
  end
end
