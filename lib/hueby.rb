require_relative 'core_extensions/string/hueby'

class Hueby
  def self.base_dir
    File.dirname(__FILE__)
  end

  def self.define_color(name, color, create_methods: false)
    defined_methods = []

    if create_methods
      if safe_to_define_color_methods?(name)
        in_method = String.define_method(name) do
          self.in(color)
        end

        on_method = String.define_method("on_#{name}") do
          self.on(color)
        end

        defined_methods += [in_method, on_method]
      else
        raise ArgumentError.new("Cannot define color method \"#{name}\" as that would overwrite an existing method.")
      end
    end

    CoreExtensions::String::Hueby::NAMED_COLORS[name.to_s.downcase] = color

    return defined_methods.any? ? defined_methods : true
  end

  # Returns true IFF
  # - Methods are not defined
  # - OR
  # - Methods are define but were defined by Hueby (in NAMED_COLORS)
  def self.safe_to_define_color_methods?(named_color)
    norm = named_color.to_s.downcase
    in_method_name = norm.to_sym
    on_method_name = "on_#{norm}".to_sym

    already_defined = "".methods & [in_method_name, on_method_name]

    return true unless already_defined.any?

    if CoreExtensions::String::Hueby::NAMED_COLORS[norm] != nil
      true
    else
      false
    end
  end

  def self.color_table
    puts "Here is a list of single digit colors that Hueby recognizes.\n\n"
    puts "[0 to 11] Basic colors defined by the terminal compared with the ideal hex color."
    base_colors = %w[black red green yellow blue magenta cyan white]
    base_colors.each_slice(4) do |slice|
      puts (slice.map.with_index do |color, i|
        string = " #{i} (term_#{color})"
        string.pad_to(25, :right).on("term_#{color}").in(:term_bright_white)
      end.join)
      puts slice.map { |color| (" " + color + " (#{String::NAMED_COLORS[color]})").pad_to(25, :right).on(color) }.join
      puts (slice.map.with_index do |color, i|
        string = " #{i + 8} (term_bright_#{color})"
        string.pad_to(25, :right).on("term_bright_#{color}").in(:term_black)
      end.join)
      puts "\n"
    end

    puts "\n[16 to 231] 8-bit Colors:"

    padded_string = proc { |v| (" " + v.to_s.pad_to(5, :right)).on(v) }

    row_start_values = {16 => "#FFF", 34 => "#000"}
    row_start_values.each do |row_start_value, text_color|
      6.times do
        cell_value = row_start_value
        18.times do |column|
          print "   " if column > 0 && column % 6 == 0
          padded = padded_string[cell_value]
          print text_color ? padded.in(text_color) : padded
          cell_value += 1
        end
        puts "\n"
        row_start_value += 36
      end
      puts "\n"
    end

    puts "Greyscale:"
    puts (232..243).to_a.map { |i| padded_string[i] }.join
    puts (244..255).to_a.map { |i| padded_string[i].in(0) }.join

    nil
  end
end

# TODO - FOR TESTING ONLY
String.include CoreExtensions::String::Hueby
Hueby.color_table
