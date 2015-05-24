require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unsuccessful edit' do
    login_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'

    patch user_path(@user), user: { name: '',
                                    email: 'foo@invalid',
                                    password: 'foo',
                                    password_confirmation: 'bar' }
    assert_template 'users/edit'
  end

  test 'successful edit' do
    login_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'

    name = 'Foo Bar'
    email = 'foo@bar.com'
    patch user_path(@user), user: { name: name,
                                    email: email,
                                    password: '',
                                    password_confirmation: '' }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    # confirm that the url is remembered
    assert_equal edit_user_url(@user), session[:forwarding_url]
    login_as(@user)
    assert logged_in?
    # confirm that the url is cleared and redirected to
    assert_nil session[:forwarding_url]
    assert_redirected_to edit_user_path(@user)
    # confirm that further logins won't remember position
    get edit_user_path(@user)
    assert_nil session[:forwarding_url]
    assert logged_in?

    name  = 'Foo Bar'
    email = 'foo@bar.com'
    patch user_path(@user), user: { name: name,
                                    email: email,
                                    password: '',
                                    password_confirmation: '' }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end
