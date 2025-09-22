require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_url
    assert_includes [ 200, 302 ], response.status
  end
end
