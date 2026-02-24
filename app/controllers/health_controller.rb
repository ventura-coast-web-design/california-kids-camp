# Lightweight health check for Fly.io (and other load balancers).
# Returns 200 as soon as the app is listening — no DB check, so cold starts
# pass even when Postgres is still waking. Real requests use ConnectionRetry.
class HealthController < ActionController::Base
  skip_before_action :verify_authenticity_token, raise: false

  def show
    head :ok
  end
end
