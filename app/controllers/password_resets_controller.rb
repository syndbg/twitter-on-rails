class PasswordResetsController < ApplicationController
  before_action :fetch_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)

    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_path
    else
      flash.now[:danger] = 'Email address not found'
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      flash.now[:danger] = 'Password can\'t be empty'
      render 'edit'
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def fetch_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    redirect_to root_url unless @user && @user.activated? &&
                                @user.authenticated?(:reset, params[:id])
  end

  def check_expiration
    redirect_to root_url unless @user && @user.activated? &&
                                @user.authenticated?(:reset, params[:id])
    flash[:danger] = 'Password reset has expired.'
    redirect_to new_password_reset_path
  end
end
