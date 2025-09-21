require 'google/apis/calendar_v3'
require 'googleauth'

class CalendarController < ApplicationController
  def show
    @events = []
    if session[:google_token]
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = Signet::OAuth2::Client.new(
        access_token: session[:google_token],
        refresh_token: session[:google_refresh_token],
        client_id: ENV['GOOGLE_CLIENT_ID'],
        client_secret: ENV['GOOGLE_CLIENT_SECRET'],
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token'
      )
      calendar_id = 'primary'
      response = service.list_events(calendar_id, max_results: 10, single_events: true, order_by: 'startTime')
      @events = response.items
    end
  end
end