require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    # remember(@user)
    log_in @user
  end

  # Does this belong here?
  test "current_user returns right user when logged in" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  # test "current_user returns nil when remember digest is wrong" do
  #   @user.update_attribute(:remember_digest, User.digest(User.new_token))
  #   assert_nil current_user
  # end
end