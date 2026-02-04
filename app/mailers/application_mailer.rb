class ApplicationMailer < ActionMailer::Base
  default from: "noreply@californiacamping.com"
  layout "mailer"

  # Attach logo to all emails
  before_action :attach_logo

  private

  def attach_logo
    logo_path = Rails.root.join("app", "assets", "images", "logo-black.png")
    if File.exist?(logo_path)
      attachments.inline["logo-black.png"] = File.read(logo_path)
    end
  end
end
