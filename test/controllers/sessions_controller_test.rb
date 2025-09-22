require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get sessions_create_url
    assert_response :redirect
    assert_includes [200, 302], response.status
  end

  test "should get failure" do
    get sessions_failure_url
    assert_includes [200, 302], response.status
  end

  test "should destroy session and redirect" do
    delete logout_url
    assert_includes [200, 302], response.status
  end
end
