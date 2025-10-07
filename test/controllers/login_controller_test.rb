require "test_helper"

class LoginControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index for guest user" do
    get root_url
    assert_response :success
  end

  test "should redirect authenticated user to dashboard" do
    user = users(:one)
    sign_in user
    get root_url
    assert_response :redirect
    assert_redirected_to dashboard_path
  end
end