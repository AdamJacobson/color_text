# color_text
Ruby library for colorizing strings.

I hope to make this into a Ruby Gem.

Works by monkey patching the String class.

## Usage

```ruby
require "color_text"
```

Strings now posses a number of methods to change their color and background.

The following methods can be called on any String. All methods return the altered string and are therefor chainable.

```
 :default,
 :bold,
 :dim,
 :italic,
 :underline,
 :inverse,
 :invisible,
 :strikethrough,
 :on_black,
 :on_red,
 :on_green,
 :on_yellow,
 :on_blue,
 :on_magenta,
 :on_cyan,
 :on_white,
 :on_bright_black,
 :on_bright_red,
 :on_bright_green,
 :on_bright_yellow,
 :on_bright_blue,
 :on_bright_magenta,
 :on_bright_cyan,
 :on_bright_white,
 :black,
 :red,
 :green,
 :yellow,
 :blue,
 :magenta,
 :cyan,
 :white,
 :bright_black,
 :bright_red,
 :bright_green,
 :bright_yellow,
 :bright_blue,
 :bright_magenta,
 :bright_cyan,
 :bright_white
```

![basic examples](images/examples_1.png)

Strings can also be colorized in more advanced ways using the `String#in` method.

`String#in` supports multiple arguments.

With a string or symbol, you can specify a named color.

With a single integer, you can specify a 256 bit color.

With 3 integers, you can specify a color via Red, Green and Blue values.

Similarly, `String#on` will change the background color in the same way.
