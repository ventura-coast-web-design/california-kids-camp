import styles from "./page.module.scss";

export default function Home() {
  return (
    <div className={styles.page}>
      {/* Hero Section */}
      <section className={styles.hero}>
        <div className={styles.heroContent}>
          <h1 className={styles.heroTitle}>
            California Kids Camp
          </h1>
          <p className={styles.heroSubtitle}>
            A Faith-Filled Summer Adventure for Young Christadelphians
          </p>
          <p className={styles.heroDescription}>
            Join us for an unforgettable week of faith, friendship, and fun in the beautiful California outdoors!
          </p>
          <div className={styles.heroCta}>
            <a href="#register" className={styles.primaryButton}>
              Register Now
            </a>
            <a href="#about" className={styles.secondaryButton}>
              Learn More
            </a>
          </div>
        </div>
      </section>

      {/* About the Camp Section */}
      <section id="about" className={styles.section}>
        <div className={styles.container}>
          <h2 className={styles.sectionTitle}>About the Camp</h2>
          <p className={styles.sectionIntro}>
            California Kids Camp is a special summer program designed for children and young teens 
            in the Christadelphian community. Our camp provides a safe, nurturing environment where 
            campers can grow in their faith while enjoying exciting outdoor activities.
          </p>
          
          <div className={styles.features}>
            <div className={styles.featureCard}>
              <div className={styles.featureIcon}>📖</div>
              <h3>Bible Studies</h3>
              <p>Age-appropriate lessons that bring Scripture to life through interactive discussions and activities.</p>
            </div>
            
            <div className={styles.featureCard}>
              <div className={styles.featureIcon}>🏕️</div>
              <h3>Outdoor Adventures</h3>
              <p>Hiking, swimming, campfires, and nature exploration in California&apos;s stunning landscape.</p>
            </div>
            
            <div className={styles.featureCard}>
              <div className={styles.featureIcon}>🎵</div>
              <h3>Worship & Music</h3>
              <p>Inspiring hymns, worship sessions, and learning about God through song and prayer.</p>
            </div>
            
            <div className={styles.featureCard}>
              <div className={styles.featureIcon}>🤝</div>
              <h3>Lasting Friendships</h3>
              <p>Build connections with other young Christadelphians from across California and beyond.</p>
            </div>
            
            <div className={styles.featureCard}>
              <div className={styles.featureIcon}>🎨</div>
              <h3>Creative Activities</h3>
              <p>Arts, crafts, drama, and games that encourage creativity and teamwork.</p>
            </div>
            
            <div className={styles.featureCard}>
              <div className={styles.featureIcon}>⚽</div>
              <h3>Sports & Recreation</h3>
              <p>Team sports, games, and physical activities that promote health and cooperation.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Who Are Christadelphians Section */}
      <section className={styles.section + ' ' + styles.christadelphianSection}>
        <div className={styles.container}>
          <h2 className={styles.sectionTitle}>Who Are Christadelphians?</h2>
          
          <div className={styles.infoContent}>
            <div className={styles.infoText}>
              <p>
                Christadelphians are a Christian community that believes in following the teachings 
                of the Bible as the inspired word of God. The name &quot;Christadelphian&quot; means 
                &quot;Brothers and Sisters in Christ.&quot;
              </p>
              
              <h3 className={styles.subheading}>Core Beliefs</h3>
              <ul className={styles.beliefsList}>
                <li>
                  <strong>One God:</strong> We believe in one God, the Father, and that Jesus Christ 
                  is His son, not God Himself.
                </li>
                <li>
                  <strong>The Bible:</strong> Scripture is our foundation for faith and practice, 
                  studied carefully and applied to daily life.
                </li>
                <li>
                  <strong>Baptism:</strong> Believers are baptized by full immersion as a conscious 
                  decision to follow Christ.
                </li>
                <li>
                  <strong>Kingdom of God:</strong> We look forward to Christ&apos;s return to establish 
                  God&apos;s Kingdom on earth.
                </li>
                <li>
                  <strong>Mortality:</strong> We believe humans are naturally mortal, and eternal 
                  life is a gift from God through Christ.
                </li>
              </ul>
              
              <h3 className={styles.subheading}>Our Community Values</h3>
              <p>
                Christadelphian communities emphasize Bible study, worship, and supporting one another 
                in faith. We meet regularly for &quot;breaking of bread&quot; services, Bible classes, and 
                fellowship. Our camp reflects these values, creating a space where young people can 
                explore their faith in a supportive, joyful environment.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Camp Details Section */}
      <section className={styles.section}>
        <div className={styles.container}>
          <h2 className={styles.sectionTitle}>Camp Details</h2>
          
          <div className={styles.detailsGrid}>
            <div className={styles.detailCard}>
              <h3>📅 When</h3>
              <p>Summer 2026</p>
              <p className={styles.detailSubtext}>One-week sessions available</p>
            </div>
            
            <div className={styles.detailCard}>
              <h3>📍 Where</h3>
              <p>California</p>
              <p className={styles.detailSubtext}>Beautiful outdoor facility</p>
            </div>
            
            <div className={styles.detailCard}>
              <h3>👥 Who</h3>
              <p>Ages 8-16</p>
              <p className={styles.detailSubtext}>Age-appropriate activities</p>
            </div>
            
            <div className={styles.detailCard}>
              <h3>🏠 Accommodation</h3>
              <p>Cabins</p>
              <p className={styles.detailSubtext}>Supervised by trained counselors</p>
            </div>
          </div>
        </div>
      </section>

      {/* Registration CTA */}
      <section id="register" className={styles.ctaSection}>
        <div className={styles.container}>
          <h2 className={styles.ctaTitle}>Ready to Join Us?</h2>
          <p className={styles.ctaText}>
            Registration opens soon! Sign up to receive updates about dates, pricing, and registration.
          </p>
          <div className={styles.ctaButtons}>
            <a href="mailto:info@californiacampc.org" className={styles.primaryButton}>
              Contact Us
            </a>
            <a href="#about" className={styles.secondaryButton}>
              Learn More
            </a>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className={styles.footer}>
        <div className={styles.container}>
          <p>© 2025 California Kids Camp - Christadelphian Community</p>
          <p className={styles.footerSubtext}>
            Building faith, friendship, and memories that last a lifetime
          </p>
        </div>
      </footer>
    </div>
  );
}
