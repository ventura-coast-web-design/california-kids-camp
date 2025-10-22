import Link from 'next/link';
import styles from './success.module.scss';

export default function RegistrationSuccess() {
  return (
    <div className={styles.successPage}>
      <div className={styles.container}>
        <div className={styles.successCard}>
          <div className={styles.iconContainer}>
            <svg
              className={styles.checkIcon}
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M5 13l4 4L19 7"
              />
            </svg>
          </div>
          <h1>Registration Successful!</h1>
          <p className={styles.subtitle}>
            Thank you for registering for California Kids Camp!
          </p>
          <div className={styles.messageBox}>
            <h2>What&apos;s Next?</h2>
            <ul>
              <li>✓ You will receive a confirmation email shortly</li>
              <li>✓ We&apos;ll send you camp details and a packing list closer to the camp date</li>
              <li>✓ If you have any questions, feel free to contact us at info@californiacampc.org</li>
            </ul>
          </div>
          <div className={styles.actions}>
            <Link href="/" className={styles.homeButton}>
              Return to Home
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}

