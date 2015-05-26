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

  test 'password resets' do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # Invalid email
    post password_resets_path, password_reset: { email: "" }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Valid email
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token),
          email: user.email,
          user: { password:              "foobaz",
                  password_confirmation: "barquux" }
    assert_select 'div#error_explanation'
    # Empty password
    patch password_reset_path(user.reset_token),
          email: user.email,
          user: { password:              "",
                  password_confirmation: "" }
    assert_not flash.empty?
    assert_template 'password_resets/edit'
    # Valid password & confirmation
    patch password_reset_path(user.reset_token),
          email: user.email,
          user: { password:              "foobaz",
                  password_confirmation: "foobaz" }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end
