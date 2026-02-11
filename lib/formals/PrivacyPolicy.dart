import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../MyColors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Text(
          title,
          style: TextStyle(
            color: MyColors.cyan,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String content) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyColors.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: MyColors.cyan.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: MyColors.cyan,
            size: 24,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.ramabhadra(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Container(
            padding: EdgeInsets.all(50),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: MyColors.cyan.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Last Updated: December 13, 2025',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome to PractiCo ("we," "our," or "us"). We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, share, and protect your data when you use our online exam preparation and testing platform at practicotesting.com (the "Website" or "Service").\n\nBy creating an account or using our services, you acknowledge that you have read, understood, and agree to be bound by this Privacy Policy.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSection(
                  '1. Information We Collect',
                  'We collect several types of information to provide and improve our services:',
                ),

                _buildSubSection(
                  '1.1 Personal Information',
                  'When you register for an account or use our services, we collect:\n\n'
                      '• Identity Data: Your full name as provided during registration\n'
                      '• Contact Data: Email address for account communication and verification\n'
                      '• Account Credentials: Username and securely encrypted password\n'
                      '• Authentication Data: Email verification codes (OTP), password reset tokens, and session information',
                ),

                _buildSubSection(
                  '1.2 Payment Information',
                  '',
                ),

                _buildInfoBox(
                  'Important: We do NOT store your credit card information or banking details. All payments are processed securely through our third-party payment processor, Iyzico, which is PCI DSS compliant.',
                ),

                Text(
                  'We collect and store:\n\n'
                      '• Payment transaction history (payment ID, amount, currency, date)\n'
                      '• Membership status and expiry dates\n'
                      '• Country/region for payment processing (detected automatically from your IP address)\n'
                      '• Payment status (successful, pending, or failed)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSubSection(
                  '1.3 Usage and Performance Data',
                  'To provide our core testing and analytics services, we automatically collect:\n\n'
                      '• Test Performance: Your scores, selected answers, time spent on questions, and progress history\n'
                      '• Practice Test Results: Number of correct, wrong, and empty answers for each test attempt\n'
                      '• Subject-specific Progress: Your performance across different test subjects\n'
                      '• User Preferences: Theme settings (dark mode/light mode)',
                ),

                _buildSubSection(
                  '1.4 Technical Data',
                  '• Internet Protocol (IP) address\n'
                      '• Browser type and version\n'
                      '• Device information and operating system\n'
                      '• Time zone settings\n'
                      '• Login timestamps and device information\n'
                      '• Session activity data (last active time)',
                ),

                _buildSection(
                  '2. How We Use Your Information',
                  'We use your data for the following specific purposes:',
                ),

                Text(
                  '\n• Service Provision: To provide access to our test simulation services, process your registration, and manage your account\n\n'
                      '• Performance Analytics: To generate your test results and provide detailed performance analytics (a core feature of our service)\n\n'
                      '• Authentication & Security: To verify your email address, manage login sessions, and prevent unauthorized access to your account\n\n'
                      '• Payment Processing: To process membership fees through our secure payment gateway (Iyzico) and maintain payment records\n\n'
                      '• Customer Support: To respond to your inquiries and provide technical assistance\n\n'
                      '• Service Improvement: To analyze usage trends and improve the quality of our question bank, user interface, and overall platform functionality\n\n'
                      '• Account Security: To detect and prevent multiple concurrent logins, manage active sessions, and protect your account from unauthorized access\n\n'
                      '• Legal Compliance: To comply with applicable laws, regulations, and legal processes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSection(
                  '3. Session Management & Security',
                  'We implement advanced session management to protect your account:',
                ),

                Text(
                  '\n• Single Session Policy: Only one active session is allowed per account. If you log in from a new device, previous sessions are automatically terminated\n\n'
                      '• Session Monitoring: We track your last active time through periodic "heartbeat" checks\n\n'
                      '• Automatic Logout: Sessions are automatically terminated after 2 minutes of inactivity to protect your account\n\n'
                      '• Secure Tokens: We use JWT (JSON Web Tokens) with session IDs for secure authentication',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSection(
                  '4. How We Share Your Information',
                  '',
                ),

                _buildInfoBox(
                  'We do NOT sell your personal data to third parties under any circumstances.',
                ),

                Text(
                  'We may share your data with the following categories of third parties only as necessary to provide our services:\n\n'
                      '• Payment Processors: Iyzico processes all payments on our behalf. Payment information is transmitted directly to Iyzico through secure channels and is subject to their privacy policy\n\n'
                      '• Email Service Providers: We use Gmail SMTP services to send verification codes, password reset emails, and account notifications\n\n'
                      '• Cloud Hosting Providers: Our application and database are hosted on secure cloud infrastructure (Heroku) with industry-standard security measures\n\n'
                      '• Legal Authorities: We may disclose information if required by law, court order, or valid requests from government authorities\n\n'
                      '• Business Transfers: In the event of a merger, acquisition, or sale of assets, your data may be transferred to the successor organization',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSection(
                  '5. Data Security',
                  'We implement comprehensive security measures to protect your personal data:',
                ),

                Text(
                  '\n• Password Encryption: All passwords are hashed using bcrypt with salt rounds before storage\n\n'
                      '• Secure Transmission: All data transmission is encrypted using SSL/TLS protocols\n\n'
                      '• Database Security: Our MongoDB database uses secure connections and access controls\n\n'
                      '• Access Control: Access to personal data is restricted to authorized personnel who have a legitimate need to know\n\n'
                      '• Session Security: Secure session tokens with automatic expiration to prevent unauthorized access\n\n'
                      '• OTP Verification: Time-limited one-time passwords (5-minute expiry) for email verification and password resets',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'However, please note that no method of transmission over the Internet or electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your data, we cannot guarantee absolute security.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildSection(
                  '6. Data Retention',
                  'We retain your personal data only as long as necessary to fulfill the purposes outlined in this policy:',
                ),

                Text(
                  '\n• Active Accounts: Data is retained while your account remains active and in good standing\n\n'
                      '• Payment Records: Payment history is retained for accounting and legal compliance purposes\n\n'
                      '• Test Results: Your practice test results and performance analytics are stored until you delete them or close your account\n\n'
                      '• Inactive Accounts: Accounts inactive for an extended period (typically 2+ years) may be deleted\n\n'
                      '• Verification Codes: OTP codes and password reset tokens expire automatically after 5 minutes\n\n'
                      '• Account Deletion: You may request deletion of your account and associated data at any time',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSection(
                  '7. Your Rights and Choices',
                  'You have the following rights regarding your personal data:',
                ),

                Text(
                  '\n• Access: Request a copy of the personal data we hold about you\n\n'
                      '• Correction: Request correction of inaccurate or incomplete data\n\n'
                      '• Deletion: Request deletion of your account and personal data (subject to legal retention requirements)\n\n'
                      '• Data Portability: Request your data in a commonly used, machine-readable format\n\n'
                      '• Withdraw Consent: Withdraw consent for data processing where consent is the legal basis\n\n'
                      '• Object to Processing: Object to certain types of data processing',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                SizedBox(height: 15),
                Text(
                  'To exercise any of these rights, please contact us at the email address provided below. We may require identity verification before processing your request. We will respond to your request within 30 days.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSection(
                  '8. Email Communications',
                  'We send the following types of emails:',
                ),

                Text(
                  '\n• Transactional Emails: Account verification, password resets, payment confirmations (cannot be opted out)\n\n'
                      '• Service Updates: Important updates about our service or your account\n\n'
                      '• Marketing Communications: Optional newsletters and promotional content (you can opt-out at any time)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                SizedBox(height: 15),
                Text(
                  'You can unsubscribe from marketing emails by clicking the "unsubscribe" link in any marketing email or by contacting us directly.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSection(
                  '9. Children\'s Privacy',
                  'Our service is intended for users aged 16 and above. We do not knowingly collect personal information from children under 16. If we become aware that we have collected personal data from a child under 16, we will take steps to delete such information promptly.',
                ),

                _buildSection(
                  '10. International Data Transfers',
                  'Your information may be transferred to and processed in countries other than your country of residence. We ensure that appropriate safeguards are in place to protect your data in accordance with this Privacy Policy.',
                ),

                _buildSection(
                  '11. Third-Party Links',
                  'Our Website may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies before providing any personal information.',
                ),

                _buildSection(
                  '12. Changes to This Privacy Policy',
                  'We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or other factors. We will notify you of any material changes by:',
                ),

                Text(
                  '\n• Updating the "Last Updated" date at the top of this policy\n'
                      '• Posting a notice on our website\n'
                      '• Sending you an email notification (for significant changes)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                SizedBox(height: 15),
                Text(
                  'Your continued use of our services after any changes indicates your acceptance of the updated Privacy Policy.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSection(
                  '13. Cookie Policy',
                  'We use cookies and similar tracking technologies to enhance your experience:',
                ),

                Text(
                  '\n• Essential Cookies: Required for login, session management, and core functionality\n\n'
                      '• Preference Cookies: Remember your settings like dark mode preference\n\n'
                      '• Analytics Cookies: Help us understand how you use our platform to improve our services',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                SizedBox(height: 15),
                Text(
                  'You can control cookies through your browser settings, but disabling certain cookies may affect your ability to use some features.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                  ),
                ),

                _buildSection(
                  '14. Data Protection Officer',
                  'If you have any questions about data protection or wish to exercise your rights, you can contact our Data Protection team at the email address provided below.',
                ),

                _buildSection(
                  '15. Contact Us',
                  'If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:',
                ),

                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MyColors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: MyColors.cyan.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PractiCo Support',
                        style: TextStyle(
                          color: MyColors.cyan,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email: practico.testing@gmail.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Website: practicotesting.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                        ),
                      )

                    ],
                  ),
                ),

                SizedBox(height: 40),
                Divider(
                  color: Colors.white.withOpacity(0.2),
                  thickness: 1,
                ),
                SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        '© 2025 PractiCo. All rights reserved.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This Privacy Policy is effective as of the date stated above\nand governs our use of your personal information.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}