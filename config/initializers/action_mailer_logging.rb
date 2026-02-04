# frozen_string_literal: true

# Filter out base64-encoded email content from logs
# This prevents attachment data from cluttering the logs while preserving useful email info

# Create a logger wrapper module that filters base64 content
module Base64FilterLogger
  BASE64_LINE_PATTERN = /\A[A-Za-z0-9+\/]{50,}={0,2}\z/
  
  def add(severity, message = nil, progname = nil, &block)
    # Get the actual message
    msg = message || (block ? block.call : progname)
    
    # Skip base64-encoded lines (long alphanumeric strings with +, /, =)
    return if msg.to_s.strip.match?(BASE64_LINE_PATTERN)
    
    # Skip MIME boundary markers
    return if msg.to_s.include?("----==_mimepart_")
    
    # Skip attachment encoding headers (but keep other headers)
    return if msg.to_s.strip == "Content-Transfer-Encoding: base64"
    
    # Call original add method
    super(severity, message, progname, &block)
  end
end

Rails.application.config.after_initialize do
  # Unwrap TaggedLogging/BroadcastLogger to get to the underlying logger(s)
  def unwrap_and_filter_logger(logger)
    return unless logger
    
    # Handle BroadcastLogger - apply to all broadcasts
    if logger.is_a?(ActiveSupport::BroadcastLogger)
      logger.broadcasts.each do |broadcast_logger|
        unwrap_and_filter_logger(broadcast_logger)
      end
      return
    end
    
    # Handle TaggedLogging - unwrap and continue
    if logger.is_a?(ActiveSupport::TaggedLogging)
      underlying = logger.instance_variable_get(:@logger)
      unwrap_and_filter_logger(underlying)
      return
    end
    
    # Apply filter to actual Logger instances
    if logger.is_a?(Logger) && !logger.is_a?(Base64FilterLogger)
      logger.extend(Base64FilterLogger)
    end
  end
  
  # Apply filter to Rails logger
  unwrap_and_filter_logger(Rails.logger)
end
