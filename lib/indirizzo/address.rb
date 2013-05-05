require 'indirizzo/constants'
require 'indirizzo/parser'
require 'indirizzo/address_hash_extractor'
require 'indirizzo/match'
require 'indirizzo/city'
require 'indirizzo/street'
require 'indirizzo/helper'

module Indirizzo
  # The Address class takes a US street address or place name and
  # constructs a list of possible structured parses of the address
  # string.
  class Address
    attr_accessor :text
    attr_accessor :prenum, :number, :sufnum
    attr_accessor :street
    attr_accessor :city
    attr_accessor :state
    attr_accessor :zip, :plus4
    attr_accessor :country
    attr_accessor :options

    # Takes an address or place name string as its sole argument.
    def initialize (text, options={})
      @options = {:expand_streets => true}.merge(options)

      raise ArgumentError, "no text provided" unless text and !text.empty?
      if text.class == Hash
        @text = ""
        assign_text_to_address text
      else
        @text = clean text
        parse
      end
    end

    # Removes any characters that aren't strictly part of an address string.
    def clean (value)
      Helper.clean(value)
    end

    def assign_text_to_address(text)
      @text, @city, @street, @number, @prenum, @sufnum, @full_state, @state, @zip, @plus4, @country = AddressHashExtractor.extract(text, @options)
    end

    def expand_numbers (string)
      NumberHelper.expand_numbers(string)
    end

    def parse
      @city, @street, @number, @prenum, @sufnum, @full_state, @state, @zip, @plus4, @country = Parser.new(@text, @options).parse
    end

    def expand_streets(street)
      Street.expand(street)
    end

    def street_parts
      Street.parts(@street, @number)
    end

    def remove_noise_words(strings)
      Helper.remove_noise_words(strings)
    end

    def city_parts
      City.city_parts(@city)
    end

    def city= (strings)
      # NOTE: This will still fail on: 100 Broome St, 33333 (if 33333 is
      # Broome, MT or what)
      strings = expand_streets(strings) # fix for "Mountain View" -> "Mountain Vw"
      match = Regexp.new('\s*\b(?:' + strings.join("|") + ')\b\s*$', Regexp::IGNORECASE)
      @street = @street.map {|string| string.gsub(match, '')}.select {|s|!s.empty?}
    end

    def po_box?
      !Match[:po_box].match(@text).nil?
    end

    def intersection?
      !Match[:at].match(@text).nil?
    end
  end
end
