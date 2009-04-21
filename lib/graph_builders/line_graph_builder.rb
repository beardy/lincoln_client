class LineGraphBuilder < GraphBuilder

  def get_graph_element(e)
    ge = LineDot.new
    ge
  end

  def get_graph_value(v)
    gv = DotValue.new(v.value, v.color)
    gv
  end
  
end
