require 'test_helper'
require 'indirizzo/address'

include Indirizzo

class TestAddress < Test::Unit::TestCase

  def test_new_raises_exception_with_no_text
    assert_raise do
      Address.new
    end
  end

  def test_text_parsing_city
    addr = Address.new("Lake Forest")
    assert_equal ["lake forest"], addr.city
  end

  def test_new
    addr = Address.new("1600 Pennsylvania Av., Washington DC")
    assert_equal "1600 Pennsylvania Av, Washington DC", addr.text
  end

  def test_expand_street
    addr = Address.new("1 First St, Atlanta GA, 12345")
    expected_streets = ["1 st", "first st", "one st"]
    expected_streets.each_with_index do |street, index|
      addr.street[index] = expected_streets[index]
    end
  end

  def test_no_expand_street
    addr = Address.new("1 First St, Atlanta GA, 12345", :expand_streets => false)
    assert_equal addr.street.first, "first st"
  end

  def test_po_box
    addr_po = Address.new "PO Box 1111 Herndon VA 20171"
    assert addr_po.po_box?
  end

  def test_intersection
    addr_intersection = Address.new "Means St. at Optimism Way"
    assert addr_intersection.intersection?
  end

  def test_skip_parse
    addresses = [
      {:street => "1233 Main St", :city => "Springfield", :region => "VA", :postal_code => "12345", :final_number => "1233", :parsed_street => "main st"},
      {:street => "somewhere Ln", :city => "Somewhere", :region => "WI", :postal_code => "22222", :number => "402", :parsed_street => "somewhere ln", :final_number => "402"},
#      {:street => "somewhere Ln", :city => "Somewhere", :state => "WI", :full_state => "Wisconsin", :postal_code => "22222", :number => "402", :parsed_street => "somewhere ln", :final_number => "402"},
      ]
      for preparsed_address in addresses
        address_for_geocode = Address.new preparsed_address
        assert_equal preparsed_address[:parsed_street],address_for_geocode.street[0]
        assert_equal preparsed_address[:final_number],address_for_geocode.number
        assert_equal preparsed_address[:city],address_for_geocode.city[0]
        assert_equal preparsed_address[:region],address_for_geocode.state if preparsed_address[:region]
        assert_equal preparsed_address[:state],address_for_geocode.state  if preparsed_address[:state]
        assert_equal preparsed_address[:full_state],address_for_geocode.full_state if preparsed_address[:state] || preparsed_address[:region]
        assert_equal preparsed_address[:abbr_state],address_for_geocode.state if preparsed_address[:state]
        assert_equal preparsed_address[:postal_code],address_for_geocode.zip
      end
  end

  def test_states_abbreviated_in_skip_parse
    addresses = [
      {:street => "123 Main St", :city => "Springfield", :region => "Virginia", :postal_code => "12345",:state_abbrev => "VA"},
      {:street => "402 Somewhere Ln", :city => "Somewhere", :region => "WI", :postal_code => "22222", :state_abbrev => "WI"},
      ]
      for preparsed_address in addresses
        address_for_geocode = Address.new preparsed_address
        assert_equal preparsed_address[:state_abbrev],address_for_geocode.state
      end
  end

  def test_address_hash
    addresses = [
      {:address => "Herndon, VA", :place_check => ["herndon"]},
      {:address => "Arlington, VA", :place_check => ["arlington"]}
      ]
      for preparsed_address in addresses
        address_for_geocode = Address.new preparsed_address
        assert_equal preparsed_address[:place_check],address_for_geocode.city
      end
  end

  def test_partial_address
    addresses = [
      {:street => "2200 Wilson Blvd", :postal_code => "22201"},
      ]
      for preparsed_address in addresses
        address_for_geocode = Address.new preparsed_address
        assert_equal preparsed_address[:postal_code],address_for_geocode.zip
      end
  end

  def test_country_parse
    addresses = [
      {:city => "Paris", :country => "FR"},
      ]

      for preparsed_address in addresses
        address_for_geocode = Address.new preparsed_address
        assert_equal preparsed_address[:country],address_for_geocode.state
      end
  end

  # test cleaning code
  [
    [ "cleaned text", "cleaned: text!" ],
    [ "cleaned-text 2", "cleaned-text: #2?" ],
    [ "it's working 1/2", "~it's working 1/2~" ],
    [ "it's working, yes", "it's working, yes...?" ],
    [ "it's working & well", "it's working & well?" ]
  ].each do |output, given|
    define_method "test_clean_#{output.tr('-/\'&', '').gsub(/\s+/, '_')}" do
      assert_equal output, Address.new(given).text
    end
  end

  # test the city parsing code
  [
    [ "New York, NY",     "New York", "NY", "" ],
    [ "NY",               "", "NY",   "" ],
    [ "New York",         "New York", "NY",   "" ],
    [ "Philadelphia",     "Philadelphia", "", "" ],
    [ "Philadelphia PA",  "Philadelphia", "PA", "" ],
    [ "Philadelphia, PA", "Philadelphia", "PA", "" ],
    [ "Philadelphia, Pennsylvania", "Philadelphia", "PA", "" ],
    [ "Philadelphia, Pennsylvania 19131", "Philadelphia", "PA", "19131" ],
    [ "Philadelphia 19131", "Philadelphia", "", "19131" ],
    [ "Pennsylvania 19131", "Pennsylvania", "PA", "19131" ], # kind of a misfeature
    [ "19131", "", "", "19131" ],
    [ "19131-9999", "", "", "19131" ],
  ].each do |fixture|
    fixture_name = fixture[0].gsub(/(?:\s+|[,])/,'_')
    define_method "test_city_parse_#{fixture_name}" do
      check_city(fixture)
    end
  end

  def check_city(fixture)
      addr  = Address.new(fixture[0])
      [:city, :state, :zip].zip(fixture[1..3]).each do |key,val|
        result = addr.send(key)
        result = [result.downcase] unless result.kind_of?(Array)
        if result.empty?
          assert_equal val, "", key.to_s + " test no result " + fixture.join("/")
        else
          assert result.member?(val.downcase), key.to_s + " test " + result.inspect + fixture.join("/")
        end
      end
  end

  # test address parsing code
  [
    {:text   => "1600 Pennsylvania Av., Washington DC 20050",
     :number => "1600",
     :street => "Pennsylvania Ave",
     :city   => "Washington",
     :state  => "DC",
     :full_state => "washington dc",
     :zip    => "20050"},

    {:text   => "1600 Pennsylvania, Washington DC",
     :number => "1600",
     :street => "Pennsylvania",
     :city   => "Washington",
     :full_state => "washington dc",
     :state  => "DC"},

    {:text   => "1600 Pennsylvania Washington DC",
     :number => "1600",
     :city   => "Washington",
     :street => "Pennsylvania",
     :full_state => "washington dc",
     :state  => "DC"},

    {:text   => "1600 Pennsylvania Washington",
     :pending => true,
     :number => "1600",
     :street => "Pennsylvania",
     :city   => "Washington",
     :full_state => "washington dc",
     :state  => "DC"},

    {:text   => "1600 Pennsylvania 20050",
     :number => "1600",
     :state  => "PA",
     :full_state => "pennsylvania",
     :zip    => "20050"},

    {:text   => "1600 Pennsylvania Av, Washington DC 20050-9999",
     :number => "1600",
     :state  => "DC",
     :street => "Pennsylvania Ave",
     :plus4  => "9999",
     :zip    => "20050"},

    {:text   => "1600 Pennsylvania Av, 20050-9999",
     :pending => true,
     :number => "1600",
     #:state  => "PA",
     :street => "Pennsylvania Ave",
     :plus4  => "9999",
     :zip    => "20050"},

    {:text   => "1005 Gravenstein Highway North, Sebastopol CA",
     :number => "1005",
     :street => "Gravenstein Hwy N",
     :city   => "Sebastopol",
     :state  => "CA"},

    {:text   => "100 N 7th St, Brooklyn",
     :number => "100",
     :street => "N 7 St",
     :city   => "Brooklyn"},

    {:text   => "100 N Seventh St, Brooklyn",
     :number => "100",
     :street => "N 7 St",
     :city   => "Brooklyn"},

    {:text   => "100 Central Park West, New York, NY",
     :number => "100",
     :street => "Central Park W",
     :city   => "New York",
     :state  => "NY"},

    {:text   => "100 Central Park West, 10010",
     :number => "100",
     :street => "Central Park W",
     :zip    => "10010"},

    {:text   => "1400 Avenue of the Americas, New York, NY 10019, US",
     :number => "1400",
     :street => "Ave of the Americas",
     :city   => "New York",
     :state  => "NY",
     :country => "US"},

    {:text   => "1400 Avenue of the Americas, New York, NY 10019, USA",
     :number => "1400",
     :street => "Ave of the Americas",
     :city   => "New York",
     :state  => "NY",
     :country => "USA"},

    {:text   => "1400 Avenue of the Americas, New York, NY 10019,   United States of America  ",
     :number => "1400",
     :street => "Ave of the Americas",
     :city   => "New York",
     :state  => "NY",
     :country => "United States of America"},

    {:text   => "1400 Avenue of the Americas, New York",
     :number => "1400",
     :street => "Ave of the Americas",
     :city   => "New York"},

    {:text   => "1400 Ave of the Americas, New York",
     :number => "1400",
     :street => "Ave of the Americas",
     :city   => "New York"},

    {:text   => "1400 Av of the Americas, New York",
     :number => "1400",
     :street => "Ave of the Americas",
     :city   => "New York"},

    {:text   => "1400 Av of the Americas New York",
     :number => "1400",
     :street => "Ave of the Americas",
     :city   => "New York"},

    {:text   => "23 Home St,    Hometown  PA,  12345  US",
     :number => "23",
     :state  => "PA",
     :street => "Home St",
     :city   => "Hometown",
     :zip    => "12345"},

    {:text   => "23 Home St, Apt. A, Hometown  PA,  12345  US",
     :number => "23",
     :state  => "PA",
     :street => "Home St",
     :city   => "Hometown",
     :zip    => "12345",
     :country => "US"}
  ].each do |fixture|
    define_method "test_parse_#{fixture[:text].gsub(/(?:\s+|[.,])/,'_')}" do
      pend if fixture[:pending]
      check_addr(fixture)
    end
  end

  def check_addr(fixture)
    text = fixture[:text]
    addr = Address.new(text)
    fixture.reject{|k,v| k == :text}.each do |key, val|
      result = addr.send key
      if result.kind_of? Array
        result.map! {|str| str.downcase}
        assert result.member?(val.downcase), "#{text} (#{key}) = #{result.inspect}"
      else
        assert_equal val, result, "#{text} (#{key}) = #{result.inspect}"
      end
    end
  end
end
