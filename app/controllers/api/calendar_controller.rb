require "google/apis/calendar_v3"
require "googleauth"

module Api
  class CalendarController < ApplicationController
    def events
      unless session[:google_token]
        return render json: { error: "Not authenticated" }, status: :unauthorized
      end

      client = Signet::OAuth2::Client.new(
        access_token: session[:google_token],
        refresh_token: session[:google_refresh_token],
        expires_at: session[:google_token_expires_at],
        client_id: ENV["GOOGLE_CLIENT_ID"],
        client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        token_credential_uri: "https://oauth2.googleapis.com/token"
      )

      # Refresh token if expired or about to expire
      begin
        client.refresh! if client.expired? || client.expires_at < Time.now + 120
      rescue Signet::AuthorizationError => e
        Rails.logger.error("Token refresh failed: #{e.message}")
        return render json: { error: "Authentication expired, please login again" }, status: :unauthorized
      end

      # Update session with new token
      session[:google_token] = client.access_token
      session[:google_refresh_token] ||= client.refresh_token

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client

      calendar_id = "primary"
      start_time = params[:start_date] || Time.now.beginning_of_month.iso8601
      end_time   = params[:end_date] || Time.now.end_of_month.iso8601

      begin
        response = service.list_events(
          calendar_id,
          single_events: true,
          order_by: "startTime",
          time_min: start_time,
          time_max: end_time,
          max_results: 50
        )

        events = response.items.map do |event|
          {
            id: event.id,
            summary: event.summary,
            start: event.start&.date_time || event.start&.date,
            end: event.end&.date_time || event.end&.date,
            location: event.location,
            description: event.description
          }
        end

        render json: events
      rescue Google::Apis::AuthorizationError => e
        Rails.logger.error("Calendar authorization error: #{e.message}")
        render json: { error: "Failed to load events due to authorization" }, status: :unauthorized
      rescue => e
        Rails.logger.error("Calendar error: #{e.message}")
        render json: { error: "Failed to load events" }, status: :internal_server_error
      end
    end

    # ---------- CREATE ----------
    def create
      service = calendar_service_or_unauthorized or return

      all_day  = ActiveModel::Type::Boolean.new.cast(params.dig(:event, :all_day))
      start_et = event_time(params.dig(:event, :start_time), all_day)

      end_et =
        if all_day
          # all-day: Google expects end = next day (exclusive)
          sd = Date.parse(params.dig(:event, :start_time)) rescue nil
          ed = params.dig(:event, :end_time).present? ? (Date.parse(params.dig(:event, :end_time)) rescue nil) : sd
          Google::Apis::CalendarV3::EventDateTime.new(date: ed&.+(1)&.iso8601)
        else
          event_time(params.dig(:event, :end_time), false)
        end

      ev = Google::Apis::CalendarV3::Event.new(
        summary:     params.dig(:event, :summary),
        description: params.dig(:event, :description),
        location:    params.dig(:event, :location),
        start:       start_et,
        end:         end_et
      )

      created = service.insert_event("primary", ev)
      respond_to do |format|
      format.json { render json: serialize_event(created), status: :created }
      format.html { redirect_to dashboard_path(anchor: "calendar"), notice: "Event created." }
      end
      
      rescue Google::Apis::ClientError => e
        Rails.logger.error("Calendar create: #{e.message}")
        respond_to do |format|
          format.json { render json: { error: "Failed to create event" }, status: :unprocessable_entity }
          format.html { redirect_to dashboard_path(anchor: "calendar"), alert: "Failed to create event." }
        end
    end

    # ---------- UPDATE ----------
    def update
      service = calendar_service_or_unauthorized or return

      # allow a checkbox or infer all-day from YYYY-MM-DD
      all_day_param = ActiveModel::Type::Boolean.new.cast(params.dig(:event, :all_day))
      infer_all_day = ->(raw) { raw.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/) }
      all_day = all_day_param

      patch = Google::Apis::CalendarV3::Event.new(
        summary:     params.dig(:event, :summary),
        description: params.dig(:event, :description),
        location:    params.dig(:event, :location)
      )

      if params.dig(:event, :start_time).present?
        all_day ||= infer_all_day.call(params.dig(:event, :start_time))
        patch.start = event_time(params.dig(:event, :start_time), all_day)
      end

      if params.dig(:event, :end_time).present? || all_day
        patch.end =
          if all_day
            sd = Date.parse(params.dig(:event, :start_time)) rescue nil
            ed = params.dig(:event, :end_time).present? ? (Date.parse(params.dig(:event, :end_time)) rescue nil) : sd
            Google::Apis::CalendarV3::EventDateTime.new(date: ed&.+(1)&.iso8601)
          else
            event_time(params.dig(:event, :end_time), false)
          end
      end

      updated = service.update_event("primary", params[:id], patch)
      respond_to do |format|
        format.json { render json: serialize_event(updated), status: :ok }
        format.html { redirect_to dashboard_path(anchor: "calendar"), notice: "Event updated." }
      end
    rescue Google::Apis::ClientError => e
      Rails.logger.error("Calendar update: #{e.message}")
      respond_to do |format|
        format.json { render json: { error: "Failed to update event" }, status: :unprocessable_entity }
        format.html { redirect_to dashboard_path(anchor: "calendar"), alert: "Failed to update event." }
      end
    end

    # ---------- DELETE ----------
    def destroy
      service = calendar_service_or_unauthorized or return
      service.delete_event("primary", params[:id])
      respond_to do |format|
        format.json { render json: { message: "Event deleted" }, status: :ok }
        format.html { redirect_to dashboard_path(anchor: "calendar"), notice: "Event deleted." }
      end
      rescue Google::Apis::ClientError => e
        Rails.logger.error("Calendar delete: #{e.message}")
        respond_to do |format|
          format.html { redirect_to dashboard_path(anchor: "calendar"), alert: "Failed to delete event." }
          format.json { render json: { error: "Failed to delete event" }, status: :unprocessable_entity }
        end
    end

    private

    # Shared: build authorized Calendar service or render 401
    def calendar_service_or_unauthorized
      unless session[:google_token].present?
        render json: { error: "Not authenticated" }, status: :unauthorized
        return nil
      end

      client = Signet::OAuth2::Client.new(
        access_token:         session[:google_token],
        refresh_token:        session[:google_refresh_token],
        client_id:            ENV["GOOGLE_CLIENT_ID"],
        client_secret:        ENV["GOOGLE_CLIENT_SECRET"],
        token_credential_uri: "https://oauth2.googleapis.com/token"
      )

      # Refresh if expired / near expiry (2 minutes)
      begin
        if client.respond_to?(:expires_at)
          client.refresh! if client.expired? || client.expires_at.to_i <= (Time.now + 120).to_i
        else
          client.refresh! if client.expired?
        end
      rescue Signet::AuthorizationError => e
        Rails.logger.error("Token refresh failed: #{e.message}")
        reset_session
        render json: { error: "Authentication expired, please login again" }, status: :unauthorized
        return nil
      end

      session[:google_token]          = client.access_token
      session[:google_refresh_token] ||= client.refresh_token

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      service
    end

    # Build an EventDateTime for all-day or timed events.
    def event_time(raw, all_day)
      return nil if raw.blank?

      if all_day || raw.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)
        d = Date.parse(raw) rescue nil
        return Google::Apis::CalendarV3::EventDateTime.new(date: d&.iso8601)
      end

      t = Time.zone.parse(raw) rescue nil
      Google::Apis::CalendarV3::EventDateTime.new(
        date_time: t&.iso8601,
        time_zone: Time.zone.name
      )
    end

    def serialize_event(event)
      {
        id:          event.id,
        summary:     event.summary,
        start:       event.start&.date_time || event.start&.date,
        end:         event.end&.date_time   || event.end&.date,
        location:    event.location,
        description: event.description
      }
    end
  end
end
