module ShanShan; class Spider

  def initialize(uri:)
    @center = Node.new(uri:URI.parse(uri))
  end

  def spin(depth:0)
    @center.children(depth:depth)
  end

end; end
