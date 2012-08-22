class LookAheadTrie < Trie

  def paths
    @children.collect { |c| c[0] + c[1].longest_path }
  end
  
  def steps 
    @children.collect { |c| c[0] }
  end

  def linear?
    @children.size == 1 && @values.size == 0
  end

  def longest_path
    return "" unless linear?
    child = @children.first
    return child[0] + child[1].longest_path
  end

end
