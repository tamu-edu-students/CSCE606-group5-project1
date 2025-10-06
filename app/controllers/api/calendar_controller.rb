require "google/apis/calendar_v3"
require "googleauth"

module Api
  class CalendarController < ApplicationController
    before_action :ensure_event_name_present, only: [ :create, :update ]
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
      start_time_param = params.dig(:event, :start_time).presence || current_time.strftime("%H:%M")

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
        # === ADD LeetCodeSession creation ===
        start_time = if all_day
                      Date.parse(start_date).beginning_of_day.in_time_zone("America/Chicago")
                    else
                      Time.zone.parse("#{start_date} #{start_time_param}")
                    end

        end_time = if all_day
                    Date.parse(start_date).end_of_day.in_time_zone("America/Chicago")
                  else
                    Time.zone.parse(end_et.date_time || (start_time + 30.minutes).iso8601)
                  end

        duration_minutes = [(end_time - start_time) / 60, 1].max.to_i

        LeetCodeSession.create!(
          user_id: current_user.id,
          google_event_id: created.id,
          title: params.dig(:event, :summary).presence || "Untitled Session",
          description: params.dig(:event, :description),
          scheduled_time: start_time,
          duration_minutes: duration_minutes,
          status: if end_time < Time.current
                    "completed"
                  else
                    "scheduled"
                  end
        )
        # === END LeetCodeSession creation ===
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

      event_params = params.require(:event).permit(:summary, :start_date, :start_time, :end_time, :location, :description, :all_day)

      all_day = ActiveModel::Type::Boolean.new.cast(event_params[:all_day])

      # Get existing event first
      event = service.get_event("primary", params[:id])

      # Create patch object with only the fields that are being updated
      patch = Google::Apis::CalendarV3::Event.new

      # Update basic fields if they are present in params
      patch.summary = event_params[:summary] if event_params[:summary].present?
      patch.description = event_params[:description] if event_params[:description].present?
      patch.location = event_params[:location] if event_params[:location].present?


      # Handle start and end times based on all_day flag
      if event_params[:start_time].present? || event_params[:start_date].present?
        Time.zone = "America/Chicago"

        if all_day
          start_date = event_params[:start_date].presence || event_params[:start_time]
          patch.start = Google::Apis::CalendarV3::EventDateTime.new(
            date: Date.parse(start_date).to_s
          )
          patch.end = Google::Apis::CalendarV3::EventDateTime.new(
            date: Date.parse(start_date).next_day.to_s
          )
        else
          datetime = if event_params[:start_date].present? && event_params[:start_time].present?
                Time.zone.parse("#{event_params[:start_date]} #{event_params[:start_time]}")
          elsif event_params[:start_time].present?
                Time.zone.parse(event_params[:start_time])
          else
                Time.zone.parse(event_params[:start_date])
          end

          patch.start = Google::Apis::CalendarV3::EventDateTime.new(
            date_time: datetime.iso8601,
            time_zone: "America/Chicago"
          )

          if event_params[:end_time].present?
            end_datetime = Time.zone.parse("#{event_params[:start_date] || datetime.to_date} #{event_params[:end_time]}")
            patch.end = Google::Apis::CalendarV3::EventDateTime.new(
              date_time: end_datetime.iso8601,
              time_zone: "America/Chicago"
            )
          else
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
    def ensure_event_name_present
      # Works whether your form posts under params[:event] or flat params
      name = params.dig(:event, :summary).presence || params[:summary].presence
      return if name.to_s.strip.present?

      msg = "Event name is required."
      respond_to do |format|
        format.html { redirect_back fallback_location: calendar_path, alert: msg }
        format.json { render json: { error: msg }, status: :unprocessable_entity }
      end
    end

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
        token_credential_uri: ENV["GOOGLE_OAUTH_URI"]
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
