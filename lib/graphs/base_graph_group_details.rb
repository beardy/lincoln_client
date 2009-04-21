module BeardGraph
  #
  # Base Graph for all "Group Details" graphs
  #
  class BaseGraphGroupDetails < BaseGraph
  
    def preprocess(groups)
      # initialize graph data
	  @data.elements["Incoming"] = GraphElement.new("Incoming", @data.num_values)
	  @data.elements["Outgoing"] = GraphElement.new("Outgoing", @data.num_values)
	  
	  # convert RGB to HSL
	  hsl = Color.rgb_to_hsl(Color.hex_to_rgb(groups.first.color))
	  
	  # calculate light and dark shades
	  if hsl[2] <= 0.5
		hsl[2] = hsl[2] + 0.15 # more light
		light_shade = Color.rgb_to_hex(Color.hsl_to_rgb(hsl))
		dark_shade = groups.first.color
	  else
		hsl[2] = hsl[2] - 0.15 # less light
		light_shade = groups.first.color
		dark_shade = Color.rgb_to_hex(Color.hsl_to_rgb(hsl))
	  end
	  
	  # update graph colors
	  @data.elements["Incoming"].color = "##{light_shade}"
	  @data.elements["Outgoing"].color = "##{dark_shade}"
    end
    
  end
end
