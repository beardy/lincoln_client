class PieGraphBuilder < GraphBuilder

  def get_graph_element(e)
    ge = Pie.new
    ge.colours = e.colors
    ge
  end

  def get_graph_value(v)
    gv = PieValue.new(v.value, v.color)
    gv.label = v.label
    gv
  end

end
