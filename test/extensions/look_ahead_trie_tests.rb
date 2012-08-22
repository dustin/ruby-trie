#!/usr/bin/ruby -w
#
# = Name
# TestTrie
#
# == Description
# This file contains unit tests for the Trie class.
#
# == Author
# Daniel Erat <dan-ruby@erat.org>
#
# == Copyright
# Copyright 2005 Daniel Erat
#
# == License
# GNU GPL; see COPYING

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")

require 'test/unit'
require 'trie'

# Unit tests for the Trie class.
class TestLookAheadTrie < Test::Unit::TestCase
  # Check to see what the possible extensions are
  def test_list_root_paths
    t = LookAheadTrie.new
    %w(radio ratio ration radon patio path q).each_with_index { |word, index| t.insert(word, index) }
    assert_equal(%w(pat q ra), t.paths.sort)
  end

  def test_list_walked_paths
    t = LookAheadTrie.new
    %w(radio ratio ration radon patio path q).each_with_index { |word, index| t.insert(word, index) }
    t2 = t.find_prefix("ra")
    assert_equal(%w(d tio), t2.paths.sort)
  end

  def test_list_root_steps
    t = LookAheadTrie.new
    %w(radio ratio ration radon patio path q).each_with_index { |word, index| t.insert(word, index) }
    assert_equal(%w(p q r), t.steps.sort)
  end

  def test_list_walked_steps
    t = LookAheadTrie.new
    %w(radio ratio ration radon patio path q).each_with_index { |word, index| t.insert(word, index) }
    t2 = t.find_prefix("ra")
    assert_equal(%w(d t), t2.steps.sort)
  end

end
