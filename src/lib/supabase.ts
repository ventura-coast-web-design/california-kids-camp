import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Types for our database
export interface Registrant {
  id: string;
  created_at: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  camper_first_name: string;
  camper_last_name: string;
  camper_age: number;
  camper_gender: string;
  session_preference: string;
  emergency_contact_name: string;
  emergency_contact_phone: string;
  medical_notes?: string;
  dietary_restrictions?: string;
  payment_status: 'pending' | 'completed' | 'failed';
  payment_intent_id?: string;
  amount_paid?: number;
}

