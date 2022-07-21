# frozen_string_literal: true

require_relative 'ls_object'
require 'minitest/autorun'

class LsObjectTest < Minitest::Test
  def test_ls1
    expected_string = <<~TEXT.chomp
      ls_object.rb        ls_object_test.rb   ls_test
    TEXT
    assert_equal expected_string, main('.')
  end
end

