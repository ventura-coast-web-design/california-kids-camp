namespace :counsellors do
  SPAM_EMOJI = "💳"

  desc "Delete counsellor records where first_name or last_name contains 💳 (spam). Dry run unless CONFIRM=1"
  task delete_spam: :environment do
    scope = Counsellor.where("first_name LIKE ? OR last_name LIKE ?", "%#{SPAM_EMOJI}%", "%#{SPAM_EMOJI}%")
    count = scope.count

    if count.zero?
      puts "No counsellor records found with 💳 in name. Nothing to do."
      next
    end

    if ENV["CONFIRM"] != "1"
      puts "DRY RUN: Would delete #{count} counsellor(s) with 💳 in first_name or last_name."
      scope.limit(10).pluck(:id, :first_name, :last_name, :created_at).each do |id, first, last, created|
        puts "  id=#{id}  first_name=#{first.inspect}  last_name=#{last.inspect}  created_at=#{created}"
      end
      puts "  ... and #{[ count - 10, 0 ].max} more." if count > 10
      puts "Run with CONFIRM=1 to actually delete: CONFIRM=1 bundle exec rake counsellors:delete_spam"
      next
    end

    deleted = scope.destroy_all
    puts "Deleted #{deleted.size} counsellor spam record(s)."
  end
end

namespace :registrations do
  desc "Clean up old pending attendee registrations that were never paid (older than 1 hour)"
  task cleanup_pending: :environment do
    old_pending = AttendeeRegistration.where(payment_status: "pending")
                                      .where("created_at < ?", 1.hour.ago)
    
    count = 0
    old_pending.find_each do |registration|
      # Cancel any associated payment intents
      if registration.stripe_payment_intent_id.present?
        begin
          payment_intent = Stripe::PaymentIntent.retrieve(registration.stripe_payment_intent_id)
          if [ "requires_payment_method", "requires_confirmation" ].include?(payment_intent.status)
            Stripe::PaymentIntent.cancel(registration.stripe_payment_intent_id)
            puts "Cancelled payment intent #{registration.stripe_payment_intent_id} for registration #{registration.id}"
          end
        rescue Stripe::StripeError => e
          Rails.logger.warn "Failed to cancel payment intent #{registration.stripe_payment_intent_id}: #{e.message}"
        end
      end
      
      # Delete the registration
      registration.destroy
      count += 1
      puts "Deleted pending registration #{registration.id} (created #{registration.created_at})"
    end
    
    puts "Cleanup complete: Deleted #{count} pending registration(s)"
  end
end
