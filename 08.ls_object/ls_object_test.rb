# frozen_string_literal: true

require_relative 'ls_object'
require 'minitest/autorun'

class LsObjectTest < Minitest::Test
  def setup
    @options = { a: false, r: false, l: false }
  end

  def test_ls_object
    expected_string = <<~TEXT.chomp
      Gemfile          	babel.config.js  	ls_object_test.rb
      Gemfile.lock     	config           	package.json
      Procfile         	config.ru        	postcss.config.js
      README.md        	log
    TEXT
    assert_equal expected_string, main('ls_test', @options)
  end

  def test_ls_object_reverse_option
    @options[:r] = true
    expected_string = <<~TEXT.chomp
      postcss.config.js	config.ru        	Procfile
      package.json     	config           	Gemfile.lock
      ls_object_test.rb	babel.config.js  	Gemfile
      log              	README.md
    TEXT
    assert_equal expected_string, main('ls_test', @options)
  end

  def test_ls_object_long_option
    @options[:l] = true
    expected_string = <<~TEXT.chomp
      total 8
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 Gemfile
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 Gemfile.lock
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 Procfile
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 README.md
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 babel.config.js
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 config
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 config.ru
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 log
      -rw-r--r--  1 yokoyamadaichi  staff  293  6 22 23:11 ls_object_test.rb
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 package.json
      -rw-r--r--  1 yokoyamadaichi  staff    0  6 21 23:55 postcss.config.js
    TEXT
    assert_equal expected_string, main('ls_test', @options)
  end

end
