module Charts::JsonHelpers
  class << self
    def prepare_pie_values_json(records)
      values = []
      other = 0.0

      if records
        records.each_with_index do |record, index|
          if index < 10
            values << [safe_sql_name_alias(record), record.value.to_f.round(2)]
          else
            other += record.value.to_f
          end
        end
      end

      values << ['Other', other.round(2)] if other > 0

      build_pie_values_json(values)
    end

    def build_pie_values_json(values)
      if values.present?
        {
          :names => {:column1 => 'Name', :column2 => 'Amount'},
          :values => values
        }.to_json
      else
        build_empty_pie_values_json
      end
    end

    def build_empty_pie_values_json
      { :names => {}, :values => [] }.to_json
    end

    private

    # In postgres, you can't sql alias something if its also a
    # column - Group By will fail.. But we still want to use
    # AR convenient alias 'methods' on the result set objects.
    # So for those columns,  we use a different alias
    def safe_sql_name_alias(record)
      name = record.respond_to?(:name) ? record.name : record.name_or_descr
    end
  end
end
