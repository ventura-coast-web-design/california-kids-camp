import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2025-09-30.clover',
});

export async function POST(request: NextRequest) {
  try {
    const { registrantId, camperName, email } = await request.json();

    // Create Checkout Session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: 'California Kids Camp Registration',
              description: `Camp registration for ${camperName}`,
            },
            unit_amount: 50000, // $500.00 in cents
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: `${request.headers.get('origin')}/registration-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${request.headers.get('origin')}/register?canceled=true`,
      customer_email: email,
      metadata: {
        registrantId,
        camperName,
      },
    });

    return NextResponse.json({ 
      sessionId: session.id,
      checkoutUrl: session.url
    });
  } catch (err) {
    console.error('Stripe checkout error:', err);
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'An error occurred' },
      { status: 500 }
    );
  }
}

