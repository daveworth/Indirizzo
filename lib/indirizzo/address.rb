require 'indirizzo/constants'
require 'indirizzo/parser'
require 'indirizzo/match'
require 'indirizzo/city'
require 'indirizzo/street'

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
      value.strip \
           .gsub(/[^a-z0-9 ,'&@\/-]+/io, "") \
           .gsub(/\s+/o, " ")
    end

    def assign_text_to_address(text)
      if !text[:address].nil?
        @text = clean text[:address]
        parse
      else
        @street = []
        @prenum = text[:prenum]
        @sufnum = text[:sufnum]
        if !text[:street].nil?
          @street = text[:street].scan(Match[:street])
        end
        @number = ""
        if !@street.nil?
          if text[:number].nil?
            @street.map! { |single_street|
              single_street.downcase!
              @number = single_street.scan(Match[:number])[0].reject{|n| n.nil? || n.empty?}.first.to_s
              single_street.sub! @number, ""
              single_street.sub! /^\s*,?\s*/o, ""
            }
          else
            @number = text[:number].to_s
          end
          @street = expand_streets(@street) if @options[:expand_streets]
          street_parts
        end
        @city = []
        if !text[:city].nil?
          @city.push(text[:city])
          @text = text[:city].to_s
        else
          @city.push("")
        end
        if !text[:region].nil?
          # @state = []
          @state = text[:region]
          if @state.length > 2
            # full_state = @state.strip # special case: New York
            @state = State[@state]
          end
        elsif !text[:state].nil?
          @state = text[:state]
        elsif !text[:country].nil?
          @state = text[:country]
        end

        @zip = text[:postal_code]
        @plus4 = text[:plus4]
        if !@zip
          @zip = @plus4 = ""
        end
      end
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
