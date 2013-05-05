module Indirizzo
  class Helper
    def self.remove_noise_words(strings)
      # Don't return strings that consist solely of abbreviations.
      # NOTE: Is this a micro-optimization that has edge cases that will break?
      # Answer: Yes, it breaks on simple things like "Prairie St" or "Front St"
      prefix = Regexp.new("^" + Prefix_Type.regexp.source + "\s*", Regexp::IGNORECASE)
      suffix = Regexp.new("\s*" + Suffix_Type.regexp.source + "$", Regexp::IGNORECASE)
      predxn = Regexp.new("^" + Directional.regexp.source + "\s*", Regexp::IGNORECASE)
      sufdxn = Regexp.new("\s*" + Directional.regexp.source + "$", Regexp::IGNORECASE)
      good_strings = strings.map {|s|
        s = s.clone
        s.gsub!(predxn, "")
        s.gsub!(sufdxn, "")
        s.gsub!(prefix, "")
        s.gsub!(suffix, "")
        s
      }
      good_strings.reject! {|s| s.empty?}
      strings = good_strings if !good_strings.empty? {|s| not Std_Abbr.key?(s) and not Name_Abbr.key?(s)}
      strings
    end
  end
end
