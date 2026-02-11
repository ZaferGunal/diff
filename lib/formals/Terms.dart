import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../MyColors.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({Key? key}) : super(key: key);

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
          'Terms of Service',
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
                  'Terms of Service',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Last Updated: 01/11/2025',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 30),
                _buildSection(
                  'Welcome',
                  'Welcome to practicotesting.com ("Site"). The Site provides online educational products and services ("Services"), including exams, exercises, tools, content, and other educational materials ("Content") for individual users and educational institutions (collectively, the "Platform"). The Platform is operated by TECH TEM BİLİŞİM GIDA TEMİZLİK İNŞ. TEKS. İTH. İHR. VE SAN. TİC. LTD. ŞTİ. ("we", "us", "PRACTICO").\n\nBy accessing or using the Site, you acknowledge that you have read, understood, and agreed to be bound by these Terms, our Privacy Policy, and any additional rules or guidelines published on the Platform.\n\nIf you do not agree to these Terms, you must immediately stop using the Site.',
                ),
                _buildSection(
                  '1. Important Legal Disclaimer: No Official Affiliation with Bocconi University',
                  '1.1 Institutional Independence\npracticotesting.com and all educational materials offered on the Platform are provided independently by TECH TEM BİLİŞİM GIDA TEMİZLİK İNŞ. TEKS. İTH. İHR. VE SAN. TİC. LTD. ŞTİ. This service is not affiliated with, endorsed by, sponsored by, or officially approved by Università Commerciale Luigi Bocconi ("Bocconi University") or any of its subsidiaries.\n\n1.2 Trademark Use\n"Bocconi", "Bocconi University", and all related names, logos, and visuals are registered trademarks. Their use on the Platform is solely for descriptive and referential purposes and does not imply any partnership or authorization from the trademark holders.\n\n1.3 Source and Nature of Materials\nPractice tests, questions, and exercises displayed on the Platform are created solely for training and practice purposes. They are not real exams published by Bocconi University. Users acknowledge that the Content does not guarantee success or exact replication of any official examination.',
                ),
                _buildSection(
                  '2. Eligibility',
                  'By using the Services, you confirm and warrant that:\n• You are at least 18 years old; or if under 18, you are using the Platform with the consent and supervision of a parent or legal guardian who accepts these Terms on your behalf.\n• You have the legal capacity to enter into this agreement.\n• Your use of the Services is not prohibited by the laws of your country of residence.',
                ),
                _buildSection(
                  '3. User Accounts and Registration',
                  '3.1 Account Creation\nAccess to the question bank and practice tests requires an account. You agree to provide accurate, current, and complete information during registration and to keep this information updated.\n\n3.2 Account Security\nYou are responsible for maintaining the confidentiality of your password and for all activities conducted under your account. In case of unauthorized access, you must notify us at practico.testing@gmail.com immediately.\n\n3.3 Account Sharing\nAccount sharing is strictly prohibited. Each account is intended for a single user only. Multiple simultaneous logins from different IP addresses or evidence of sharing may result in account suspension or termination without refund.',
                ),
                _buildSection(
                  '4. Intellectual Property Rights',
                  '4.1 Ownership\nAll Content on the Platform—including question banks, practice tests, text, graphics, logos, software code, and audio—is owned by TECH TEM BİLİŞİM GIDA TEMİZLİK İNŞ. TEKS. İTH. İHR. VE SAN. TİC. LTD. ŞTİ. or authorized content providers.\n\n4.2 License\nSubject to full compliance with these Terms, you are granted a limited, non-exclusive, non-transferable, and non-sublicensable license to access and use the Platform for your personal, non-commercial educational purposes within your purchased plan. Corporate or institutional use is governed by separate contractual agreements.\n\n4.3 Restrictions\nYou must not:\n• Copy, reproduce, distribute, share, resell, or create derivative works from the Content\n• Use automated tools (bots, scrapers, spiders) to extract data\n• Reverse engineer, decompile, or disassemble the Site or any part of it\n• Share screenshots, questions, or Content on social media, forums, or public platforms\n• Provide multi-user access beyond the licensed scope',
                ),
                _buildSection(
                  '5. Payments, Subscriptions, and Refunds',
                  '5.1 Pricing\nSubscription prices are displayed on the Site. PRACTICO reserves the right to modify pricing at any time.\n\n5.2 Auto-Renewal\nRecurring subscriptions automatically renew at the end of each billing cycle. You must cancel at least 24 hours before the renewal date to avoid automatic charges.\n\n5.3 Refund Policy\nBecause digital content is delivered immediately upon purchase, users acknowledge that they waive the right of withdrawal once access is granted. Therefore, all subscription sales are final and non-refundable. In cases of technical issues that prevent access to purchased Content, users must contact support. Refunds or compensation are provided at PRACTICO\'s sole discretion.',
                ),
                _buildSection(
                  '6. Third-Party Websites',
                  'The Platform may contain links to third-party websites. We do not control and are not responsible for the content, security, or privacy practices of these external sites. Your use of third-party sites is entirely at your own risk. PRACTICO is not liable for any direct or indirect losses arising from such use.',
                ),
                _buildSection(
                  '7. Disclaimer of Warranties and Limitation of Liability',
                  'The Service is provided "as is" and "as available". To the maximum extent permitted by law, PRACTICO disclaims all express or implied warranties, including:\n• Guarantees of academic success\n• Accuracy, completeness, or reliability of Content\n• Uninterrupted or error-free operation of the Service\n\nExcept in cases of willful misconduct or gross negligence, PRACTICO is not liable for any indirect, incidental, consequential, punitive, or commercial damages resulting from your use or inability to use the Service.',
                ),
                _buildSection(
                  '8. Indemnification',
                  'You agree to indemnify and hold harmless PRACTICO, its officers, and employees—within legal limitations and only to the extent damages arise directly from your own actions—against claims resulting from:\n• Violation of these Terms\n• Infringement of third-party rights (e.g., copyright, privacy)\n• Misuse of your account or unauthorized activity\n\nThis clause shall not be interpreted to impose unlimited liability on the user.',
                ),
                _buildSection(
                  '9. Changes to Terms',
                  'PRACTICO reserves the right to update these Terms at any time. Material changes will be communicated via the Site or email. Continued use of the Service after updates constitutes acceptance of the revised Terms.',
                ),
                _buildSection(
                  '10. Contact',
                  'For any questions regarding these Terms:\n\nTECH TEM BİLİŞİM GIDA TEMİZLİK İNŞ. TEKS. İTH. İHR. VE SAN. TİC. LTD. ŞTİ.\nKIZILIRMAK MAH. DUMLUPINAR BUL. YDA CENTER A NO:9A/158 ÇANKAYA / ANKARA\nEmail: practico.testing@gmail.com',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: MyColors.cyan,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
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
      ),
    );
  }
}