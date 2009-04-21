module BeardGraph
  #
  # Base Graph for all "All Groups" graphs
  #
  class BaseGraphAllGroups < BaseGraph
  
    def preprocess(groups)
      # initialize graph data
      groups.each do |group|
        @data.elements[group.name] = GraphElement.new(group.name, @data.num_values)
        @data.elements[group.name].color = "##{group.color}"
      end
    end
    
  end
end
