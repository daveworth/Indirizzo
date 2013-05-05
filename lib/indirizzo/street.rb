require 'indirizzo/constants'
require 'indirizzo/number_helper'
require 'indirizzo/helper'

module Indirizzo
  class Street
    def self.expand(street)
      if !street.empty? && !street[0].nil?
        street.map! {|s|s.strip}
        add = street.map {|item| item.gsub(Name_Abbr.regexp) {|m| Name_Abbr[m]}}
        street |= add
        add = street.map {|item| item.gsub(Std_Abbr.regexp) {|m| Std_Abbr[m]}}
        street |= add
        street.map! {|item| NumberHelper.expand_numbers(item)}
        street.flatten!
        street.map! {|s| s.downcase}
        street.uniq!
      else
        street = []
      end
      street
    end

    def self.parts(street, number)
      strings = []
      # Get all the substrings delimited by whitespace
      street.each do |string|
        tokens = string.split(" ")
        strings |= (0...tokens.length).map do |i|
                   (i...tokens.length).map {|j| tokens[i..j].join(" ")}
        end.flatten
      end
      strings = Helper.remove_noise_words(strings)

      # Try a simpler case of adding the @number in case everything is an abbr.
      strings += [number] if strings.all? {|s| Std_Abbr.key?(s) || Name_Abbr.key?(s)}
      strings.uniq
    end
  end
end
