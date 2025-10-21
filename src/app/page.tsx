import styles from "./page.module.scss";

export default function Home() {
  return (
    <div className={styles.page}>
      {/* Navigation */}
      <nav className={styles.navbar}>
        <div className={styles.navContainer}>
          <div className={styles.logo}>
            <h1>California Kids Camp</h1>
          </div>
          <ul className={styles.navMenu}>
            <li><a href="#home">Home</a></li>
            <li><a href="#about">About</a></li>
            <li><a href="#camp">Camp Info</a></li>
            <li><a href="#christadelphians">Our Faith</a></li>
            <li><a href="#faq">FAQ</a></li>
            <li><a href="#contact">Contact</a></li>
          </ul>
        </div>
      </nav>

      {/* Hero Section */}
      <section id="home" className={styles.hero}>
        <div className={styles.heroOverlay}>
          <div className={styles.heroContent}>
            <p className={styles.heroLabel}>Join the Summer Adventure</p>
            <h1 className={styles.heroTitle}>
              Experience the Joy<br />at California Kids Camp
            </h1>
            <p className={styles.heroSubtitle}>
              A Faith-Filled Summer Adventure for Young Christadelphians
            </p>
            <a href="#about" className={styles.heroButton}>Discover More</a>
          </div>
        </div>
      </section>

      {/* Welcome Section */}
      <section id="about" className={styles.welcomeSection}>
        <div className={styles.container}>
          <div className={styles.sectionHeader}>
            <p className={styles.sectionLabel}>Our Introduction</p>
            <h2 className={styles.sectionTitle}>Welcome to California Kids Camp</h2>
          </div>
          <div className={styles.welcomeContent}>
            <p className={styles.welcomeText}>
              The mission of our camp is to disciple young people for the glory of God, 
              and to promote their spiritual and physical well-being through summer camps, 
              Bible studies, outdoor activities, and fellowship. We provide a safe, nurturing 
              environment where campers can grow in their faith while enjoying the beautiful 
              California outdoors.
            </p>
            <div className={styles.welcomeFeatures}>
              <div className={styles.welcomeFeature}>
                <span className={styles.featureIcon}>✓</span>
                <span>Safe & Secure Environment</span>
              </div>
              <div className={styles.welcomeFeature}>
                <span className={styles.featureIcon}>✓</span>
                <span>Spirit-Filled Activities</span>
              </div>
              <div className={styles.welcomeFeature}>
                <span className={styles.featureIcon}>✓</span>
                <span>Christ-Centered Teaching</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Why Choose Us Section */}
      <section className={styles.benefitsSection}>
        <div className={styles.container}>
          <div className={styles.sectionHeader}>
            <p className={styles.sectionLabel}>Our Benefits</p>
            <h2 className={styles.sectionTitle}>Why Choose Us</h2>
          </div>
          <div className={styles.benefitsGrid}>
            <div className={styles.benefitCard}>
              <div className={styles.benefitIcon}>📖</div>
              <h3>Bible Studies</h3>
              <p>
                Age-appropriate lessons that bring Scripture to life through interactive 
                discussions, bringing young people closer to God&apos;s word.
              </p>
            </div>
            <div className={styles.benefitCard}>
              <div className={styles.benefitIcon}>🏕️</div>
              <h3>Outdoor Adventures</h3>
              <p>
                Hiking, swimming, campfires, and nature exploration in California&apos;s 
                stunning landscape, creating unforgettable memories.
              </p>
            </div>
            <div className={styles.benefitCard}>
              <div className={styles.benefitIcon}>🎵</div>
              <h3>Worship & Music</h3>
              <p>
                Inspiring hymns, worship sessions, and learning about God through 
                song and prayer together as a community.
              </p>
            </div>
            <div className={styles.benefitCard}>
              <div className={styles.benefitIcon}>🤝</div>
              <h3>Lasting Friendships</h3>
              <p>
                Build connections with other young Christadelphians from across 
                California and beyond that last a lifetime.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Christadelphian Info Section */}
      <section id="christadelphians" className={styles.christadelphianSection}>
        <div className={styles.container}>
          <div className={styles.sectionHeader}>
            <p className={styles.sectionLabel}>Our Faith</p>
            <h2 className={styles.sectionTitle}>Who Are Christadelphians?</h2>
          </div>
          <div className={styles.faithContent}>
            <div className={styles.faithIntro}>
              <p>
                Christadelphians are a Christian community that believes in following the teachings 
                of the Bible as the inspired word of God. The name &quot;Christadelphian&quot; means 
                &quot;Brothers and Sisters in Christ.&quot; We are a worldwide community united in 
                our commitment to understanding and living by Scripture.
              </p>
            </div>
            
            <div className={styles.beliefsGrid}>
              <div className={styles.beliefCard}>
                <h4>One God</h4>
                <p>We believe in one God, the Father, and that Jesus Christ is His son, not God Himself.</p>
              </div>
              <div className={styles.beliefCard}>
                <h4>The Bible</h4>
                <p>Scripture is our foundation for faith and practice, studied carefully and applied to daily life.</p>
              </div>
              <div className={styles.beliefCard}>
                <h4>Baptism</h4>
                <p>Believers are baptized by full immersion as a conscious decision to follow Christ.</p>
              </div>
              <div className={styles.beliefCard}>
                <h4>Kingdom of God</h4>
                <p>We look forward to Christ&apos;s return to establish God&apos;s Kingdom on earth.</p>
              </div>
              <div className={styles.beliefCard}>
                <h4>Mortality</h4>
                <p>We believe humans are naturally mortal, and eternal life is a gift from God through Christ.</p>
              </div>
              <div className={styles.beliefCard}>
                <h4>Community</h4>
                <p>We meet regularly for &quot;breaking of bread&quot; services, Bible classes, and fellowship.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className={styles.testimonialsSection}>
        <div className={styles.container}>
          <div className={styles.sectionHeader}>
            <p className={styles.sectionLabel}>Testimonials</p>
            <h2 className={styles.sectionTitle}>What Campers Say</h2>
          </div>
          <div className={styles.testimonialsGrid}>
            <div className={styles.testimonialCard}>
              <div className={styles.testimonialQuote}>&quot;</div>
              <p className={styles.testimonialText}>
                It was the best summer camp ever! I learned so much about the Bible 
                and made friends I&apos;ll never forget. Can&apos;t wait to come back next year!
              </p>
              <p className={styles.testimonialAuthor}>— Sarah M., Age 14</p>
            </div>
            <div className={styles.testimonialCard}>
              <div className={styles.testimonialQuote}>&quot;</div>
              <p className={styles.testimonialText}>
                California Kids Camp helped my son grow in his faith while having the 
                time of his life. The counselors are amazing and truly care about each child.
              </p>
              <p className={styles.testimonialAuthor}>— Parent of Camper</p>
            </div>
            <div className={styles.testimonialCard}>
              <div className={styles.testimonialQuote}>&quot;</div>
              <p className={styles.testimonialText}>
                This camp is a very special place to learn about God and spend a week 
                of fun and friendship. The activities were awesome and the Bible studies 
                really helped me understand Scripture better.
              </p>
              <p className={styles.testimonialAuthor}>— David L., Age 12</p>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section id="faq" className={styles.faqSection}>
        <div className={styles.container}>
          <div className={styles.sectionHeader}>
            <p className={styles.sectionLabel}>Frequently Asked Questions</p>
            <h2 className={styles.sectionTitle}>Any Questions?</h2>
          </div>
          <div className={styles.faqList}>
            <div className={styles.faqItem}>
              <h4>What ages can attend the camp?</h4>
              <p>
                California Kids Camp welcomes children and young teens ages 8-16. 
                We organize activities and Bible studies appropriate for different age groups.
              </p>
            </div>
            <div className={styles.faqItem}>
              <h4>Do campers need to be Christadelphian to attend?</h4>
              <p>
                While our camp is designed for the Christadelphian community, we welcome 
                children who are interested in learning about our faith and the Bible.
              </p>
            </div>
            <div className={styles.faqItem}>
              <h4>What is included in the camp fee?</h4>
              <p>
                The camp fee includes accommodation, all meals, supervised activities, 
                Bible study materials, recreational equipment, and trained counselor supervision.
              </p>
            </div>
            <div className={styles.faqItem}>
              <h4>How long is each camp session?</h4>
              <p>
                Each session runs for one week during the summer. Multiple sessions 
                are available throughout the summer months.
              </p>
            </div>
            <div className={styles.faqItem}>
              <h4>What should campers bring?</h4>
              <p>
                Campers should bring comfortable clothing, swimwear, Bible, toiletries, 
                bedding, and any personal items. A detailed packing list is provided upon registration.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Camp Details Section */}
      <section id="camp" className={styles.campDetailsSection}>
        <div className={styles.container}>
          <div className={styles.sectionHeader}>
            <p className={styles.sectionLabel}>Camp Information</p>
            <h2 className={styles.sectionTitle}>Camp Details</h2>
          </div>
          <div className={styles.detailsGrid}>
            <div className={styles.detailBox}>
              <div className={styles.detailIcon}>📅</div>
              <h3>When</h3>
              <p className={styles.detailMain}>Summer 2026</p>
              <p className={styles.detailSub}>One-week sessions available</p>
            </div>
            <div className={styles.detailBox}>
              <div className={styles.detailIcon}>📍</div>
              <h3>Where</h3>
              <p className={styles.detailMain}>California</p>
              <p className={styles.detailSub}>Beautiful outdoor facility</p>
            </div>
            <div className={styles.detailBox}>
              <div className={styles.detailIcon}>👥</div>
              <h3>Who</h3>
              <p className={styles.detailMain}>Ages 8-16</p>
              <p className={styles.detailSub}>All skill levels welcome</p>
            </div>
            <div className={styles.detailBox}>
              <div className={styles.detailIcon}>🏠</div>
              <h3>Accommodation</h3>
              <p className={styles.detailMain}>Cabin Housing</p>
              <p className={styles.detailSub}>Supervised by trained counselors</p>
            </div>
          </div>
        </div>
      </section>

      {/* Contact/Newsletter Section */}
      <section id="contact" className={styles.contactSection}>
        <div className={styles.container}>
          <div className={styles.contactContent}>
            <div className={styles.contactInfo}>
              <h2>Get In Touch</h2>
              <p className={styles.contactDescription}>
                Ready to register or have questions? We&apos;re here to help! 
                Contact us for more information about camp dates, pricing, and registration.
              </p>
              <div className={styles.contactDetails}>
                <div className={styles.contactItem}>
                  <h4>📧 Email Us</h4>
                  <a href="mailto:info@californiacampc.org">info@californiacampc.org</a>
                </div>
                <div className={styles.contactItem}>
                  <h4>📞 Call Us</h4>
                  <p>Contact information coming soon</p>
                </div>
              </div>
            </div>
            <div className={styles.newsletterBox}>
              <h3>Newsletter Signup</h3>
              <p>Subscribe to receive updates about camp dates, registration, and special events.</p>
              <form className={styles.newsletterForm}>
                <input type="email" placeholder="Email Address *" required />
                <input type="text" placeholder="First Name" />
                <input type="text" placeholder="Last Name" />
                <button type="submit" className={styles.subscribeButton}>Subscribe</button>
              </form>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className={styles.footer}>
        <div className={styles.container}>
          <div className={styles.footerGrid}>
            <div className={styles.footerColumn}>
              <h3>California Kids Camp</h3>
              <p>
                A Christadelphian summer camp dedicated to building faith, 
                friendship, and memories that last a lifetime.
              </p>
            </div>
            <div className={styles.footerColumn}>
              <h4>Learn More</h4>
              <ul>
                <li><a href="#about">About Us</a></li>
                <li><a href="#christadelphians">Our Faith</a></li>
                <li><a href="#camp">Camp Info</a></li>
                <li><a href="#faq">FAQ</a></li>
              </ul>
            </div>
            <div className={styles.footerColumn}>
              <h4>Contact</h4>
              <p>Email: info@californiacampc.org</p>
              <p>California</p>
            </div>
          </div>
          <div className={styles.footerBottom}>
            <p>© Copyright 2025 California Kids Camp - Christadelphian Community</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
