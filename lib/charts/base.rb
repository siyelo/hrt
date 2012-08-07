require 'active_support/core_ext/float'

module Charts

  # Common methods for constructing Chart objects
  class Base
    attr_reader :data

    # Charts are initialized with a collection of objects that respond to
    # name_method and value_method.
    # names and values are saved into @data
    def initialize(collection)
      map_data collection
    end

    ### Class methods
    class << self
      # Default method for extracting data label names from the given collection
      # The objects in the collection should respond to this
      def name_method
        :name
      end

      # Default name format for all chart name labels
      def name_format
        :capitalize
      end

      # a simple default, though subclasses will usually override this
      # e.g. project responds to :total_budget
      def value_method
        :amount
      end

      #default value format for all charts
      def value_format
        :to_f
      end
    end

    ### Instance methods
    # Json for use with a google pie chart visualization
    def google_pie
      return empty_google_pie if @data.empty?
      {
        :names => pie_legend,
        :values => pie_sort
      }.to_json
    end

    # json for use with a google bar chart visualization
    # amounts are translated into relative percentage
    def google_bar
      [
        [bar_legend].concat(bar_sort.map{ |e| e[0] }),
        [''].concat(bar_sort.map{ |e| (e[1] * 100.0 / total).round(2) })
      ].to_json
    end

    def google_column
      return empty_google_column if @data.empty?
      [
        [bar_legend].concat(column_sort.map{ |e| e[0] }),
        [''].concat(column_sort.map{ |e| (e[1] * 100.0 / total).round(2) })
      ].to_json
    end

    protected

    def map_data(collection)
      @data ||= collection.inject({}) do |result,e|
        val = e.send(self.class.value_method) || 0
        if val.to_f > 0.0
          name = e.send(self.class.name_method) || "no name"
          key = name.send(self.class.name_format)
          # in the event of duplicate keys, just add the values together
          result[key] = val.send(self.class.value_format) + (result[key] || 0)
        end
        result
      end
    end

    def empty_google_pie
      { :names => {}, :values => [] }.to_json
    end

    def empty_google_column
      [['', 'No data'],['', 0]].to_json
    end

    def total
      @total ||= @data.values.inject{|sum,x| sum + x }
    end

    def pie_legend
      {:column1 => 'Name', :column2 => 'Amount'}
    end

    def bar_legend
      'Default Bar Chart Title'
    end

    def pie_sort
      self.sort_by_values_desc
    end

    def bar_sort
      self.sort_by_name
    end

    def column_sort
      self.sort_by_values_desc[0..9]
    end

    def sort_by_values_desc
      sort_by_name.reverse.sort { |x, y| (y[1] || 0) <=> (x[1] || 0) }
    end

    def sort_by_name
      @data.sort_by { |k,v| k }
    end

  end
end
