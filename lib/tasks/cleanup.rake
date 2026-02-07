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
