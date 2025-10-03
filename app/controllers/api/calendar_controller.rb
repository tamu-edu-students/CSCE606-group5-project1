require "google/apis/calendar_v3"
require "googleauth"

module Api
  class CalendarController < ApplicationController
    def events
      unless session[:google_token]
        redirect_to login_google_path, alert: "Not authenticated with Google."
        return
      end
      service = calendar_service_or_unauthorized or return

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

        redirect_to calendar_path(anchor: "calendar"), notice: "Events loaded."
      rescue Google::Apis::AuthorizationError => e
        Rails.logger.error("Calendar authorization error: #{e.message}")
        redirect_to dashboard_path(anchor: "calendar"), alert: "Failed to load events due to authorization."
      rescue => e
        Rails.logger.error("Calendar error: #{e.message}")
        redirect_to calendar_path(anchor: "calendar"), alert: "Failed to load events."
      end
    end

    # ---------- CREATE ----------
    def create
      service = calendar_service_or_unauthorized or return
      all_day = ActiveModel::Type::Boolean.new.cast(params.dig(:event, :all_day))

      # Set timezone
      Time.zone = "America/Chicago"

      # Default to current date/time if not provided
      current_time = Time.current
      current_date = current_time.to_date.to_s  # Always get current date
      start_date = params.dig(:event, :start_date).presence || current_date
      start_time = params.dig(:event, :start_time).presence || current_time.strftime("%H:%M")

      if all_day
        start_et = Google::Apis::CalendarV3::EventDateTime.new(
          date: start_date,
          time_zone: "America/Chicago"
        )
        end_et = Google::Apis::CalendarV3::EventDateTime.new(
          date: Date.parse(start_date).next_day.to_s,
          time_zone: "America/Chicago"
        )
      else
        start_datetime = Time.zone.parse("#{start_date} #{start_time}").iso8601
        start_et = Google::Apis::CalendarV3::EventDateTime.new(
          date_time: start_datetime,
          time_zone: "America/Chicago"
        )

        end_time = params.dig(:event, :end_time)
        end_datetime = if end_time.present?
                        Time.zone.parse("#{start_date} #{end_time}").iso8601
        else
                        (Time.zone.parse(start_datetime) + 30.minutes).iso8601
        end
        end_et = Google::Apis::CalendarV3::EventDateTime.new(
          date_time: end_datetime,
          time_zone: "America/Chicago"
        )
      end
      ev = Google::Apis::CalendarV3::Event.new(
        summary:     params.dig(:event, :summary),
        description: params.dig(:event, :description),
        location:    params.dig(:event, :location),
        start:       start_et,
        end:         end_et
      )

      begin
        created = service.insert_event("primary", ev)
        respond_to do |format|
          format.html { redirect_to calendar_path, notice: "Event successfully created." }
          format.json { render json: serialize_event(created), status: :created }
        end
      rescue Google::Apis::ClientError => e
        error_message = e.respond_to?(:message) ? e.message : "Failed to create event"
        Rails.logger.error("Calendar create: #{error_message}")
        respond_to do |format|
          format.html { redirect_to calendar_path, alert: error_message }
          format.json { render json: { error: error_message }, status: :unprocessable_entity }
        end
      end
    end

    # ---------- UPDATE ----------
    def update
      service = calendar_service_or_unauthorized or return
      all_day = ActiveModel::Type::Boolean.new.cast(params[:all_day])

      # Get existing event first
      event = service.get_event("primary", params[:id])

      # Create patch object with only the fields that are being updated
      patch = Google::Apis::CalendarV3::Event.new

      # Update basic fields if they are present in params
      patch.summary = params[:summary] if params[:summary].present?
      patch.description = params[:description] if params[:description].present?
      patch.location = params[:location] if params[:location].present?

      # Handle start and end times based on all_day flag
      if params[:start_time].present? || params[:start_date].present?
        Time.zone = "America/Chicago"

        if all_day
          start_date = params[:start_date].presence || params[:start_time]
          patch.start = Google::Apis::CalendarV3::EventDateTime.new(
            date: Date.parse(start_date).to_s,
            time_zone: "America/Chicago"
          )
          patch.end = Google::Apis::CalendarV3::EventDateTime.new(
            date: Date.parse(start_date).next_day.to_s,
            time_zone: "America/Chicago"
          )
        else
          datetime = if params[:start_date].present? && params[:start_time].present?
                      Time.zone.parse("#{params[:start_date]} #{params[:start_time]}")
          elsif params[:start_time].present?
                      Time.zone.parse(params[:start_time])
          else
                      Time.zone.parse(params[:start_date])
          end

          patch.start = Google::Apis::CalendarV3::EventDateTime.new(
            date_time: datetime.iso8601,
            time_zone: "America/Chicago"
          )

          if params[:end_time].present?
            end_datetime = Time.zone.parse("#{params[:start_date] || datetime.to_date} #{params[:end_time]}")
            patch.end = Google::Apis::CalendarV3::EventDateTime.new(
              date_time: end_datetime.iso8601,
              time_zone: "America/Chicago"
            )
          else
            # Default to 30 minutes later if no end time specified
            patch.end = Google::Apis::CalendarV3::EventDateTime.new(
              date_time: (datetime + 30.minutes).iso8601,
              time_zone: "America/Chicago"
            )
          end
        end
      end

      updated = service.update_event("primary", params[:id], patch)
      respond_to do |format|
        format.html { redirect_to calendar_path, notice: "Event successfully updated." }
        format.json { render json: serialize_event(updated) }
      end
    rescue Google::Apis::ClientError => e
      Rails.logger.error("Calendar update error: #{e.message}")
      respond_to do |format|
        format.html { redirect_to calendar_path, alert: "Failed to update event." }
        format.json { render json: { error: "Failed to update event" }, status: :unprocessable_entity }
      end
    end

    # ---------- DELETE ----------
    def destroy
      service = calendar_service_or_unauthorized or return
      service.delete_event("primary", params[:id])
      respond_to do |format|
        format.html { redirect_to calendar_path(anchor: "calendar"), notice: "Event deleted." }
      end
      rescue Google::Apis::ClientError => e
        Rails.logger.error("Calendar delete: #{e.message}")
        respond_to do |format|
          format.html { redirect_to calendar_path(anchor: "calendar"), alert: "Failed to delete event." }
        end
    end

    private

    # Shared: build authorized Calendar service or render 401
    def calendar_service_or_unauthorized
      unless session[:google_token].present?
        redirect_to login_google_path, alert: "Please log in with Google to continue."
        return nil
      end

      client = Signet::OAuth2::Client.new(
        access_token:         session[:google_token],
        refresh_token:        session[:google_refresh_token],
        client_id:            ENV["GOOGLE_CLIENT_ID"],
        client_secret:        ENV["GOOGLE_CLIENT_SECRET"],
        token_credential_uri: "https://oauth2.googleapis.com/token"
      )

      # Refresh if expired / near expiry (5 minutes)
      begin
        if session[:google_token_expires_at].present?
          expiry_time = Time.at(session[:google_token_expires_at].to_i)
          if expiry_time - Time.now < 300 # 5 minutes
            client.refresh!
            session[:google_token] = client.access_token
            session[:google_token_expires_at] = client.expires_at.to_i
            Rails.logger.info("Token refreshed, new expiry: #{Time.at(session[:google_token_expires_at].to_i)}")
          end
        else
          client.refresh!
          session[:google_token] = client.access_token
          session[:google_token_expires_at] = client.expires_at.to_i
        end
      rescue Signet::AuthorizationError => e
        Rails.logger.error("Token refresh failed: #{e.message}")
        reset_session
        redirect_to login_google_path, alert: "Your session expired. Please log in again."
        return nil
      end

      session[:google_token] = client.access_token
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
