require 'test_helper'

class UsersLogoutTest < ActionDispatch::IntegrationTest

    def setup
      @user = users :michael
    end

    test 'login with valid information then logout' do
      get login_path
      post login_path, session: { email: @user.email, password: 'password' }
      assert logged_in?

      delete logout_path
      assert_not logged_in?
      assert_redirected_to root_path
      # Simulate a user clicking logout in a second window.
      delete logout_path
      follow_redirect!
      assert_select 'a[href=?]', login_path
      assert_select 'a[href=?]', logout_path, count: 0
      assert_select 'a[href=?]', user_path(@user), count: 0
    end

    test 'logout without login beforehand' do

    end
end
