require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com',
                     password: 'example', password_confirmation: 'example')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should not be blank' do
    @user.name = '    '
    assert_not @user.valid?, 'User.name is blank'
  end

  test 'email should not be blank' do
    @user.email = '    '
    assert_not @user.valid?, 'User.email is blank'
  end

  test 'name should not be too long' do
    @user.name = 'a' * 100
    assert_not @user.valid?, 'User.name is too long'
  end

  test 'email should not be too long' do
    @user.email = 'mail' * 250 + '@example.com'
    assert_not @user.valid?, 'User.email is too long'
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'email addresses should be case-insensitive unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lowercase' do
    @user.email = 'ExAmPle@exAmple.com'
    @user.save
    assert @user.valid?
    assert_equal @user.reload.email, 'example@example.com'
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?(nil)
    assert_not @user.authenticated?('')
  end
end
