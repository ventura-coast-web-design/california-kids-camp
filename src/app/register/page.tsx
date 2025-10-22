'use client';

import { useState } from 'react';
import Link from 'next/link';
import { supabase } from '@/lib/supabase';
import { stripePromise } from '@/lib/stripe';
import styles from './register.module.scss';

export default function RegisterPage() {
  const [formData, setFormData] = useState({
    // Parent/Guardian Info
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
    
    // Camper Info
    camper_first_name: '',
    camper_last_name: '',
    camper_age: '',
    camper_gender: '',
    camper_date_of_birth: '',
    
    // Camp Info
    session_preference: '',
    
    // Emergency Contact
    emergency_contact_name: '',
    emergency_contact_phone: '',
    emergency_contact_relationship: '',
    
    // Medical & Dietary
    medical_notes: '',
    dietary_restrictions: '',
    medications: '',
    
    // Additional
    notes: '',
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      // Insert registrant into Supabase
      const { data: registrant, error: supabaseError } = await supabase
        .from('registrants')
        .insert([{
          ...formData,
          camper_age: parseInt(formData.camper_age),
          payment_status: 'pending',
          amount_paid: 500.00, // $500 camp fee
        }])
        .select()
        .single();

      if (supabaseError) throw supabaseError;

      // Create Stripe checkout session
      const response = await fetch('/api/create-checkout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          registrantId: registrant.id,
          camperName: `${formData.camper_first_name} ${formData.camper_last_name}`,
          email: formData.email,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to create checkout session');
      }

      // Redirect to Stripe Checkout
      const stripe = await stripePromise;
      if (stripe && data.sessionId) {
        window.location.href = data.checkoutUrl || `/checkout?session_id=${data.sessionId}`;
      }

    } catch (err) {
      console.error('Registration error:', err);
      const message = err instanceof Error ? err.message : 'An error occurred during registration. Please try again.';
      setError(message);
      setLoading(false);
    }
  };

  return (
    <div className={styles.registerPage}>
      <div className={styles.container}>
        <div className={styles.header}>
          <h1>Camp Registration</h1>
          <p>Register your camper for California Kids Camp Summer 2026</p>
        </div>

        {error && (
          <div className={styles.errorMessage}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className={styles.form}>
          {/* Parent/Guardian Information */}
          <section className={styles.formSection}>
            <h2>Parent/Guardian Information</h2>
            <div className={styles.formGrid}>
              <div className={styles.formGroup}>
                <label htmlFor="first_name">First Name *</label>
                <input
                  type="text"
                  id="first_name"
                  name="first_name"
                  value={formData.first_name}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="last_name">Last Name *</label>
                <input
                  type="text"
                  id="last_name"
                  name="last_name"
                  value={formData.last_name}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="email">Email *</label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="phone">Phone Number *</label>
                <input
                  type="tel"
                  id="phone"
                  name="phone"
                  value={formData.phone}
                  onChange={handleChange}
                  required
                />
              </div>
            </div>
          </section>

          {/* Camper Information */}
          <section className={styles.formSection}>
            <h2>Camper Information</h2>
            <div className={styles.formGrid}>
              <div className={styles.formGroup}>
                <label htmlFor="camper_first_name">Camper First Name *</label>
                <input
                  type="text"
                  id="camper_first_name"
                  name="camper_first_name"
                  value={formData.camper_first_name}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="camper_last_name">Camper Last Name *</label>
                <input
                  type="text"
                  id="camper_last_name"
                  name="camper_last_name"
                  value={formData.camper_last_name}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="camper_age">Age *</label>
                <input
                  type="number"
                  id="camper_age"
                  name="camper_age"
                  min="8"
                  max="16"
                  value={formData.camper_age}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="camper_date_of_birth">Date of Birth *</label>
                <input
                  type="date"
                  id="camper_date_of_birth"
                  name="camper_date_of_birth"
                  value={formData.camper_date_of_birth}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="camper_gender">Gender *</label>
                <select
                  id="camper_gender"
                  name="camper_gender"
                  value={formData.camper_gender}
                  onChange={handleChange}
                  required
                >
                  <option value="">Select...</option>
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                </select>
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="session_preference">Session Preference *</label>
                <select
                  id="session_preference"
                  name="session_preference"
                  value={formData.session_preference}
                  onChange={handleChange}
                  required
                >
                  <option value="">Select...</option>
                  <option value="session1">Session 1 - Week 1 (TBD)</option>
                  <option value="session2">Session 2 - Week 2 (TBD)</option>
                  <option value="session3">Session 3 - Week 3 (TBD)</option>
                </select>
              </div>
            </div>
          </section>

          {/* Emergency Contact */}
          <section className={styles.formSection}>
            <h2>Emergency Contact</h2>
            <div className={styles.formGrid}>
              <div className={styles.formGroup}>
                <label htmlFor="emergency_contact_name">Contact Name *</label>
                <input
                  type="text"
                  id="emergency_contact_name"
                  name="emergency_contact_name"
                  value={formData.emergency_contact_name}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="emergency_contact_phone">Contact Phone *</label>
                <input
                  type="tel"
                  id="emergency_contact_phone"
                  name="emergency_contact_phone"
                  value={formData.emergency_contact_phone}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="emergency_contact_relationship">Relationship *</label>
                <input
                  type="text"
                  id="emergency_contact_relationship"
                  name="emergency_contact_relationship"
                  value={formData.emergency_contact_relationship}
                  onChange={handleChange}
                  placeholder="e.g., Mother, Father, Aunt"
                  required
                />
              </div>
            </div>
          </section>

          {/* Medical & Dietary Information */}
          <section className={styles.formSection}>
            <h2>Medical & Dietary Information</h2>
            <div className={styles.formGroup}>
              <label htmlFor="medical_notes">Medical Conditions or Allergies</label>
              <textarea
                id="medical_notes"
                name="medical_notes"
                value={formData.medical_notes}
                onChange={handleChange}
                rows={3}
                placeholder="Please list any medical conditions, allergies, or health concerns..."
              />
            </div>
            <div className={styles.formGroup}>
              <label htmlFor="medications">Current Medications</label>
              <textarea
                id="medications"
                name="medications"
                value={formData.medications}
                onChange={handleChange}
                rows={3}
                placeholder="Please list any medications your camper takes regularly..."
              />
            </div>
            <div className={styles.formGroup}>
              <label htmlFor="dietary_restrictions">Dietary Restrictions</label>
              <textarea
                id="dietary_restrictions"
                name="dietary_restrictions"
                value={formData.dietary_restrictions}
                onChange={handleChange}
                rows={2}
                placeholder="Any dietary restrictions or food allergies..."
              />
            </div>
          </section>

          {/* Additional Notes */}
          <section className={styles.formSection}>
            <h2>Additional Information</h2>
            <div className={styles.formGroup}>
              <label htmlFor="notes">Additional Notes (Optional)</label>
              <textarea
                id="notes"
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                rows={3}
                placeholder="Anything else we should know about your camper..."
              />
            </div>
          </section>

          {/* Payment Info */}
          <div className={styles.paymentInfo}>
            <h3>Registration Fee: $500.00</h3>
            <p>You will be redirected to Stripe to complete your payment securely.</p>
          </div>

          <div className={styles.formActions}>
            <button
              type="submit"
              className={styles.submitButton}
              disabled={loading}
            >
              {loading ? 'Processing...' : 'Proceed to Payment'}
            </button>
          </div>
        </form>

        <div className={styles.backLink}>
          <Link href="/">← Back to Home</Link>
        </div>
      </div>
    </div>
  );
}

