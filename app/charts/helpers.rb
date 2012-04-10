module Charts::Helpers
  def get_virtual_codes(activities, virtual_type)
    codes = []
    assignments = activities.collect{|a| a.send(virtual_type)}.flatten
    assignments.group_by {|a| a.code}.each do |code, array|
      row = [code.short_display, array.inject(0) {|sum, v| sum + v.cached_amount}]
      def row.value
        self[1]
      end
      def row.name
        self[0]
      end
      codes << row if row.value > 0
    end
    codes
  end
end
