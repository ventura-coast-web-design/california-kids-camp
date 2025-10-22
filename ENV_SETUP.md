# Environment Variables Setup

Create a `.env.local` file in the root directory with the following variables:

```bash
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key

# Stripe Configuration
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=your-stripe-publishable-key
STRIPE_SECRET_KEY=your-stripe-secret-key
STRIPE_WEBHOOK_SECRET=your-stripe-webhook-secret

# Admin Configuration (for simple admin authentication)
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your-secure-password-here
```

## Setup Instructions

### 1. Supabase Setup

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Navigate to Project Settings > API
3. Copy your project URL to `NEXT_PUBLIC_SUPABASE_URL`
4. Copy your anon/public key to `NEXT_PUBLIC_SUPABASE_ANON_KEY`
5. Go to SQL Editor and run the `supabase-schema.sql` file to create your tables

### 2. Stripe Setup

1. Go to [stripe.com](https://stripe.com) and create an account
2. Navigate to Developers > API keys
3. Copy your Publishable key to `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
4. Copy your Secret key to `STRIPE_SECRET_KEY`
5. Set up webhooks for payment confirmation:
   - Go to Developers > Webhooks
   - Add endpoint: `https://your-domain.com/api/stripe-webhook`
   - Select events: `checkout.session.completed`
   - Copy the webhook secret to `STRIPE_WEBHOOK_SECRET`

### 3. Admin Credentials

Set your admin username and a secure password:
- `ADMIN_USERNAME`: Your admin username (default: admin)
- `ADMIN_PASSWORD`: A strong password for admin access

## Deployment on Vercel

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com) and import your repository
3. Add all environment variables in Vercel Project Settings > Environment Variables
4. Deploy!

Note: Make sure `.env.local` is in your `.gitignore` file (it should be by default)

