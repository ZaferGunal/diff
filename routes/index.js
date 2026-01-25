const express = require("express");
const actions = require('../methods/actions');
const router = express.Router();

router.get("/", (req, res) => {
  res.send("Hello world");
});

router.get("/dashboard", (req, res) => {
  res.send("Dashboard");
});

// ==========================================
// USER AUTHENTICATION
// ==========================================
router.post("/adduser", actions.addNew);
router.post("/authenticate", actions.authenticate);
router.post("/force-login", actions.forceLogin);
router.get("/getinfo", actions.getinfo);
router.post("/updateDarkMode", actions.updateDarkMode);
router.post("/updatePracticesSolved", actions.updatePracticesSolved);
router.post("/logout", actions.logout);
router.post("/heartbeat", actions.heartbeat);

// ==========================================
// EMAIL VERIFICATION (SIGNUP)
// ==========================================
router.post("/send-otp", actions.sendOTP);
router.post("/verify-otp", actions.verifyOTP);
router.post("/resend-otp", actions.resendOTP);

// ==========================================
// PASSWORD RESET - YENİ!
// ==========================================
router.post("/password-reset/send-otp", actions.sendPasswordResetOTP);
router.post("/password-reset/verify-otp", actions.verifyPasswordResetOTP);
router.post("/password-reset/reset", actions.resetPassword);

// ==========================================
// PRACTICE TESTS
// ==========================================
router.post("/practice/add", actions.addPracticeTest);
router.get("/practice/:index", actions.getPracticeTest);
router.get("/practice", actions.getAllPracticeTests);

// ==========================================
// SUBJECT TESTS
// ==========================================
router.post("/subject/add", actions.addSubjectTest);
router.get("/subject/:subject/:index", actions.getSubjectTest);
router.get("/subject/:subject", actions.getSubjectTestsBySubject);

// ========================================== 
// PRACTICE TEST RESULTS
// ==========================================
router.post("/practice-test-results/update", actions.updatePracticeTestResults);
router.get("/practice-test-results", actions.getPracticeTestResults);
router.post("/practice-test-results/delete", actions.deletePracticeTestResult);


router.post("/verify-payment", actions.verifyPayment);

router.post("/payment/initialize", actions.initializePayment);
router.post("/payment/callback", actions.paymentCallback);
router.get("/payment/callback", actions.paymentCallback); // GET desteği de ekle
router.post("/payment/check-status", actions.checkPaymentStatus);


// ai part
router.post("/ai/analyze-question", actions.analyzeQuestion);
router.post("/ai/chat", actions.chatWithAI);


module.exports = router;