# frozen_string_literal: true

# Rescues stale PostgreSQL connections (e.g. after Fly.io machine sleep).
# Clears the connection pool and retries the request once so the next
# checkout establishes a fresh connection.
module Middleware
  class ConnectionRetry
    STALE_CONNECTION_ERRORS = [
      ActiveRecord::ConnectionNotEstablished,
      PG::ConnectionBad
    ].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue *STALE_CONNECTION_ERRORS
      ActiveRecord::Base.connection_handler.clear_all_connections!
      @app.call(env)
    end
  end
end
