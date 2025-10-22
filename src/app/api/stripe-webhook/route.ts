import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';
import { supabase } from '@/lib/supabase';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2025-09-30.clover',
});

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

export async function POST(request: NextRequest) {
  const body = await request.text();
  const signature = request.headers.get('stripe-signature')!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error';
    console.error('Webhook signature verification failed:', message);
    return NextResponse.json(
      { error: 'Webhook signature verification failed' },
      { status: 400 }
    );
  }

  // Handle the checkout.session.completed event
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.Checkout.Session;
    
    const registrantId = session.metadata?.registrantId;
    const paymentIntentId = session.payment_intent as string;

    if (registrantId) {
      try {
        // Update registrant with payment information
        const { error } = await supabase
          .from('registrants')
          .update({
            payment_status: 'completed',
            payment_intent_id: paymentIntentId,
            amount_paid: session.amount_total ? session.amount_total / 100 : 0,
          })
          .eq('id', registrantId);

        if (error) {
          console.error('Supabase update error:', error);
        } else {
          console.log(`Payment completed for registrant ${registrantId}`);
        }
      } catch (err) {
        console.error('Error updating registrant:', err);
      }
    }
  }

  return NextResponse.json({ received: true });
}

