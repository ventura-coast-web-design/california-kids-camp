require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Enable serving of static files from the public directory.
  config.public_file_server.enabled = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use in-memory cache so we don't depend on Solid Cache DB (avoids crashes when Postgres is asleep on Fly).
  # Set USE_SOLID_CACHE=1 to use Solid Cache instead (requires cache DB created in release_command).
  config.cache_store = ENV["USE_SOLID_CACHE"].present? ? :solid_cache_store : :memory_store

  # Send emails and other jobs inline (no queue). Set to :solid_queue and SOLID_QUEUE_IN_PUMA to use a queue.
  config.active_job.queue_adapter = :inline

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: ENV.fetch("RAILS_HOST", "example.com") }

  # Configure Gmail SMTP server
  if ENV['GMAIL_USERNAME'].present? && ENV['GMAIL_APP_PASSWORD'].present?
    config.action_mailer.delivery_method = :smtp
    # Try port 465 with SSL first (more reliable), fallback to 587 with STARTTLS
    smtp_port = ENV.fetch('SMTP_PORT', '587').to_i
    smtp_settings = {
      address: 'smtp.gmail.com',
      port: smtp_port,
      domain: 'gmail.com',
      user_name: ENV['GMAIL_USERNAME'],
      password: ENV['GMAIL_APP_PASSWORD'],
      authentication: 'plain'
    }
    
    if smtp_port == 465
      # Port 465 uses SSL directly
      smtp_settings[:ssl] = true
      smtp_settings[:openssl_verify_mode] = 'none' # Gmail's certificate chain can cause issues
    else
      # Port 587 uses STARTTLS
      smtp_settings[:enable_starttls_auto] = true
      smtp_settings[:openssl_verify_mode] = 'none' # Gmail's certificate chain can cause issues
    end
    
    config.action_mailer.smtp_settings = smtp_settings
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Allow Fly.io, custom host, and internal IP (Fly health checks use Host: 172.x.x.x:3000).
  config.hosts << ".fly.dev"
  config.hosts << "kidscampcalifornia.com"
  config.hosts << "www.kidscampcalifornia.com"
  config.hosts << ENV["RAILS_HOST"] if ENV["RAILS_HOST"].present?
  config.hosts << /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d+)?$/  # e.g. 172.19.35.18:3000
end
