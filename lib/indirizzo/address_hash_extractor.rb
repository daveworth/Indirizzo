module Indirizzo
  class AddressHashExtractor
    def self.extract(address_hash, options)
      AddressHashExtractor.new(address_hash, options).extract
    end

    def initialize(address_hash, options={})
      @address_hash = address_hash
      @options = options
    end
    attr_accessor :address_hash

    def extract
      if !address_hash[:address].nil?
        @text = Helper.clean address_hash[:address]
        return Parser.new(@text, @options).parse
      else
        handle_hash
      end

      return @text, @city, @street, @number, @prenum, @sufnum, @full_state, @abbr_state, @state, @zip, @plus4, @country
    end

    private
    def handle_hash
      handle_street_and_numbers
      handle_city
      handle_state
      handle_zip
    end

    def handle_street_and_numbers
      @street = []
      @prenum = address_hash[:prenum]
      @sufnum = address_hash[:sufnum]
      if !address_hash[:street].nil?
        @street = address_hash[:street].scan(Match[:street])
      end
      @number = ""
      if !@street.nil?
        if address_hash[:number].nil?
          @street.map! { |single_street|
            single_street.downcase!
            @number = single_street.scan(Match[:number])[0].reject{|n| n.nil? || n.empty?}.first.to_s
            single_street.sub! @number, ""
            single_street.sub! /^\s*,?\s*/o, ""
          }
        else
          @number = address_hash[:number].to_s
        end
        @street = Street.expand(@street) if @options[:expand_streets]
      end
    end

    def handle_city
      @city = []
      if !address_hash[:city].nil?
        @city.push(address_hash[:city])
        @text = address_hash[:city].to_s
      else
        @city.push("")
      end
    end

    def handle_state
      if !address_hash[:region].nil?
        @state = address_hash[:region]
        # full_state = @state.strip # special case: New York
        @state = State[@state] if @state.length > 2
      elsif !address_hash[:state].nil?
        @state = address_hash[:state]
        @abbr_state = State.select{|k,v| k == @state}.values.first || @state
        @full_state = State.select{|k,v| k == @state || v == @state}.keys.first
      elsif !address_hash[:country].nil?
        @state = address_hash[:country]
      end
    end

    def handle_zip
      @zip = address_hash[:postal_code]
      @plus4 = address_hash[:plus4]
      if !@zip
        @zip = @plus4 = ""
      end
    end
  end
end
