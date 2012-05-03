class Admin::BaseController < ApplicationController
  before_filter :require_admin

  before_filter :set_latest_response

  private
    def set_latest_response
      set_response(last_response)
    end
end
