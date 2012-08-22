SPEC = Gem::Specification.new do |s|
  s.name          = "trie"
  s.version       = "0.0.2"
  s.author        = "Daniel Erat"
  s.email         = "dan-ruby@erat.org"
  s.homepage      = "http://www.erat.org/ruby/"
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Implemention of a trie data structure"
  candidates      = %w(COPYING INSTALL MANIFEST README setup.rb trie.gemspec lib/trie.rb lib/trie/extensions/look_ahead_trie.rb test/tests.rb test/extensions/look_ahead_trie_tests.rb)
  s.files         = candidates.delete_if {|i| i =~ /CVS/ }
  s.require_path  = "lib"
  s.test_file     = "test/tests.rb"
  s.has_rdoc      = true
end
