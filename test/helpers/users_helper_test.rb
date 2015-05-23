require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  def setup
    @user = User.new(name: 'test', email: 'test@test.com')
  end

  test 'gravatar for' do
    assert_contains 'https://secure.gravatar.com/avatar/', gravatar_for(@user)
  end

  test 'gravatar for size' do
    size = 150
    assert_contains "s=#{size}", gravatar_for(@user, size: size)
  end
end
