import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../MyColors.dart';

class DSAgreementPage extends StatelessWidget {
  const DSAgreementPage({Key? key}) : super(key: key);

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
          'Distance Sales Agreement',
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
                  'Distance Sales Agreement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 30),
                _buildSection(
                  'IMPORTANT NOTICE',
                  'This Agreement governs the sale and use of digital educational content provided electronically.\n\nBy completing the payment process, the BUYER confirms that they have read, understood, and expressly accepted this Agreement prior to purchase.\n\nThe BUYER further acknowledges that digital content is made available immediately after purchase and that, due to instant access, the right of withdrawal is waived in accordance with applicable consumer protection laws.\n\nUsers who do not accept the terms of this Agreement may not access, view, or use the digital content or related services.',
                ),
                _buildSection(
                  '1 – PARTIES',
                  '1.1 SELLER\nCompany Name: TECH TEM BİLİŞİM GIDA TEMİZLİK İNŞ. TEKS. İTH. İHR. VE SAN. TİC. LTD. ŞTİ.\nAddress: KIZILIRMAK MAH. DUMLUPINAR BUL. YDA CENTER A NO:9A/158 ÇANKAYA / ANKARA\nEmail: practico.testing@gmail.com\nWebsite: practicotesting.com \n\n1.2 BUYER\nFull Name: (Final User Name and Surname)\nEmail Address: …………………………………\n\n1.3 USER\nThe individual who accesses and uses the digital content purchased under this Agreement. If the USER is a minor, this Agreement is deemed to have been approved by the USER\'s parent or legal guardian.',
                ),
                _buildSection(
                  '2 – SUBJECT OF THE AGREEMENT',
                  'The subject of this Agreement is the purchase by the BUYER of digital educational content ("PRODUCT") offered on the SELLER\'s website practicotesting.com, and the determination of the terms and conditions governing its use.\n\nDetailed information regarding the scope, features, and usage of the PRODUCT is available on the Website.',
                ),
                _buildSection(
                  '3 – Price, Payment, and Fees',
                  'The PRODUCT price is the amount displayed on the Website at the time of purchase and includes all applicable taxes.\n\nPayment Method: Payments are processed securely through the iyzico payment infrastructure.\n\nThe SELLER shall not be held liable for issues arising from incorrect or incomplete information provided by the BUYER during payment.\n\nThe SELLER reserves the right to modify prices and apply promotional discounts at its discretion.',
                ),
                _buildSection(
                  '4 – Right of Withdrawal, Refund, and Cancellation',
                  '4.1 - As this Agreement concerns digital content delivered electronically with immediate access, the BUYER does not have a right of withdrawal pursuant to Article 15/ğ of the Distance Contracts Regulation and applicable consumer protection laws.\n\n4.2 - The BUYER expressly acknowledges and accepts that immediate access to the digital content results in the waiver of the right of withdrawal.\n\n4.3 - Access to the PRODUCT is granted to the BUYER/USER for the duration corresponding to the purchased package following successful payment.\n\n4.4 - The SELLER shall not be responsible for the BUYER\'s inability to access the PRODUCT due to incorrect or incomplete account information provided by the BUYER.\n\n4.5 - In the event of payment cancellation, chargeback, or detection of unauthorized transactions, access to the PRODUCT shall be suspended or terminated.',
                ),
                _buildSection(
                  '5 – Scope of Use and User Obligations',
                  'The USER agrees and undertakes to:\n• Use the PRODUCT strictly within the scope of the granted license\n• Not copy, reproduce, distribute, share, or sell any digital content\n• Maintain the confidentiality of account credentials\n• Not hold the SELLER liable for damages caused by malicious software or third-party systems\n• Accept that no claims may be made due to service interruptions caused by force majeure events, including but not limited to natural disasters, war, terrorism, or infrastructure failures',
                ),
                _buildSection(
                  '6 – Seller\'s Representations and Disclaimers',
                  'The SELLER represents that:\n• The digital content will be provided as described on the Website\n• No guarantee of academic success or specific outcomes is given\n• Content may be updated, modified, or improved at any time\n• Temporary service interruptions due to maintenance or technical requirements do not constitute liability',
                ),
                _buildSection(
                  '7 – Electronic Communications',
                  'The SELLER may send informational messages to the BUYER via email or electronic systems for purposes related to service delivery, payment confirmation, and technical notifications, without requiring additional consent.',
                ),
                _buildSection(
                  '8 – Term and Termination',
                  'In the event of a breach of this Agreement by the BUYER or USER, the SELLER reserves the right to terminate the Agreement unilaterally and suspend access to the PRODUCT.\n\nThe BUYER may terminate their subscription at any time; however, termination does not entitle the BUYER to any refund.',
                ),
                _buildSection(
                  '9 – Entry into Force',
                  'This Agreement enters into force upon electronic approval by the BUYER. A copy of this Agreement shall be sent to the BUYER\'s registered email address.',
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