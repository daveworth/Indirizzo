module Indirizzo
  class City
    def self.city_parts(city)
      strings = []
      city.map do |string|
        tokens = string.split(" ")
        strings |= (0...tokens.length).to_a.reverse.map do |i|
                   (i...tokens.length).map {|j| tokens[i..j].join(" ")}
        end.flatten
      end
      # Don't return strings that consist solely of abbreviations.
      # NOTE: Is this a micro-optimization that has edge cases that will break?
      # Answer: Yes, it breaks on "Prairie"
      strings.reject { |s| Std_Abbr.key?(s) }.uniq
    end
  end
end
