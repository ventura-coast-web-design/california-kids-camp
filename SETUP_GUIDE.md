# California Kids Camp - Complete Setup Guide

This guide will walk you through setting up the complete camp registration system with Supabase, Stripe, and Vercel.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Supabase Setup](#supabase-setup)
3. [Stripe Setup](#stripe-setup)
4. [Local Development](#local-development)
5. [Vercel Deployment](#vercel-deployment)
6. [Admin Access](#admin-access)
7. [Testing](#testing)

---

## Prerequisites

- Node.js 18+ installed
- npm or yarn
- A GitHub account (for Vercel deployment)
- A Supabase account (free tier works)
- A Stripe account (test mode is fine)

---

## Supabase Setup

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Fill in:
   - **Name**: `california-kids-camp`
   - **Database Password**: (Choose a strong password)
   - **Region**: Choose closest to your users
4. Wait for project to be created (~2 minutes)

### 2. Get API Credentials

1. In your project dashboard, go to **Settings** > **API**
2. Copy these values:
   - **Project URL** → This is your `NEXT_PUBLIC_SUPABASE_URL`
   - **anon/public key** → This is your `NEXT_PUBLIC_SUPABASE_ANON_KEY`
3. Save these for later

### 3. Create Database Tables

1. In Supabase dashboard, go to **SQL Editor**
2. Click "New Query"
3. Copy the entire contents of `supabase-schema.sql` from the project root
4. Paste into the SQL editor
5. Click "Run" to execute
6. Verify tables were created by going to **Table Editor**

You should see:
- `registrants` table
- `admins` table (optional, for future use)

### 4. Configure Row Level Security (RLS)

The schema already includes RLS policies:
- Public can INSERT (register)
- Everyone can SELECT (for admin viewing)
- Authenticated can UPDATE (for admin modifications)

---

## Stripe Setup

### 1. Create Stripe Account

1. Go to [stripe.com](https://stripe.com) and sign up
2. Complete account verification (you can use test mode first)

### 2. Get API Keys

1. Go to **Developers** > **API keys**
2. Copy:
   - **Publishable key** → This is your `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
   - **Secret key** → This is your `STRIPE_SECRET_KEY`
3. Start in **Test mode** (toggle at top)

### 3. Set Up Webhook (for production)

1. Go to **Developers** > **Webhooks**
2. Click "Add endpoint"
3. Enter your endpoint URL:
   - Local testing: Use Stripe CLI (see below)
   - Production: `https://your-domain.vercel.app/api/stripe-webhook`
4. Select events to listen for:
   - `checkout.session.completed`
5. Copy the **Signing secret** → This is your `STRIPE_WEBHOOK_SECRET`

### 4. Stripe CLI (for local testing)

```bash
# Install Stripe CLI
brew install stripe/stripe-brew/stripe

# Login to Stripe
stripe login

# Forward webhooks to local server
stripe listen --forward-to localhost:3000/api/stripe-webhook

# This will give you a webhook secret for local development
```

---

## Local Development

### 1. Clone and Install

```bash
cd /Users/ackers/Desktop/code/VCWD/california-kids-camp
npm install
```

### 2. Create Environment Variables

Create a `.env.local` file in the project root:

```bash
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# Stripe Configuration
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your-publishable-key
STRIPE_SECRET_KEY=sk_test_your-secret-key
STRIPE_WEBHOOK_SECRET=whsec_your-webhook-secret

# Admin Configuration
ADMIN_USERNAME=admin
ADMIN_PASSWORD=YourSecurePassword123!

# JWT Secret (generate a random string)
JWT_SECRET=your-super-secret-jwt-key-change-this
```

### 3. Run Development Server

```bash
npm run dev
```

Visit:
- Main site: http://localhost:3000
- Registration: http://localhost:3000/register
- Admin login: http://localhost:3000/admin/login

---

## Vercel Deployment

### 1. Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your-username/california-kids-camp.git
git push -u origin main
```

### 2. Deploy to Vercel

1. Go to [vercel.com](https://vercel.com) and sign up/login
2. Click "Add New Project"
3. Import your GitHub repository
4. Configure project:
   - **Framework Preset**: Next.js
   - **Root Directory**: ./
   - **Build Command**: `npm run build`

### 3. Add Environment Variables

In Vercel project settings:
1. Go to **Settings** > **Environment Variables**
2. Add all variables from `.env.local`:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
   - `STRIPE_SECRET_KEY`
   - `STRIPE_WEBHOOK_SECRET`
   - `ADMIN_USERNAME`
   - `ADMIN_PASSWORD`
   - `JWT_SECRET`

3. Make sure to add for all environments (Production, Preview, Development)

### 4. Update Stripe Webhook

1. Go back to Stripe Dashboard > **Developers** > **Webhooks**
2. Update or add new endpoint with your Vercel URL:
   ```
   https://your-domain.vercel.app/api/stripe-webhook
   ```
3. Update `STRIPE_WEBHOOK_SECRET` in Vercel with the new signing secret

### 5. Deploy

Click "Deploy" and wait for build to complete.

---

## Admin Access

### Default Credentials

As configured in your `.env.local`:
- **URL**: `https://your-domain.com/admin/login`
- **Username**: `admin` (or whatever you set)
- **Password**: Your secure password

### Admin Features

1. **Dashboard**: View all registrants
2. **Filter**: By payment status (all/completed/pending)
3. **Search**: Find specific registrants
4. **Export**: Download CSV of all registrations
5. **View Details**: Click "View" button for full registrant info

### Changing Admin Credentials

Simply update the environment variables:
- `ADMIN_USERNAME`
- `ADMIN_PASSWORD`

Redeploy on Vercel for changes to take effect.

---

## Testing

### Test Registration Flow

1. Go to `/register`
2. Fill out the form
3. Click "Proceed to Payment"
4. Use Stripe test card:
   - **Card**: 4242 4242 4242 4242
   - **Expiry**: Any future date
   - **CVC**: Any 3 digits
   - **ZIP**: Any 5 digits
5. Complete payment
6. Should redirect to success page
7. Check admin dashboard - registrant should appear with "completed" status

### Test Webhook

1. Complete a test registration
2. Check Supabase to verify `payment_status` updated to "completed"
3. If not updated, check:
   - Webhook endpoint is correct
   - Webhook secret matches
   - Check Vercel logs for errors

---

## Troubleshooting

### Supabase Connection Issues

- Verify URL and anon key are correct
- Check if Supabase project is active
- Verify RLS policies are in place

### Stripe Payment Fails

- Ensure you're using test mode keys for testing
- Check webhook is properly configured
- Verify all Stripe env variables are set

### Admin Login Not Working

- Check `ADMIN_USERNAME` and `ADMIN_PASSWORD` in environment variables
- Clear browser localStorage
- Check browser console for errors

### Build Errors

```bash
# Clear cache and rebuild
rm -rf .next
npm run build
```

---

## Production Checklist

Before going live:

- [ ] Switch Stripe from test mode to live mode
- [ ] Update Stripe API keys in Vercel
- [ ] Set up real webhook endpoint
- [ ] Change admin password to something secure
- [ ] Test complete registration flow
- [ ] Set up email notifications (future enhancement)
- [ ] Add custom domain in Vercel
- [ ] Enable Vercel production protection
- [ ] Test on mobile devices
- [ ] Back up Supabase database

---

## Support

For issues or questions:
- Check Vercel deployment logs
- Check Supabase logs
- Check Stripe webhook logs
- Contact: info@californiacampc.org

---

## Future Enhancements

Potential features to add:
- Email confirmations after registration
- Automatic reminder emails before camp
- Waitlist management
- Multiple session pricing
- Early bird discounts
- Sibling discounts
- Refund processing
- Medical form uploads
- Photo gallery from camp
- Camper portal

---

## File Structure

```
california-kids-camp/
├── src/
│   ├── app/
│   │   ├── page.tsx                 # Homepage
│   │   ├── register/                # Registration form
│   │   ├── registration-success/    # Success page
│   │   ├── admin/
│   │   │   ├── login/              # Admin login
│   │   │   └── dashboard/          # Admin dashboard
│   │   └── api/
│   │       ├── create-checkout/    # Stripe checkout API
│   │       ├── stripe-webhook/     # Stripe webhook handler
│   │       └── admin/login/        # Admin auth API
│   ├── lib/
│   │   ├── supabase.ts             # Supabase client
│   │   └── stripe.ts               # Stripe client
│   └── styles/                      # SCSS styles
├── supabase-schema.sql             # Database schema
├── ENV_SETUP.md                    # Environment setup guide
└── SETUP_GUIDE.md                  # This file
```

---

Happy Camping! 🏕️

