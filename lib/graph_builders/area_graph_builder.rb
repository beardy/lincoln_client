class AreaGraphBuilder < GraphBuilder

  def get_graph_element(e)
    ge = AreaHollow.new
    ge.fill = e.color
    ge.fill_alpha = 1
    ge
  end

  def get_graph_value(v)
    gv = DotValue.new(v.value, v.color)
    gv
  end
  
end
