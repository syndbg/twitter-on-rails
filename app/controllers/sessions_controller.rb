class SessionsController < ApplicationController
  def new
  end

  def create
    session_data = params.require(:session)
    @user = User.find_by(email: session_data[:email].downcase)

    if @user && @user.authenticate(session_data[:password])
      log_in @user
      session_data[:remember_me] == '1' ? remember(@user) : forget(@user)
      flash.now[:success] = 'Logged in!'
      redirect_back_or @user
    else
      flash.now[:danger] = 'Invalid username or password. Try again!'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end
