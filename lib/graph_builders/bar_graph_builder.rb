class BarGraphBuilder < GraphBuilder

  def get_graph_element(e)
    ge = Bar.new
    ge.colours = e.colors
    ge
  end

  def get_graph_value(v)
    gv = BarValue.new(v.value)
    gv
  end

end
