# frozen_string_literal: true

require_relative 'bowling_object'
require 'minitest/autorun'

class BowlingObjectTest < Minitest::Test
  def test_bowling1
    assert_equal 139, main('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5')
  end

  def test_bowling2
    assert_equal 164, main('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X')
  end

  def test_bowling3
    assert_equal 107, main('0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4')
  end

  def test_bowling4
    assert_equal 134, main('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0')
  end

  def test_bowling5
    assert_equal 144, main('6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,1,8')
  end

  def test_bowling6
    assert_equal 300, main('X,X,X,X,X,X,X,X,X,X,X,X')
  end
end
