module CoreExtensions
  module String
    module TypeTest
      def is_a_string?
        new_string = ""

        puts "#{new_string.inspect}.class == #{new_string.class}"
        puts "#{new_string.class} =?= #{String}"
        puts "Classes are the same? #{new_string.class == String}"
        puts "#{new_string.inspect}.is_a?(String) == #{new_string.is_a?(String)}"

        new_string.is_a?(::String)
      end
    end
  end
end
