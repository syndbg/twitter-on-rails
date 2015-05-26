require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:michael)
    @user = users(:archer)
  end

  test 'should redirect to root_path if /:id is non-existing user or not activated' do
    login_as(@admin_user)
    # non-existing
    get user_path(9999)
    assert_redirected_to root_path
    # not-activated
    @user.toggle!(:activated)
    get user_path(@user.reload)
    assert_redirected_to root_path
  end

  test 'should have index including pagination and delete actions for admin users' do
    login_as(@admin_user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'

    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user.admin?
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
  end

  test 'should have index including pagination and no delete actions for non-admin users' do
    login_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'

    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      assert_select 'a', text: 'delete', count: 0
    end
  end
end
