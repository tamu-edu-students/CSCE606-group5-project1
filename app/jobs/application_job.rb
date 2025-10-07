# Base class for all background jobs in the application
# Inherits from ActiveJob::Base and provides common configuration for all jobs
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # Uncomment the line below to enable automatic retry on database deadlocks
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # Uncomment the line below to discard jobs when records can't be deserialized
  # discard_on ActiveJob::DeserializationError
end
