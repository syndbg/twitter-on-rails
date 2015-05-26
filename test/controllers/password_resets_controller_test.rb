require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  def setup
    @user = users(:michael)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should redirect edit if not logged in, unactivated account and expired token' do
    # not logged in
    get :edit
    assert_response :redirect
    # logged but no reset token
    login_as(@user)
    get :edit
    assert_response :redirect
    # logged in but not activated
    @user.activated = false
    get :edit
    assert_response :redirect
  end
end
