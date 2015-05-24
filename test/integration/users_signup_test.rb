require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
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

  test 'valid signup information' do
    get signup_path

    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name: 'Example User',
                                            email: 'user@example.com',
                                            password: 'password',
                                            password_confirmation: 'password' }
    end
    assert logged_in?

    assert_template 'users/show'
    assert_not_nil flash
    assert flash.key?(:success)
    assert_select 'div.message_explanation'
    assert_select 'div.alert-success'
  end
end
