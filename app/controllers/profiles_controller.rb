class ProfilesController < ApplicationController
  before_filter :require_user, :load_user

  def disable_tips
    @user.tips_shown = false
    @user.save
    render :nothing => true
  end

  private
    def load_user
      @user = current_user
    end
end
