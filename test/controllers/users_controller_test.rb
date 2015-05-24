require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should redirect edit when not logged in' do
    get :edit, id: @user.id
    assert_not flash.empty?
    assert_equal 'Please log in.', flash[:danger]
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch :update, id: @user.id, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_equal 'Please log in.', flash[:danger]
    assert_redirected_to login_url
  end

  test 'should redirect index when not logged in' do
    get :index
    assert_redirected_to login_path
  end

  test 'should redirect edit when logged in as wrong user' do
    login_as(@other_user)
    get :edit, id: @user.id
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect update when logged in as wrong user' do
    login_as(@other_user)
    patch :update, id: @user.id, user: { name: @user.name, email: @user.email }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user.id
    end
    assert_redirected_to login_path
  end

  test 'should redirect destroy when not logged in as admin' do
    login_as(@other_user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user.id
    end
    assert_redirected_to root_path
  end

  test 'should delete user when logged in as admin' do
    login_as(@user)
    assert_difference 'User.count', -1 do
      delete :destroy, id: @other_user.id
    end
    assert_redirected_to users_path
  end

  test 'should not allow the admin attribute to be edited via the web' do
   login_as(@other_user)
   assert_not @other_user.admin?
   patch :update, id: @other_user, user: { password: 'password',
                                           password_confirmation: 'password',
                                           admin: true }
   assert_not @other_user.reload.admin?
 end
end
