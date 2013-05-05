module Indirizzo
  class AddressHashExtractor
    def self.extract(address_hash, options)
      AddressHashExtractor.new(address_hash, options).extract
    end

    def initialize(address_hash, options={})
      @address_hash = address_hash
      @options = options
    end

    def extract
      if !@address_hash[:address].nil?
        @text = Helper.clean @address_hash[:address]
        return Parser.new(@text, @options).parse
      else
        handle_hash
      end

      return @text, @city, @street, @number, @prenum, @sufnum, @full_state, @state, @zip, @plus4, @country
    end

    private
    def handle_hash
      text = @address_hash
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
        @street = Street.expand(@street) if @options[:expand_streets]
        #Street.parts
      end

      handle_city

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

    def handle_city
      @city = []
      if !@address_hash[:city].nil?
        @city.push(@address_hash[:city])
        @text = @address_hash[:city].to_s
      else
        @city.push("")
      end
    end
  end
end
