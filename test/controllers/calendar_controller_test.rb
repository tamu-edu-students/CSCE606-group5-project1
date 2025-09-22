# require "test_helper"

# class CalendarControllerTest < ActionDispatch::IntegrationTest
#   test "should get show" do
#     open_session do |sess|
#       sess.get calendar_url
#       sess.request.session[:google_token] = "fake_token"
#       sess.request.session[:google_refresh_token] = "fake_refresh"
#       sess.get calendar_url
#       assert_includes [ 200, 302 ], sess.response.status
#     end
#   end
# end
