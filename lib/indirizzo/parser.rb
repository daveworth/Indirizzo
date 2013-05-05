require 'indirizzo/match'
require 'indirizzo/helper'
require 'indirizzo/street'
require 'indirizzo/constants'

module Indirizzo
  class Parser
    def initialize(text, options={})
      @text = text
      @options = options
    end

    def parse
      text = @text.clone.downcase

      @zip = text.scan(Match[:zip]).last
      if @zip
        last_match = $&
          zip_index = text.rindex(last_match)
        zip_end_index = zip_index + last_match.length - 1
        @zip, @plus4 = @zip.map {|s| s and s.strip }
      else
        @zip = @plus4 = ""
        zip_index = text.length
        zip_end_index = -1
      end

      @country = @text[zip_end_index+1..-1].sub(/^\s*,\s*/, '').strip
      @country = nil if @country == text

      @state = text.scan(Match[:state]).last
      if @state
        last_match = $&
          state_index = text.rindex(last_match)
        text = parse_state(last_match, text)
      else
        @full_state = ""
        @state = ""
      end

      @number = text.scan(Match[:number]).first
      # FIXME: 230 Fish And Game Rd, Hudson NY 12534
      if @number # and not intersection?
        last_match = $&
          number_index = text.index(last_match)
        number_end_index = number_index + last_match.length - 1
        @prenum, @number, @sufnum = @number.map {|s| s and s.strip}
      else
        number_end_index = -1
        @prenum = @number = @sufnum = ""
      end

      # FIXME: special case: Name_Abbr gets a bit aggressive
      # about replacing St with Saint. exceptional case:
      # Sault Ste. Marie

      # FIXME: PO Box should geocode to ZIP
      street_search_end_index = [state_index,zip_index,text.length].reject(&:nil?).min-1
      @street = text[number_end_index+1..street_search_end_index].scan(Match[:street]).map { |s| s and s.strip }

      @street = Street.expand(@street) if @options[:expand_streets]
      # SPECIAL CASE: 1600 Pennsylvania 20050
      @street << @full_state if @street.empty? and @state.downcase != @full_state.downcase

      street_end_index = @street.map { |s| text.rindex(s) }.reject(&:nil?).min||0

      if @city.nil? || @city.empty?
        @city = text[street_end_index..street_search_end_index+1].scan(Match[:city])
        if !@city.empty?
          #@city = [@city[-1].strip]
          @city = [@city.last.strip]
          add = @city.map {|item| item.gsub(Name_Abbr.regexp) {|m| Name_Abbr[m]}}
          @city |= add
          @city.map! {|s| s.downcase}
          @city.uniq!
        else
          @city = []
        end

        # SPECIAL CASE: no city, but a state with the same name. e.g. "New York"
        @city << @full_state if @state.downcase != @full_state.downcase
      end

      return @city, @street, @number, @prenum, @sufnum, @full_state, @state, @zip, @plus4, @country
    end

    def self.extract_data_from_hash(address_hash, options)
      text = address_hash
      if !text[:address].nil?
        @text = Helper.clean text[:address]
        return self.new(@text, options).parse
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
          @street = Street.expand(@street) if options[:expand_streets]
          #Street.parts
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

      return @text, @city, @street, @number, @prenum, @sufnum, @full_state, @state, @zip, @plus4, @country
    end

    private

    def parse_state(regex_match, text)
      idx = text.rindex(regex_match)
      @full_state = @state[0].strip # special case: New York
      @state = State[@full_state]
      @city = "Washington" if @state == "DC" && text[idx...idx+regex_match.length] =~ /washington\s+d\.?c\.?/i
      text
    end
  end
end
