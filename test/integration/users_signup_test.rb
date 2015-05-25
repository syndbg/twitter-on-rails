require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup information' do
    get signup_path

    assert_no_difference 'User.count' do
      post users_path, user: { name: '',
                               email: 'user@invalid',
                               password: 'foo',
                               password_confirmation: 'bar' }
    end
    assert_not logged_in?

    assert_template 'users/new'
    assert_select 'div.message_explanation'
    assert_select 'div.alert-danger'
  end

  test 'valid signup information without or with wrong account activation' do
    get signup_path

    assert_difference 'User.count', 1 do
      post users_path, user: { name: 'Example User',
                               email: 'user@example.com',
                               password: 'password',
                               password_confirmation: 'password' }
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    assert flash.key?(:info)
    # login before activation
    login_as(user)
    assert flash.key?(:warning)
    assert_not logged_in?
    # activate with invalid activation_token
    get edit_account_activation_path('cool token')
    assert flash.key?(:danger)
    assert_not logged_in?
    # activate with valid token, but invalid email
    get edit_account_activation_path(user.activation_token, email: 'cool@email.com')
    assert flash.key?(:danger)
    assert_not logged_in?
  end

  test 'valid signup information with account activation' do
    get signup_path

    assert_difference 'User.count', 1 do
      post users_path, user: { name: 'Example User',
                               email: 'user@example.com',
                               password: 'password',
                               password_confirmation: 'password' }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    assert flash.key?(:info)
    # activate account
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert logged_in?
  end
end
