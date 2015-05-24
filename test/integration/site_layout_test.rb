require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:archer)
    @admin_user = users(:michael)
  end

  test 'layout links when not logged in' do
    get root_path
    assert_template 'static_pages/home'
    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', signup_path
    assert_select 'a[href=?]', contact_path
    assert_select 'a[href=?]', login_path
  end

  test 'layout links when logged in as normal user' do
    login_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', users_path
    assert_select 'a[href=?]', user_path(@user)
    assert_select 'a[href=?]', edit_user_path(@user)
    assert_select 'a[href=?]', signup_path, count: 0
    assert_select 'a[href=?]', contact_path
    assert_select 'a[href=?]', logout_path
  end

  test 'layout links when logged in as admin user' do

  end
end
