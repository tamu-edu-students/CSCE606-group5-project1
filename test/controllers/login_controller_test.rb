require "test_helper"

class LoginControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index" do
    get root_url
    assert_response :success
  end
end
