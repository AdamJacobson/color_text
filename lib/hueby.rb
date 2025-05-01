require_relative 'core_extensions/string/hueby'

class Hueby
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
    padded_string = proc { |v, len| (v.to_s.pad_to(len || 5) + " ").on(v) }

    puts "Standard colors compared with a hex equivalent. NOTE: These can be affected by your terminal settings."
    puts "Basic:  " + (0..7).map { |v| padded_string[v, 8].in("#FFFFFF") }.join
    standard_hex_colors = %w[#000000 #FF0000 #00FF00 #FFFF00 #0000FF #FF00FF #00FFFF #FFFFFF]
    puts "Hex:    " + standard_hex_colors.map { |hex| (hex + " ").pad_to(9).on(hex) }.join
    puts "Bright: " + (8..15).map { |v| padded_string[v, 8].in("#000000") }.join

    puts "\n8-bit Colors:"

    row_start_values = {16 => "#FFFFFF", 34 => "#000000"}
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
