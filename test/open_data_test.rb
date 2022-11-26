require 'test_helper'

class OpenDataTest < Test::Unit::TestCase

  setup do
    @open_data = OpenData.instance
  end

  def test_root_node_is_akita_prefecture
    node = @open_data.node.children.first.last
    assert_equal 1, node.children.size
    assert_equal '秋田県', node.name
  end

  def test_second_layer_node_is_akita_city
    node = @open_data.node.children.first.last.children.first.last
    assert_equal 212, node.children.size
    assert_equal '秋田市', node.name
  end

end
