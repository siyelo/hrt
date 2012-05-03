class Reports::InputsController < ApplicationController

  def index
    @current_response = current_response
    @report = Reports::Input.new(@current_response)

    respond_to do |format|
      format.js {
        render :layout => false }
    end
  end
end
