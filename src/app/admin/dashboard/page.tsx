'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase, Registrant } from '@/lib/supabase';
import styles from './dashboard.module.scss';

export default function AdminDashboard() {
  const router = useRouter();
  const [registrants, setRegistrants] = useState<Registrant[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'completed' | 'pending'>('all');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    // Check if user is authenticated
    const token = localStorage.getItem('adminAuth');
    if (!token) {
      router.push('/admin/login');
      return;
    }

    fetchRegistrants();
  }, [router]);

  const fetchRegistrants = async () => {
    try {
      const { data, error } = await supabase
        .from('registrants')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setRegistrants(data || []);
    } catch (err) {
      console.error('Error fetching registrants:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('adminAuth');
    router.push('/admin/login');
  };

  const exportToCSV = () => {
    const headers = [
      'Date',
      'Parent Name',
      'Email',
      'Phone',
      'Camper Name',
      'Age',
      'Gender',
      'Session',
      'Emergency Contact',
      'Emergency Phone',
      'Payment Status',
      'Amount Paid',
    ];

    const rows = filteredRegistrants.map(r => [
      new Date(r.created_at).toLocaleDateString(),
      `${r.first_name} ${r.last_name}`,
      r.email,
      r.phone,
      `${r.camper_first_name} ${r.camper_last_name}`,
      r.camper_age,
      r.camper_gender,
      r.session_preference,
      r.emergency_contact_name,
      r.emergency_contact_phone,
      r.payment_status,
      r.amount_paid || 0,
    ]);

    const csvContent = [
      headers.join(','),
      ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `registrants-${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
  };

  const filteredRegistrants = registrants
    .filter(r => {
      if (filter === 'all') return true;
      return r.payment_status === filter;
    })
    .filter(r => {
      if (!searchTerm) return true;
      const search = searchTerm.toLowerCase();
      return (
        r.first_name.toLowerCase().includes(search) ||
        r.last_name.toLowerCase().includes(search) ||
        r.email.toLowerCase().includes(search) ||
        r.camper_first_name.toLowerCase().includes(search) ||
        r.camper_last_name.toLowerCase().includes(search)
      );
    });

  const stats = {
    total: registrants.length,
    completed: registrants.filter(r => r.payment_status === 'completed').length,
    pending: registrants.filter(r => r.payment_status === 'pending').length,
    totalRevenue: registrants
      .filter(r => r.payment_status === 'completed')
      .reduce((sum, r) => sum + (r.amount_paid || 0), 0),
  };

  if (loading) {
    return (
      <div className={styles.loadingPage}>
        <div className={styles.spinner}></div>
        <p>Loading...</p>
      </div>
    );
  }

  return (
    <div className={styles.dashboardPage}>
      <div className={styles.header}>
        <div className={styles.headerContent}>
          <div>
            <h1>Admin Dashboard</h1>
            <p>California Kids Camp Registrations</p>
          </div>
          <button onClick={handleLogout} className={styles.logoutButton}>
            Logout
          </button>
        </div>
      </div>

      <div className={styles.container}>
        {/* Stats */}
        <div className={styles.stats}>
          <div className={styles.statCard}>
            <h3>Total Registrations</h3>
            <p className={styles.statNumber}>{stats.total}</p>
          </div>
          <div className={styles.statCard}>
            <h3>Completed</h3>
            <p className={styles.statNumber + ' ' + styles.success}>{stats.completed}</p>
          </div>
          <div className={styles.statCard}>
            <h3>Pending Payment</h3>
            <p className={styles.statNumber + ' ' + styles.warning}>{stats.pending}</p>
          </div>
          <div className={styles.statCard}>
            <h3>Total Revenue</h3>
            <p className={styles.statNumber}>${stats.totalRevenue.toFixed(2)}</p>
          </div>
        </div>

        {/* Filters */}
        <div className={styles.controls}>
          <div className={styles.filterButtons}>
            <button
              className={filter === 'all' ? styles.active : ''}
              onClick={() => setFilter('all')}
            >
              All ({registrants.length})
            </button>
            <button
              className={filter === 'completed' ? styles.active : ''}
              onClick={() => setFilter('completed')}
            >
              Completed ({stats.completed})
            </button>
            <button
              className={filter === 'pending' ? styles.active : ''}
              onClick={() => setFilter('pending')}
            >
              Pending ({stats.pending})
            </button>
          </div>

          <div className={styles.actions}>
            <input
              type="text"
              placeholder="Search registrants..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className={styles.searchInput}
            />
            <button onClick={exportToCSV} className={styles.exportButton}>
              Export CSV
            </button>
          </div>
        </div>

        {/* Registrants Table */}
        <div className={styles.tableContainer}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>Date</th>
                <th>Parent Name</th>
                <th>Email</th>
                <th>Camper Name</th>
                <th>Age</th>
                <th>Session</th>
                <th>Status</th>
                <th>Amount</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredRegistrants.length === 0 ? (
                <tr>
                  <td colSpan={9} className={styles.emptyState}>
                    No registrants found
                  </td>
                </tr>
              ) : (
                filteredRegistrants.map((registrant) => (
                  <tr key={registrant.id}>
                    <td>{new Date(registrant.created_at).toLocaleDateString()}</td>
                    <td>{registrant.first_name} {registrant.last_name}</td>
                    <td>{registrant.email}</td>
                    <td>{registrant.camper_first_name} {registrant.camper_last_name}</td>
                    <td>{registrant.camper_age}</td>
                    <td>{registrant.session_preference}</td>
                    <td>
                      <span className={`${styles.badge} ${styles[registrant.payment_status]}`}>
                        {registrant.payment_status}
                      </span>
                    </td>
                    <td>${registrant.amount_paid?.toFixed(2) || '0.00'}</td>
                    <td>
                      <button 
                        className={styles.viewButton}
                        onClick={() => {
                          alert(`Full Details:\n\n${JSON.stringify(registrant, null, 2)}`);
                        }}
                      >
                        View
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

