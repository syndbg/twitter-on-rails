require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users :michael
  end

  test 'login with invalid information' do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: '', password: '' }
    assert_not logged_in?

    assert_template 'sessions/new'
    assert_not flash.empty?
    assert flash.key?(:danger)

    get root_path
    assert flash.empty?
    assert_not flash.key?(:danger)
  end

  test 'login with valid information' do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: @user.email, password: 'password' }
    assert logged_in?

    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
  end

  test 'login without remembering' do
    login_as(@user, remember_me: '0')
    assert_nil assigns(:user).remember_token
    assert cookies['remember_token'].blank? || cookies['remember_token'].nil?
  end

  test 'login and remember me' do
    login_as(@user, remember_me: '1')
    assert_not_nil assigns(:user).remember_token
    assert_not cookies['remember_token'].blank? || cookies['remember_token'].nil?
  end
end
