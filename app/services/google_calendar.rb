require "time"
require "date"

class GoogleCalendar
  # Determines if `now` (Time) falls inside the given Google Calendar `event`.
  # Accepts events with:
  # - event.start.date / event.end.date  (all-day events; end.date is exclusive)
  # - event.start.date_time / event.end.date_time (timestamp events)
  #
  # Signature: GoogleCalendar.in_event?(event, now = Time.now) => Boolean
  def self.in_event?(event, now = Time.now)
    return false unless event && event.respond_to?(:start) && event.respond_to?(:end)

    start_field = event.start
    end_field   = event.end

    # all-day event (date-only); Google uses exclusive end.date
    if start_field.respond_to?(:date) && start_field.date
      begin
        start_date = Date.parse(start_field.date.to_s)
        end_date = Date.parse(end_field.date.to_s)
      rescue StandardError
        return false
      end
      now_date = (now || Time.now).to_date
      return (now_date >= start_date) && (now_date < end_date)
    end

    # date_time event (with timestamps / timezones)
    if start_field.respond_to?(:date_time) && start_field.date_time
      begin
        start_time = parse_time(start_field.date_time)
        end_time   = parse_time(end_field.date_time)
        return false unless start_time && end_time
        now_time = now || Time.now
        return (now_time >= start_time) && (now_time < end_time)
      rescue StandardError
        return false
      end
    end

    false
  end

  private_class_method def self.parse_time(value)
    return value if value.is_a?(Time)
    return Time.iso8601(value) if value.is_a?(String) && value.match?(/\d{4}-\d{2}-\d{2}T/)
    return Time.parse(value.to_s) if value
    nil
  end
end
