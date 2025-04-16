# Used to parse strings with ANSI codes into a format that is easier to modify.
# Used internally by ColorText. Not required for end user.
class AnsiStringParser
  def initialize(source)
    @source = source
  end

  def parse
    @tokenized = tokenize
  end

  private

  #
  def tokenize
    tokens = []
    current_token = nil
    skip_until_after = -1

    @source.chars.each_with_index do |char, i|
      next if i <= skip_until_after

      case char
      when "\e"
        if current_token
          tokens += [current_token]
          current_token = nil
        end
        codes, skip_until_after = extract_codes_at(i)
        tokens += [codes]
      else
        current_token ||= ""
        current_token += char
      end
    end

    tokens += [current_token] if current_token
    tokens
  end

  # Get the numeric codes starting at the given index.
  # Returns codes as an Array of Integers along with the ending index of the sequence
  def extract_codes_at(code_start)
    substring = @source[code_start..-1]

    match = substring.match(/^\e\[(?<numbers>[^m]*)/)
    if match
      numbers = match.named_captures["numbers"].split(";").map(&:to_i)
      end_index = code_start + match[0].length

      return [numbers, end_index]
    else
      raise "invalid code sequence at start of substring \"#{substring}\""
    end
  end
end
