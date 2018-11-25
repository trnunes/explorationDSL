module Filter
  class And < CompositeFilter

    def filter(node, child_filters = @filters)
      child_filters.inject{|previous_boolean, filter| previous_boolean && filter.filter(node)}
    end
  end
end
