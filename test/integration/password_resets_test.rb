require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test 'emails token with password and instructions if existing email' do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: @user.email }

    @user = assigns(:user)
    assert_not_nil @user.reset_token
    assert_not_nil @user.reset_digest
    assert flash.key?(:info)
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_redirected_to root_path
  end

  test 'does not email token with password and instructions if non-existant email' do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: 'rails' }

    @user = assigns(:user)
    assert_nil @user
    assert flash.key?(:danger)
    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_template 'password_resets/new'
  end

  test 'expired token' do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: @user.email }

    @user = assigns(:user)
    @user.update(reset_sent_at: 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          email: @user.email,
          user: { password: 'foobar',
                  password_confirmation: 'foobar' }
    assert_response :redirect
    follow_redirect!
    assert 'static_pages/home'
  end
end
