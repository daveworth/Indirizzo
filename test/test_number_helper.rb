require 'test_helper'
include Indirizzo
class TestNumberHelper < Test::Unit::TestCase
  def test_expand_numbers
    num_list = ["5", "fifth", "five"]
    num_list.each {|n|
      assert_equal num_list, NumberHelper.expand_numbers(n).to_a.sort
    }
  end
end
