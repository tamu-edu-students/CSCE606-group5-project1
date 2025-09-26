require "test_helper"

class LeetCodeSessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get leet_code_sessions_index_url
    assert_response :success
  end

  test "should get show" do
    get leet_code_sessions_show_url
    assert_response :success
  end

  test "should get new" do
    get leet_code_sessions_new_url
    assert_response :success
  end

  test "should get edit" do
    get leet_code_sessions_edit_url
    assert_response :success
  end
end
