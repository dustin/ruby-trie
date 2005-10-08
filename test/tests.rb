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

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'trie'

# Unit tests for the Trie class.
class TestTrie < Test::Unit::TestCase
  # Test a compressed key with a single value at the root.
  def test_find_compressed_key_single_value_at_root
    t = Trie.new.insert('abc', 1)
    assert_equal([1], t.find('abc').values)
    assert_equal([1], t.find('abc').find('').values)
    assert_equal([], t.find('a').values)
    assert_equal([], t.find('').values)
    assert_equal([], t.find('b').values)
    assert_equal([1], t.find_prefix('abc').values)
    assert_equal([1], t.find_prefix('abc').find_prefix('').values)
    assert_equal([1], t.find_prefix('ab').values)
    assert_equal([1], t.find_prefix('a').values)
    assert_equal([1], t.find_prefix('').values)
    assert_equal([], t.find_prefix('b').values)
  end

  # Test a compressed key with multiple values at the root.
  def test_find_compressed_key_multiple_values_at_root
    t = Trie.new.insert('ab', 1).insert('ab', 2).insert('ab', 3)
    assert_equal([1, 2, 3], t.find('ab').values.sort)
    assert_equal([], t.find('a').values)
    assert_equal([], t.find('').values)
    assert_equal([1, 2, 3], t.find_prefix('ab').values.sort)
    assert_equal([1, 2, 3], t.find_prefix('a').values.sort)
    assert_equal([1, 2, 3], t.find_prefix('').values.sort)
  end

  # Test a more complex Trie that contains a few compressed keys.
  def test_find_complex
    t = Trie.new.insert('a', 1).insert('ab', 2).insert('abcdef', 3).
      insert('b', 4).insert('bcd', 5).insert('b', 6).insert('bcd', 7)
    assert_equal([1], t.find('a').values)
    assert_equal([2], t.find('ab').values)
    assert_equal([3], t.find('abcdef').values)
    assert_equal([4, 6], t.find('b').values.sort)
    assert_equal([5, 7], t.find('bcd').values.sort)
    assert_equal([], t.find('bcde').values)
    assert_equal([], t.find('').values)
    assert_equal([1, 2, 3], t.find_prefix('a').values)
    assert_equal([2, 3], t.find_prefix('ab').values)
    assert_equal([3], t.find_prefix('abcdef').values)
    assert_equal([4, 5, 6, 7], t.find_prefix('b').values.sort)
    assert_equal([5, 7], t.find_prefix('bcd').values.sort)
    assert_equal([], t.find_prefix('bcde').values)
    assert_equal([1, 2, 3, 4, 5, 6, 7], t.find_prefix('').values.sort)
  end

  # We have a compressed key at the root and then do one-or
  # two-characters-at-a-time searches against it.
  def test_find_multiple_lookups_compressed_key
    t = Trie.new.insert('alphabet', 1)
    t2 = t.find_prefix('')
    assert_equal([1], t2.values)
    t2 = t2.find_prefix('al')
    assert_equal([1], t2.values)
    t2 = t2.find_prefix('p')
    assert_equal([1], t2.values)
    t2 = t2.find_prefix('ha')
    assert_equal([1], t2.values)
    t2 = t2.find_prefix('bet')
    assert_equal([1], t2.values)
    t2 = t2.find_prefix('')
    assert_equal([1], t2.values)
    t2 = t2.find_prefix('a')
    assert_equal([], t2.values)
  end

  # We construct a trie with multiple values and then walk down it,
  # searching for one or two characters at a time.
  def test_find_multiple_lookups
    t = Trie.new.insert('happy', 1).insert('hop', 2).insert('hey', 3).
      insert('hello!', 4).insert('help', 5).insert('foo', 6)
    assert_equal([6], t.find_prefix('fo').values)
    t2 = t.find_prefix('h')
    assert_equal([1, 2, 3, 4, 5], t2.values.sort)
    t2 = t2.find_prefix('e')
    assert_equal([3, 4, 5], t2.values.sort)
    assert_equal([3], t2.find_prefix('y').values)
    t2 = t2.find_prefix('l')
    assert_equal([4, 5], t2.values.sort)
    t2 = t2.find_prefix('lo')
    assert_equal([4], t2.values)
    t2 = t2.find_prefix('!')
    assert_equal([4], t2.values)
    t2 = t2.find_prefix('')
    assert_equal([4], t2.values)
    t2 = t2.find_prefix('!')
    assert_equal([], t2.values)
  end

  # We construct a trie with multiple elements and test the size
  # method.
  def test_size
    t = Trie.new.insert('ha', 1).insert('hat', 2).insert('hate', 3).
      insert('hated', 4).insert('test', 5)
    assert_equal(5, t.size)
    assert_equal(4, t.find_prefix('ha').size)
    assert_equal(2, t.find_prefix('hate').size)
    assert_equal(1, t.find_prefix('test').size)
    assert_equal(0, t.find_prefix('testing').size)
  end

  # We build a trie and test the empty? method.
  def test_empty
    t = Trie.new.insert('foo', 1).insert('bar', 2).insert('food', 3)
    assert_equal(false, t.empty?)
    assert_equal(false, t.find('foo').empty?)
    assert_equal(false, t.find_prefix('foo').empty?)
    assert_equal(true, t.find('fool').empty?)
  end

  # We insert keys that are actually lists containing objects of varying
  # classes.
  def test_mixed_classes_in_keys
    t = Trie.new.insert([0, 1, 2], 0).insert([0, 'a'], 1).insert([1000], 2).
      insert([0, 'a'], 3).insert('blah', 4)
    assert_equal([0, 1, 3], t.find_prefix([0]).values.sort)
    assert_equal([0], t.find_prefix([0, 1]).values)
    assert_equal([1, 3], t.find_prefix([0, 'a']).values.sort)
    assert_equal([2], t.find_prefix([1000]).values)
    assert_equal([], t.find([0]).values)
    assert_equal([1, 3], t.find([0, 'a']).values.sort)
    assert_equal([4], t.find('blah').values)
  end

  # Test delete.
  def test_delete
    t = Trie.new.insert('a', 1).insert('a', 2).insert('a', 3).
      insert('ab', 4).insert('ab', 5).insert('abc', 6)
    assert_equal([1, 2, 3, 4, 5, 6], t.values.sort)
    t.delete('a')
    assert_equal([4, 5, 6], t.values.sort)
    t.delete('abc')
    assert_equal([4, 5], t.values.sort)
    t.delete('ab')
    assert_equal([], t.values)
  end

  # Test delete_pair.
  def test_delete_pair
    t = Trie.new.insert('apple', 1).insert('apples', 2)
    assert_equal([1], t.find('apple').values)
    assert_equal([1, 2], t.find_prefix('apple').values.sort)
    t.delete_pair('apple', 1)
    assert_equal([], t.find('apple').values)
    assert_equal([2], t.find('apples').values)
    assert_equal([2], t.find_prefix('apple').values)
    t.delete_pair('apples', 1)  # key/value pair isn't in trie
    assert_equal([2], t.find('apples').values)
    t.delete_pair('apples', 2)
    assert_equal([], t.find('apples').values)
  end

  # Test delete_value.
  def test_delete_value
    t = Trie.new.insert('a', 1).insert('ab', 1).insert('abc', 2).
      insert('a', 2).insert('b', 1).insert('c', 1)
    assert_equal(6, t.size)
    t.delete_value(1)
    assert_equal(2, t.size)
    t.delete_value(2)
    assert_equal(true, t.empty?)
  end

  # Test delete_prefix.
  def test_delete_prefix
    t = Trie.new.insert('a', 1).insert('a', 2).insert('a', 3).
      insert('ab', 4).insert('ab', 5).insert('abc', 6)
    assert_equal([1, 2, 3, 4, 5, 6], t.values.sort)
    t.delete_prefix('ab')
    assert_equal([1, 2, 3], t.values.sort)
    t.delete_prefix('a')
    assert_equal(true, t.empty?)
  end

  # Test clear.
  def test_clear
    t = Trie.new.insert('a', 1).insert('ab', 2)
    assert_equal(2, t.size)
    t.clear
    assert_equal(true, t.empty?)
  end

  # Test each_key.
  def test_each_key
    t = Trie.new.insert('a', 1).insert('a', 2).insert('b', 3).insert('ab', 4)
    keys = []
    t.each_key {|k| keys.push(k.join) }
    assert_equal(['a', 'ab', 'b'], keys.sort)
  end

  # Test each_value.
  def test_each_value
    t = Trie.new.insert('a', 1).insert('a', 2).insert('b', 1)
    values = []
    t.each_value {|v| values.push(v) }
    assert_equal([1, 1, 2], values.sort)
  end

  # Test each.
  def test_each
    t = Trie.new.insert('a', 1).insert('a', 2).insert('b', 3).insert('ab', 4)
    pairs = []
    t.each {|k, v| pairs.push([k.join, v]) }
    assert_equal([['a', 1], ['a', 2], ['ab', 4], ['b', 3]], pairs.sort)
  end

  # Test keys.
  def test_keys
    t = Trie.new.insert('a', 1).insert('a', 2).insert('abc', 3).insert('b', 4)
    keys = t.keys.collect {|k| k.join }.sort
    assert_equal(['a', 'abc', 'b'], keys)
  end

  # Test the composition of the tries by using the num_nodes method.
  def test_composition
    t = Trie.new.insert('a', 1)
    assert_equal(1, t.num_nodes)  # a
    t.insert('a', 2)
    assert_equal(1, t.num_nodes)  # a
    t.insert('abc', 3)
    assert_equal(3, t.num_nodes)  # '' -> a -> bc
    t.insert('ab', 4)
    assert_equal(4, t.num_nodes)  # '' -> a -> b -> c
    t.insert('b', 5)
    assert_equal(5, t.num_nodes)  # '' -> (a -> b -> c | b)
    t.insert('b', 6)
    assert_equal(5, t.num_nodes)  # '' -> (a -> b -> c | b)
    t.insert('abcdef', 7)
    assert_equal(6, t.num_nodes)  # '' -> (a -> b -> c -> def | b)
    t.insert('abcdeg', 8)
    # '' -> (a -> b -> c -> d -> e -> (f | g) | b)
    assert_equal(9, t.num_nodes)
  end
end
