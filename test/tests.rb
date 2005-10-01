#!/usr/bin/ruby -w

require 'test/unit'
require 'trie'

class TestTrie < Test::Unit::TestCase
  # Test a compressed key with a single value at the root.
  def test_find_compressed_key_single_value_at_root
    t = Trie.new.insert('abc', 1)
    assert_equal(t.find('abc').values, [1])
    assert_equal(t.find('abc').find('').values, [1])
    assert_equal(t.find('a').values, [])
    assert_equal(t.find('').values, [])
    assert_equal(t.find('b').values, [])
    assert_equal(t.find_prefix('abc').values, [1])
    assert_equal(t.find_prefix('abc').find_prefix('').values, [1])
    assert_equal(t.find_prefix('ab').values, [1])
    assert_equal(t.find_prefix('a').values, [1])
    assert_equal(t.find_prefix('').values, [1])
    assert_equal(t.find_prefix('b').values, [])
  end

  # Test a compressed key with multiple values at the root.
  def test_find_compressed_key_multiple_values_at_root
    t = Trie.new.insert('ab', 1).insert('ab', 2).insert('ab', 3)
    assert_equal(t.find('ab').values.sort, [1, 2, 3])
    assert_equal(t.find('a').values, [])
    assert_equal(t.find('').values, [])
    assert_equal(t.find_prefix('ab').values.sort, [1, 2, 3])
    assert_equal(t.find_prefix('a').values.sort, [1, 2, 3])
    assert_equal(t.find_prefix('').values.sort, [1, 2, 3])
  end

  # Test a more complex Trie that contains a few compressed keys.
  def test_find_complex
    t = Trie.new.insert('a', 1).insert('ab', 2).insert('abcdef', 3).
      insert('b', 4).insert('bcd', 5).insert('b', 6).insert('bcd', 7)
    assert_equal(t.find('a').values, [1])
    assert_equal(t.find('ab').values, [2])
    assert_equal(t.find('abcdef').values, [3])
    assert_equal(t.find('b').values.sort, [4, 6])
    assert_equal(t.find('bcd').values.sort, [5, 7])
    assert_equal(t.find('bcde').values, [])
    assert_equal(t.find('').values, [])
    assert_equal(t.find_prefix('a').values, [1, 2, 3])
    assert_equal(t.find_prefix('ab').values, [2, 3])
    assert_equal(t.find_prefix('abcdef').values, [3])
    assert_equal(t.find_prefix('b').values.sort, [4, 5, 6, 7])
    assert_equal(t.find_prefix('bcd').values.sort, [5, 7])
    assert_equal(t.find_prefix('bcde').values, [])
    assert_equal(t.find_prefix('').values.sort, [1, 2, 3, 4, 5, 6, 7])
  end

  # We have a compressed key at the root and then do one-or
  # two-characters-at-a-time searches against it.
  def test_find_multiple_lookups_compressed_key
    t = Trie.new.insert('alphabet', 1)
    t2 = t.find_prefix('')
    assert_equal(t2.values, [1])
    t2 = t2.find_prefix('al')
    assert_equal(t2.values, [1])
    t2 = t2.find_prefix('p')
    assert_equal(t2.values, [1])
    t2 = t2.find_prefix('ha')
    assert_equal(t2.values, [1])
    t2 = t2.find_prefix('bet')
    assert_equal(t2.values, [1])
    t2 = t2.find_prefix('')
    assert_equal(t2.values, [1])
    t2 = t2.find_prefix('a')
    assert_equal(t2.values, [])
  end

  # We construct a trie with multiple values and then walk down it,
  # searching for one or two characters at a time.
  def test_find_multiple_lookups
    t = Trie.new.insert('happy', 1).insert('hop', 2).insert('hey', 3).
      insert('hello!', 4).insert('help', 5).insert('foo', 6)
    assert_equal(t.find_prefix('fo').values, [6])
    t2 = t.find_prefix('h')
    assert_equal(t2.values.sort, [1, 2, 3, 4, 5])
    t2 = t2.find_prefix('e')
    assert_equal(t2.values.sort, [3, 4, 5])
    assert_equal(t2.find_prefix('y').values, [3])
    t2 = t2.find_prefix('l')
    assert_equal(t2.values.sort, [4, 5])
    t2 = t2.find_prefix('lo')
    assert_equal(t2.values, [4])
    t2 = t2.find_prefix('!')
    assert_equal(t2.values, [4])
    t2 = t2.find_prefix('')
    assert_equal(t2.values, [4])
    t2 = t2.find_prefix('!')
    assert_equal(t2.values, [])
  end

  # We construct a trie with multiple elements and test the size
  # method.
  def test_size
    t = Trie.new.insert('ha', 1).insert('hat', 2).insert('hate', 3).
      insert('hated', 4).insert('test', 5)
    assert_equal(t.size, 5)
    assert_equal(t.find_prefix('ha').size, 4)
    assert_equal(t.find_prefix('hate').size, 2)
    assert_equal(t.find_prefix('test').size, 1)
    assert_equal(t.find_prefix('testing').size, 0)
  end

  # We build a trie and test the empty? method.
  def test_empty
    t = Trie.new.insert('foo', 1).insert('bar', 2).insert('food', 3)
    assert_equal(t.empty?, false)
    assert_equal(t.find('foo').empty?, false)
    assert_equal(t.find_prefix('foo').empty?, false)
    assert_equal(t.find('fool').empty?, true)
  end

  # We insert keys that are actually lists containing objects of varying
  # classes.
  def test_mixed_classes_in_keys
    t = Trie.new.insert([0, 1, 2], 0).insert([0, 'a'], 1).insert([1000], 2).
      insert([0, 'a'], 3).insert('blah', 4)
    assert_equal(t.find_prefix([0]).values.sort, [0, 1, 3])
    assert_equal(t.find_prefix([0, 1]).values, [0])
    assert_equal(t.find_prefix([0, 'a']).values.sort, [1, 3])
    assert_equal(t.find_prefix([1000]).values, [2])
    assert_equal(t.find([0]).values, [])
    assert_equal(t.find([0, 'a']).values.sort, [1, 3])
    assert_equal(t.find('blah').values, [4])
  end

  # Test delete.
  def test_delete
    t = Trie.new.insert('a', 1).insert('a', 2).insert('a', 3).
      insert('ab', 4).insert('ab', 5).insert('abc', 6)
    assert_equal(t.values.sort, [1, 2, 3, 4, 5, 6])
    t.delete('a')
    assert_equal(t.values.sort, [4, 5, 6])
    t.delete('abc')
    assert_equal(t.values.sort, [4, 5])
    t.delete('ab')
    assert_equal(t.values, [])
  end

  # Test delete_pair.
  def test_delete_pair
    t = Trie.new.insert('apple', 1).insert('apples', 2)
    assert_equal(t.find('apple').values, [1])
    assert_equal(t.find_prefix('apple').values.sort, [1, 2])
    t.delete_pair('apple', 1)
    assert_equal(t.find('apple').values, [])
    assert_equal(t.find('apples').values, [2])
    assert_equal(t.find_prefix('apple').values, [2])
    t.delete_pair('apples', 1)  # key/value pair isn't in trie
    assert_equal(t.find('apples').values, [2])
    t.delete_pair('apples', 2)
    assert_equal(t.find('apples').values, [])
  end

  # Test delete_value.
  def test_delete_value
    t = Trie.new.insert('a', 1).insert('ab', 1).insert('abc', 2).
      insert('a', 2).insert('b', 1).insert('c', 1)
    assert_equal(t.size, 6)
    t.delete_value(1)
    assert_equal(t.size, 2)
    t.delete_value(2)
    assert_equal(t.empty?, true)
  end

  # Test delete_prefix.
  def test_delete_prefix
    t = Trie.new.insert('a', 1).insert('a', 2).insert('a', 3).
      insert('ab', 4).insert('ab', 5).insert('abc', 6)
    assert_equal(t.values.sort, [1, 2, 3, 4, 5, 6])
    t.delete_prefix('ab')
    assert_equal(t.values.sort, [1, 2, 3])
    t.delete_prefix('a')
    assert_equal(t.empty?, true)
  end

  # Test clear.
  def test_clear
    t = Trie.new.insert('a', 1).insert('ab', 2)
    assert_equal(t.size, 2)
    t.clear
    assert_equal(t.empty?, true)
  end

  # Test each_key.
  def test_each_key
    t = Trie.new.insert('a', 1).insert('a', 2).insert('b', 3).insert('ab', 4)
    keys = []
    t.each_key {|k| keys.push(k.join) }
    assert_equal(keys.sort, ['a', 'ab', 'b'])
  end

  # Test each_value.
  def test_each_value
    t = Trie.new.insert('a', 1).insert('a', 2).insert('b', 1)
    values = []
    t.each_value {|v| values.push(v) }
    assert_equal(values.sort, [1, 1, 2])
  end

  # Test each.
  def test_each
    t = Trie.new.insert('a', 1).insert('a', 2).insert('b', 3).insert('ab', 4)
    pairs = []
    t.each {|k, v| pairs.push([k.join, v]) }
    assert_equal(pairs.sort, [['a', 1], ['a', 2], ['ab', 4], ['b', 3]])
  end

  # Test keys.
  def test_keys
    t = Trie.new.insert('a', 1).insert('a', 2).insert('abc', 3).insert('b', 4)
    keys = t.keys.collect {|k| k.join }.sort
    assert_equal(keys, ['a', 'abc', 'b'])
  end

  # Test the composition of the tries by using the num_nodes method.
  def test_composition
    t = Trie.new.insert('a', 1)
    assert_equal(t.num_nodes, 1)  # a
    t.insert('a', 2)
    assert_equal(t.num_nodes, 1)  # a
    t.insert('abc', 3)
    assert_equal(t.num_nodes, 3)  # '' -> a -> bc
    t.insert('ab', 4)
    assert_equal(t.num_nodes, 4)  # '' -> a -> b -> c
    t.insert('b', 5)
    assert_equal(t.num_nodes, 5)  # '' -> (a -> b -> c | b)
    t.insert('b', 6)
    assert_equal(t.num_nodes, 5)  # '' -> (a -> b -> c | b)
    t.insert('abcdef', 7)
    assert_equal(t.num_nodes, 6)  # '' -> (a -> b -> c -> def | b)
    t.insert('abcdeg', 8)
    # '' -> (a -> b -> c -> d -> e -> (f | g) | b)
    assert_equal(t.num_nodes, 9)
  end
end
