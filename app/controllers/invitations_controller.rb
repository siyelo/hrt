class InvitationsController < ApplicationController

  layout 'promo_landing'

  before_filter :find_user

  def edit
    sign_out(current_user)
    redirect_to root_url unless @user
  end

  def update
    if @user
      @user.attributes = params[:user]
      if @user.activate
        flash[:notice] = "Thank you for registering with the Health Resource Tracker!"
        sign_in(@user)
        redirect_to dashboard_path
      else
        render :edit
      end
    else
      flash[:error] = "Sorry, the invitation is no longer valid."
      redirect_to root_url
    end
  end

  private
  def find_user
    @user = User.find_by_invite_token(params[:id])
  end
end
