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

# TODO - FOR TESTING ONLY
String.include CoreExtensions::String::Hueby
