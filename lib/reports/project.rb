require_relative 'base'
require 'active_support/core_ext/float'

module Reports
  class Project < Reports::Base
    def collection
      mark_duplicates(@resource.activities.sorted)
    end

    def resource_link(element)
      reports_activity_path(element)
    end

    def chart_links
      elements = Hash.new("")
      collection.each do |c|
        elements[c.try(:name).to_s.downcase.capitalize] = c.link_path
      end
      elements.to_json
    end
  end
end
