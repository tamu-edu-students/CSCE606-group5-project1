require "test_helper"
require "securerandom"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get index" do
    skip("Users UI is disabled")
    get users_url
    assert_response :success
  end

  test "should get new" do
    skip("Users UI is disabled")
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    skip("Users UI is disabled")
    assert_difference("User.count") do
      post users_url, params: { user: { email: "user_#{SecureRandom.hex(4)}@example.com", first_name: @user.first_name, last_login_at: @user.last_login_at, last_name: @user.last_name, netid: "netid_#{SecureRandom.hex(4)}", role: @user.role } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    skip("Users UI is disabled")
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    skip("Users UI is disabled")
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    skip("Users UI is disabled")
    patch user_url(@user), params: { user: { email: @user.email, first_name: @user.first_name, last_login_at: @user.last_login_at, last_name: @user.last_name, netid: @user.netid, role: @user.role } }
    assert_redirected_to user_url(@user)
  end

  test "should destroy user" do
    skip("Users UI is disabled")
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
