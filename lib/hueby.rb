require_relative 'core_extensions/string/hueby'

class Hueby
  def self.define_color(name, color, create_method: false)
    defined_methods = []

    if create_method
      if safe_to_define_color_methods?(name)
        in_method = String.define_method(name) do
          self.in(color)
        end

        on_method = String.define_method("on_#{name}") do
          self.on(color)
        end

        defined_methods += [in_method]
        defined_methods += [on_method]
      else
        raise ArgumentError.new("Cannot define color method \"#{name}\" as that would overwrite an existing method.")
      end
    end

    CoreExtensions::String::Hueby::NAMED_COLORS[name.to_s.downcase] = color

    defined_methods
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
end

# TODO - FOR TESTING ONLY
String.include CoreExtensions::String::Hueby
