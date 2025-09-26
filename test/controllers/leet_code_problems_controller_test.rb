require "test_helper"

class LeetCodeProblemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get leet_code_problems_index_url
    assert_response :success
  end

  test "should get show" do
    get leet_code_problems_show_url
    assert_response :success
  end

  test "should get new" do
    get leet_code_problems_new_url
    assert_response :success
  end

  test "should get edit" do
    get leet_code_problems_edit_url
    assert_response :success
  end
end
