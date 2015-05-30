require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'micropost interface' do
    login_as(@user)
    get root_path
    assert_select 'div.pagination'
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, micropost: { content: '' }
    end
    assert_select 'div.message_explanation'
    # Valid submission
    content = 'This micropost really ties the room together'
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content }
    end
    assert_redirected_to root_path
    follow_redirect!
    assert_match content, response.body
    # Has a delete action
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    # Delete a post.
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit a different user
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  test 'micropost sidebar count' do
    login_as(@user)
    get root_path
    assert_match(/#{@user.microposts.count} microposts/, response.body)
    # User with zero microposts
    other_user = users(:mallory)
    login_as(other_user)
    get root_path
    assert_match '0 microposts', response.body
    # Create a micropost.
    other_user.microposts.create!(content: 'A micropost')
    get root_path
    assert_match(/1 micropost\b/, response.body)
  end

  test 'micropost picture upload' do
    login_as(@user)
    get root_path
    assert_select 'input[type=file]'
    content = 'ruby ruby ruby'
    picture = fixture_file_upload('test/fixtures/ruby.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content, picture: picture}
    end

    assert @user.microposts.first.picture?
  end
end
