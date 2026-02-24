class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Clear stale DB connections and retry when Postgres connection was closed (e.g. Fly.io machine slept)
  rescue_from(ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad) do |exception|
    ActiveRecord::Base.connection_handler.clear_all_connections!
    raise exception
  end
  retry_on ActiveRecord::ConnectionNotEstablished, wait: 5.seconds, attempts: 2
  retry_on PG::ConnectionBad, wait: 5.seconds, attempts: 2

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
