-- California Kids Camp Database Schema
-- Run this in your Supabase SQL Editor

-- Create registrants table
CREATE TABLE IF NOT EXISTS registrants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Parent/Guardian Information
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  
  -- Camper Information
  camper_first_name TEXT NOT NULL,
  camper_last_name TEXT NOT NULL,
  camper_age INTEGER NOT NULL,
  camper_gender TEXT NOT NULL,
  camper_date_of_birth DATE,
  
  -- Camp Information
  session_preference TEXT NOT NULL,
  
  -- Emergency Contact
  emergency_contact_name TEXT NOT NULL,
  emergency_contact_phone TEXT NOT NULL,
  emergency_contact_relationship TEXT,
  
  -- Medical & Dietary
  medical_notes TEXT,
  dietary_restrictions TEXT,
  medications TEXT,
  
  -- Payment Information
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed')),
  payment_intent_id TEXT,
  amount_paid DECIMAL(10, 2),
  
  -- Additional Information
  notes TEXT,
  
  CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_registrants_email ON registrants(email);
CREATE INDEX IF NOT EXISTS idx_registrants_created_at ON registrants(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_registrants_payment_status ON registrants(payment_status);

-- Enable Row Level Security (RLS)
ALTER TABLE registrants ENABLE ROW LEVEL SECURITY;

-- Create policy to allow anyone to insert (for public registration)
CREATE POLICY "Allow public registration" ON registrants
  FOR INSERT
  WITH CHECK (true);

-- Create policy to allow authenticated users to view all (for admin)
CREATE POLICY "Allow authenticated users to view all" ON registrants
  FOR SELECT
  USING (true);

-- Create policy to allow authenticated users to update
CREATE POLICY "Allow authenticated users to update" ON registrants
  FOR UPDATE
  USING (true);

-- Optional: Create admins table for secure admin authentication
CREATE TABLE IF NOT EXISTS admins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  last_login TIMESTAMP WITH TIME ZONE
);

-- Create index on username
CREATE INDEX IF NOT EXISTS idx_admins_username ON admins(username);

-- Enable RLS for admins table
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Only allow service role to access admins table
CREATE POLICY "Service role only" ON admins
  USING (false);

COMMENT ON TABLE registrants IS 'Stores camp registration information for California Kids Camp';
COMMENT ON TABLE admins IS 'Stores admin user credentials (use service role for authentication)';

