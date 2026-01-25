var User = require("../models/user");
var jwt = require("jwt-simple");
var config = require("../config/dbconfig");
const crypto = require("crypto");

const geoip = require('geoip-lite');


const nodemailer = require("nodemailer");
const bcrypt = require("bcrypt");
const UserVerification = require("../models/userVerification");

var PracticeTest = require("../models/PracticeTest");
var SubjectTest = require("../models/SubjectTest");

const Iyzipay = require('iyzipay');

const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
// İyzico konfigürasyonu (dotenv'den al)
const iyzipay = new Iyzipay({
    apiKey: process.env.IYZICO_API_KEY,
    secretKey: process.env.IYZICO_SECRET_KEY,
    uri: process.env.IYZICO_BASE_URL || 'https://api.iyzipay.com'
});







function getCountryFromIP(ip) {
    const cleanIP = ip.includes('::ffff:') ? ip.split('::ffff:')[1] : ip;

    if (cleanIP === '127.0.0.1' || cleanIP === '::1') {
        return 'TR'; // localhost için default
    }

    const geo = geoip.lookup(cleanIP);
    return geo ? geo.country : 'US';
}

// Ülkeye göre para birimi ve fiyat
function getPaymentSettings(country) {
    if (country === 'TR') {
        return {
            currency: Iyzipay.CURRENCY.TRY,
            price: '3970.00',
            locale: Iyzipay.LOCALE.TR,
            buyerDefaults: {
                name: 'Ali',
                surname: 'Yılmaz',
                gsmNumber: '+905350000000',
                identityNumber: '11111111111',
                city: 'Istanbul',
                country: 'Turkey',
                address: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
                zipCode: '34732'
            }
        };
    } else {
        return {
            currency: Iyzipay.CURRENCY.EUR,
            price: '79.99',
            locale: Iyzipay.LOCALE.EN,
            buyerDefaults: {
                name: 'John',
                surname: 'Doe',
                gsmNumber: '+10000000000',
                identityNumber: '00000000000',
                city: 'New York',
                country: 'United States',
                address: '123 Main Street',
                zipCode: '10001'
            }
        };
    }
}











require("dotenv").config();

let transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.AUTH_EMAIL,
        pass: process.env.AUTH_PASS
    }
});

function generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

// ==========================================
// TOKEN VALIDATION MIDDLEWARE
// ==========================================
async function validateToken(req, res, next) {
    try {
        if (!req.headers.authorization || !req.headers.authorization.split(' ')[1]) {
            return res.status(401).json({
                success: false,
                msg: "No token provided"
            });
        }

        const token = req.headers.authorization.split(' ')[1];

        let decodedtoken;
        try {
            decodedtoken = jwt.decode(token, config.secret);
        } catch (err) {
            return res.status(401).json({
                success: false,
                msg: "Invalid token"
            });
        }

        const user = await User.findById(decodedtoken._id);
        if (!user) {
            return res.status(401).json({
                success: false,
                msg: "User not found"
            });
        }

        // ✅ Session token kontrolü
        if (!user.activeSessionToken || user.activeSessionToken !== decodedtoken.sessionId) {
            console.log("⚠️ [TOKEN CHECK] Session mismatch - User logged in elsewhere");
            return res.status(401).json({
                success: false,
                msg: "Session expired - You were logged in from another device",
                sessionExpired: true
            });
        }

        // ✅ HEARTBEAT KONTROLÜ: 2 dakikadan uzun heartbeat yoksa otomatik logout
        if (user.lastHeartbeat) {
            const timeSinceHeartbeat = Date.now() - new Date(user.lastHeartbeat).getTime();
            const TIMEOUT = 2 * 60 * 1000; // 2 dakika

            if (timeSinceHeartbeat > TIMEOUT) {
                console.log(`⚠️ [TOKEN CHECK] Session expired due to inactivity (${Math.floor(timeSinceHeartbeat / 1000)}s)`);

                // Otomatik logout
                user.activeSessionToken = null;
                user.lastHeartbeat = null;
                await user.save();

                return res.status(401).json({
                    success: false,
                    msg: "Session expired due to inactivity",
                    sessionExpired: true
                });
            }
        }

        req.user = user;
        req.decodedToken = decodedtoken;
        next();

    } catch (err) {
        console.error("❌ [TOKEN CHECK] Error:", err);
        return res.status(401).json({
            success: false,
            msg: "Invalid session"
        });
    }
}

var functions = {
    // ==========================================
    // AUTHENTICATION
    // ==========================================
    authenticate: async function (req, res) {
        try {
            console.log("\n🔐 [LOGIN] Starting authentication...");
            console.log(`📧 [LOGIN] Email: ${req.body.email}`);

            const user = await User.findOne({ email: req.body.email });
            if (!user) {
                console.log("❌ [LOGIN] User not found");
                return res.status(403).json({ success: false, msg: "User not found" });
            }

            const isMatch = await user.comparePassword(req.body.password);
            if (!isMatch) {
                console.log("❌ [LOGIN] Wrong password");
                return res.status(403).json({ success: false, msg: "Wrong password" });
            }

            if (!user.verified) {
                console.log("⚠️ [LOGIN] Email not verified");
                return res.status(403).json({
                    success: false,
                    msg: "Please verify your email before logging in",
                    needsVerification: true,
                    userId: user._id.toString(),
                    email: user.email
                });
            }

            // ✅ YENİ: isPaid kontrolü
            if (!user.isPaid) {
                console.log("⚠️ [LOGIN] Payment not completed");
                return res.status(403).json({
                    success: false,
                    msg: "Please complete payment to access your account",
                    needsPayment: true,
                    userId: user._id.toString(),
                    email: user.email
                });
            }

            // ✅ Önceki session'ı otomatik kapat
            const hadPreviousSession = !!user.activeSessionToken;

            if (hadPreviousSession) {
                console.log("⚠️ [LOGIN] User already logged in from another device - FORCING LOGOUT");
                console.log(`   Previous login: ${user.lastLoginDate}`);
                console.log(`   Previous device: ${user.lastLoginDevice}`);
            }

            // ✅ Yeni session oluştur
            const sessionId = crypto.randomBytes(32).toString('hex');

            user.activeSessionToken = sessionId;
            user.lastLoginDate = Date.now();
            user.lastLoginDevice = req.headers['user-agent'] || 'Unknown';
            user.lastHeartbeat = Date.now();

            await user.save();

            const token = jwt.encode({
                _id: user._id,
                name: user.name,
                email: user.email,
                sessionId: sessionId
            }, config.secret);

            console.log(`💾 [LOGIN] User logged in successfully`);
            console.log(`   Session ID: ${sessionId.substring(0, 16)}...`);
            console.log(`   Device: ${user.lastLoginDevice}`);
            console.log("✅ [LOGIN] Login successful!\n");

            return res.json({
                success: true,
                token: token,
                isDarkMode: user.isDarkMode,
                practicesSolved: user.practicesSolved,
                practiceTestResults: user.practiceTestResults,
                previousSessionClosed: hadPreviousSession
            });

        } catch (err) {
            console.error("❌ [LOGIN] Error:", err);
            return res.status(500).json({ success: false, msg: "Server error" });
        }
    },

    forceLogin: async function (req, res) {
        return functions.authenticate(req, res);
    },

    // ==========================================
    // USER REGISTRATION
    // ==========================================
    addNew: async function (req, res) {
        try {
            if (!req.body.name || !req.body.password || !req.body.email) {
                return res.json({ success: false, msg: "Enter all fields" });
            }

            const existingUser = await User.findOne({
                $or: [{ name: req.body.name }, { email: req.body.email }]
            });

            if (existingUser) {
                return res.json({ success: false, msg: "User already exists" });
            }

            const newUser = new User({
                name: req.body.name,
                password: req.body.password,
                email: req.body.email,
                isDarkMode: req.body.isDarkMode || false,
                practicesSolved: [false, false, false, false],
                verified: false,
                isPaid: false,  // ✅ YENİ EKLENEN
                activeSessionToken: null,
                lastHeartbeat: null
            });

            await newUser.save();

            const otp = generateOTP();
            const saltRounds = 10;
            const hashedOTP = await bcrypt.hash(otp, saltRounds);

            const newVerification = new UserVerification({
                userId: newUser._id,
                uniqueString: hashedOTP,
                createdAt: Date.now(),
                expiresAt: Date.now() + 300000, // 5 dakika
                verificationType: 'email_verification'
            });

            await newVerification.save();

            const mailOptions = {
                from: process.env.AUTH_EMAIL,
                to: newUser.email,
                subject: "Email Verification - Practico",
                html: `
                <div style="font-family: Arial, sans-serif; padding: 20px;">
                    <h2>Welcome to Practico!</h2>
                    <p>Your verification code is:</p>
                    <h1 style="color: #4CAF50; font-size: 32px; letter-spacing: 5px;">${otp}</h1>
                    <p>This code will expire in 5 minutes.</p>
                </div>
            `
            };

            await transporter.sendMail(mailOptions);

            const token = jwt.encode(newUser, config.secret);

            return res.json({
                success: true,
                msg: "Account created! Please verify your email",
                token: token,
                userId: newUser._id.toString(),
                email: newUser.email,
                isDarkMode: newUser.isDarkMode,
                practicesSolved: newUser.practicesSolved
            });
        } catch (err) {
            console.error("Error in addNew:", err);
            return res.json({ success: false, msg: "Failed to save" });
        }
    },

    // ==========================================
    // SESSION MANAGEMENT
    // ==========================================
    heartbeat: async function (req, res) {
        await validateToken(req, res, async () => {
            try {
                const user = req.user;

                user.lastHeartbeat = Date.now();
                await user.save();

                return res.json({
                    success: true,
                    msg: "Heartbeat received"
                });
            } catch (err) {
                console.error("❌ [HEARTBEAT] Error:", err);
                return res.status(500).json({ success: false, msg: "Server error" });
            }
        });
    },

    logout: async function (req, res) {
        await validateToken(req, res, async () => {
            try {
                const user = req.user;

                console.log(`🔴 [LOGOUT] User logging out: ${user.name}`);

                user.activeSessionToken = null;
                user.lastHeartbeat = null;
                await user.save();

                console.log("✅ [LOGOUT] Logout successful - session cleared\n");

                return res.json({
                    success: true,
                    msg: "Logged out successfully"
                });
            } catch (err) {
                console.error("❌ [LOGOUT] Error:", err);
                return res.status(500).json({ success: false, msg: "Server error" });
            }
        });
    },

    // ==========================================
    // USER INFO & PREFERENCES
    // ==========================================
    getinfo: async function (req, res) {
        await validateToken(req, res, async () => {
            const user = req.user;
            return res.json({
                success: true,
                name: user.name,
                isDarkMode: user.isDarkMode,
                practicesSolved: user.practicesSolved,
                email: user.email,
                verified: user.verified,
                isPaid: user.isPaid,
                isPaidMember: user.isPaidMember,
                membershipExpiryDate: user.membershipExpiryDate,
                acceptedTerms: user.acceptedTerms,
                acceptedPreliminaryInformation: user.acceptedPreliminaryInformation,
                termsAcceptanceDate: user.termsAcceptanceDate,
                practiceTestResults: user.practiceTestResults,
                isLoggedIn: !!user.activeSessionToken,
                lastLoginDevice: user.lastLoginDevice
            });
        });
    },

    updateDarkMode: async function (req, res) {
        await validateToken(req, res, async () => {
            try {
                const user = req.user;
                user.isDarkMode = req.body.isDarkMode;
                await user.save();
                return res.json({ success: true, isDarkMode: user.isDarkMode });
            } catch (err) {
                console.error(err);
                return res.status(500).json({ success: false, msg: "Server error" });
            }
        });
    },

    updatePracticesSolved: async function (req, res) {
        await validateToken(req, res, async () => {
            try {
                const user = req.user;
                user.practicesSolved = req.body.practicesSolved;
                user.markModified('practicesSolved');
                await user.save();
                return res.json({
                    success: true,
                    practicesSolved: user.practicesSolved,
                    msg: "Practices updated successfully"
                });
            } catch (err) {
                console.error("Error in updatePracticesSolved:", err);
                return res.status(500).json({ success: false, msg: "Server error" });
            }
        });
    },

    // ==========================================
    // EMAIL VERIFICATION (FOR SIGNUP)
    // ==========================================
    sendOTP: async function (req, res) {
        try {
            const { email } = req.body;
            if (!email) return res.json({ success: false, msg: "Email required" });

            const user = await User.findOne({ email: email });
            if (!user) return res.json({ success: false, msg: "User not found" });
            if (user.verified) return res.json({ success: false, msg: "Email already verified" });

            // ✅ Sadece email verification OTP'lerini sil
            await UserVerification.deleteMany({
                userId: user._id,
                verificationType: 'email_verification'
            });

            const otp = generateOTP();
            const saltRounds = 10;
            const hashedOTP = await bcrypt.hash(otp, saltRounds);

            const newVerification = new UserVerification({
                userId: user._id,
                uniqueString: hashedOTP,
                createdAt: Date.now(),
                expiresAt: Date.now() + 300000,
                verificationType: 'email_verification'
            });

            await newVerification.save();

            const mailOptions = {
                from: process.env.AUTH_EMAIL,
                to: email,
                subject: "Email Verification - Practico",
                html: `
                    <div style="font-family: Arial, sans-serif; padding: 20px;">
                        <h2>Email Verification</h2>
                        <p>Your verification code is:</p>
                        <h1 style="color: #4CAF50; font-size: 32px; letter-spacing: 5px;">${otp}</h1>
                        <p>This code will expire in 5 minutes.</p>
                    </div>
                `
            };

            await transporter.sendMail(mailOptions);

            return res.json({
                success: true,
                msg: "Verification code sent to your email",
                userId: user._id
            });
        } catch (err) {
            console.error("Error in sendOTP:", err);
            return res.status(500).json({ success: false, msg: "Failed to send OTP" });
        }
    },

    verifyOTP: async function (req, res) {
        try {
            const { userId, otp } = req.body;
            if (!userId || !otp) return res.json({ success: false, msg: "Empty OTP details" });

            // ✅ Email verification OTP'sini ara
            const userVerification = await UserVerification.findOne({
                userId: userId,
                verificationType: 'email_verification'
            });

            if (!userVerification) {
                return res.json({
                    success: false,
                    msg: "Account record doesn't exist or has been verified already"
                });
            }

            const { expiresAt, uniqueString } = userVerification;

            if (expiresAt < Date.now()) {
                await UserVerification.deleteOne({
                    userId: userId,
                    verificationType: 'email_verification'
                });
                return res.json({ success: false, msg: "Code has expired. Please request again" });
            }

            const validOTP = await bcrypt.compare(otp, uniqueString);
            if (!validOTP) return res.json({ success: false, msg: "Invalid code. Check your inbox" });

            await User.updateOne({ _id: userId }, { verified: true });
            await UserVerification.deleteOne({
                userId: userId,
                verificationType: 'email_verification'
            });

            return res.json({
                success: true,
                msg: "Email verified successfully"
            });
        } catch (err) {
            console.error("Error in verifyOTP:", err);
            return res.status(500).json({ success: false, msg: "Verification failed" });
        }
    },

    resendOTP: async function (req, res) {
        try {
            const { userId, email } = req.body;
            if (!userId || !email) return res.json({ success: false, msg: "Empty user details" });

            // ✅ Sadece email verification OTP'lerini sil
            await UserVerification.deleteMany({
                userId: userId,
                verificationType: 'email_verification'
            });

            const otp = generateOTP();
            const saltRounds = 10;
            const hashedOTP = await bcrypt.hash(otp, saltRounds);

            const newVerification = new UserVerification({
                userId: userId,
                uniqueString: hashedOTP,
                createdAt: Date.now(),
                expiresAt: Date.now() + 300000,
                verificationType: 'email_verification'
            });

            await newVerification.save();

            const mailOptions = {
                from: process.env.AUTH_EMAIL,
                to: email,
                subject: "Email Verification - Practico",
                html: `
                    <div style="font-family: Arial, sans-serif; padding: 20px;">
                        <h2>Email Verification</h2>
                        <p>Your NEW verification code is:</p>
                        <h1 style="color: #4CAF50; font-size: 32px; letter-spacing: 5px;">${otp}</h1>
                        <p>This code will expire in 5 minutes.</p>
                    </div>
                `
            };

            await transporter.sendMail(mailOptions);

            return res.json({
                success: true,
                msg: "Verification code resent"
            });
        } catch (err) {
            console.error("Error in resendOTP:", err);
            return res.status(500).json({ success: false, msg: "Failed to resend OTP" });
        }
    },

    // ==========================================
    // PASSWORD RESET
    // ==========================================
    sendPasswordResetOTP: async function (req, res) {
        try {
            const { email } = req.body;

            if (!email) {
                return res.json({ success: false, msg: "Email required" });
            }

            const user = await User.findOne({ email: email });

            if (!user) {
                return res.json({ success: false, msg: "No account found with this email" });
            }

            // ✅ Önceki password reset OTP'lerini sil
            await UserVerification.deleteMany({
                userId: user._id,
                verificationType: "password_reset"
            });

            const otp = generateOTP();
            const saltRounds = 10;
            const hashedOTP = await bcrypt.hash(otp, saltRounds);

            const newVerification = new UserVerification({
                userId: user._id,
                uniqueString: hashedOTP,
                createdAt: Date.now(),
                expiresAt: Date.now() + 300000, // 5 dakika
                verificationType: "password_reset"
            });

            await newVerification.save();

            const mailOptions = {
                from: process.env.AUTH_EMAIL,
                to: email,
                subject: "Password Reset - Practico",
                html: `
                    <div style="font-family: Arial, sans-serif; padding: 20px;">
                        <h2>Password Reset Request</h2>
                        <p>You requested to reset your password. Your verification code is:</p>
                        <h1 style="color: #667eea; font-size: 32px; letter-spacing: 5px;">${otp}</h1>
                        <p>This code will expire in 5 minutes.</p>
                        <p>If you didn't request this, please ignore this email.</p>
                    </div>
                `
            };

            await transporter.sendMail(mailOptions);

            console.log(`📧 [PASSWORD RESET] OTP sent to ${email}`);

            return res.json({
                success: true,
                msg: "Password reset code sent to your email",
                userId: user._id.toString()
            });

        } catch (err) {
            console.error("❌ [PASSWORD RESET] Error sending OTP:", err);
            return res.status(500).json({
                success: false,
                msg: "Failed to send password reset code"
            });
        }
    },

    verifyPasswordResetOTP: async function (req, res) {
        try {
            const { userId, otp } = req.body;

            if (!userId || !otp) {
                return res.json({ success: false, msg: "Missing required fields" });
            }

            // ✅ Password reset verification'ı bul
            const userVerification = await UserVerification.findOne({
                userId: userId,
                verificationType: "password_reset"
            });

            if (!userVerification) {
                return res.json({
                    success: false,
                    msg: "No password reset request found or code already used"
                });
            }

            const { expiresAt, uniqueString } = userVerification;

            if (expiresAt < Date.now()) {
                await UserVerification.deleteOne({
                    userId: userId,
                    verificationType: "password_reset"
                });
                return res.json({
                    success: false,
                    msg: "Code has expired. Please request a new one"
                });
            }

            const validOTP = await bcrypt.compare(otp, uniqueString);

            if (!validOTP) {
                return res.json({
                    success: false,
                    msg: "Invalid code. Please check and try again"
                });
            }

            console.log(`✅ [PASSWORD RESET] OTP verified for user ${userId}`);

            // ⚠️ OTP'yi henüz silme - şifre değiştirildikten sonra silinecek
            return res.json({
                success: true,
                msg: "Code verified successfully",
                userId: userId
            });

        } catch (err) {
            console.error("❌ [PASSWORD RESET] Error verifying OTP:", err);
            return res.status(500).json({
                success: false,
                msg: "Verification failed"
            });
        }
    },

    resetPassword: async function (req, res) {
        try {
            const { userId, newPassword } = req.body;

            if (!userId || !newPassword) {
                return res.json({ success: false, msg: "Missing required fields" });
            }

            if (newPassword.length < 6) {
                return res.json({
                    success: false,
                    msg: "Password must be at least 6 characters long"
                });
            }

            const user = await User.findById(userId);

            if (!user) {
                return res.json({ success: false, msg: "User not found" });
            }

            // ✅ Yeni şifreyi kaydet (pre-save hook otomatik hashleyecek)
            user.password = newPassword;
            await user.save();

            // ✅ Password reset verification'ı sil
            await UserVerification.deleteOne({
                userId: userId,
                verificationType: "password_reset"
            });

            console.log(`✅ [PASSWORD RESET] Password updated for user ${user.email}`);

            // ✅ Bilgilendirme email'i gönder
            const mailOptions = {
                from: process.env.AUTH_EMAIL,
                to: user.email,
                subject: "Password Changed - Practico",
                html: `
                    <div style="font-family: Arial, sans-serif; padding: 20px;">
                        <h2>Password Successfully Changed</h2>
                        <p>Your password has been successfully reset.</p>
                        <p>If you didn't make this change, please contact us immediately.</p>
                        <p style="margin-top: 20px;">You can now login with your new password.</p>
                    </div>
                `
            };

            await transporter.sendMail(mailOptions);

            return res.json({
                success: true,
                msg: "Password reset successfully. You can now login with your new password"
            });

        } catch (err) {
            console.error("❌ [PASSWORD RESET] Error resetting password:", err);
            return res.status(500).json({
                success: false,
                msg: "Failed to reset password"
            });
        }
    },

    // ==========================================
    // PRACTICE TEST RESULTS
    // ==========================================
    updatePracticeTestResults: async function (req, res) {
        await validateToken(req, res, async () => {
            try {
                const user = req.user;
                const { testNumber, correctAnswers, wrongAnswers, emptyAnswers, score } = req.body;

                if (!testNumber || testNumber < 1 || testNumber > 4) {
                    return res.json({ success: false, msg: "Invalid test number (1-4)" });
                }

                if (correctAnswers === undefined || wrongAnswers === undefined ||
                    emptyAnswers === undefined || score === undefined) {
                    return res.json({ success: false, msg: "Missing required fields" });
                }

                const existingIndex = user.practiceTestResults.findIndex(
                    result => result.testNumber === testNumber
                );

                if (existingIndex !== -1) {
                    user.practiceTestResults[existingIndex] = {
                        testNumber,
                        correctAnswers,
                        wrongAnswers,
                        emptyAnswers,
                        score,
                        date: Date.now()
                    };
                } else {
                    user.practiceTestResults.push({
                        testNumber,
                        correctAnswers,
                        wrongAnswers,
                        emptyAnswers,
                        score,
                        date: Date.now()
                    });
                }

                user.markModified('practiceTestResults');
                await user.save();

                return res.json({
                    success: true,
                    practiceTestResults: user.practiceTestResults,
                    msg: "Practice test results updated successfully"
                });
            } catch (err) {
                console.error("Error in updatePracticeTestResults:", err);
                return res.status(500).json({ success: false, msg: "Server error" });
            }
        });
    },

    getPracticeTestResults: async function (req, res) {
        await validateToken(req, res, async () => {
            const user = req.user;
            return res.json({
                success: true,
                practiceTestResults: user.practiceTestResults
            });
        });
    },

    deletePracticeTestResult: async function (req, res) {
        await validateToken(req, res, async () => {
            try {
                const user = req.user;
                const { testNumber } = req.body;

                if (!testNumber) {
                    return res.json({ success: false, msg: "Test number required" });
                }

                user.practiceTestResults = user.practiceTestResults.filter(
                    result => result.testNumber !== testNumber
                );

                user.markModified('practiceTestResults');
                await user.save();

                return res.json({
                    success: true,
                    practiceTestResults: user.practiceTestResults,
                    msg: "Practice test result deleted successfully"
                });
            } catch (err) {
                console.error("Error in deletePracticeTestResult:", err);
                return res.status(500).json({ success: false, msg: "Server error" });
            }
        });
    },

    // ==========================================
    // PRACTICE TESTS
    // ==========================================
    addPracticeTest: async function (req, res) {
        try {
            const { index, title, answerKey, questionURLs } = req.body;
            if (!index || !title || !answerKey || !questionURLs)
                return res.json({ success: false, msg: "Missing fields" });

            if (answerKey.length !== questionURLs.length)
                return res.json({ success: false, msg: "AnswerKey and questionURLs count mismatch" });

            const test = new PracticeTest({
                index,
                title,
                answerKey,
                questionURLs
            });

            await test.save();
            return res.json({ success: true, msg: "Practice test created" });
        } catch (err) {
            console.log(err);
            return res.json({ success: false, msg: "Failed to create practice test" });
        }
    },

    getPracticeTest: async function (req, res) {
        try {
            const test = await PracticeTest.findOne({ index: req.params.index });
            if (!test) return res.json({ success: false, msg: "Test not found" });
            return res.json({ success: true, test });
        } catch (err) {
            console.log(err);
            return res.json({ success: false, msg: "Server error" });
        }
    },

    getAllPracticeTests: async function (req, res) {
        try {
            const tests = await PracticeTest.find().sort({ index: 1 });
            return res.json({ success: true, tests });
        } catch (err) {
            console.log(err);
            return res.json({ success: false, msg: "Server error" });
        }
    },

    // ==========================================
    // SUBJECT TESTS
    // ==========================================
    // ==========================================
    // SUBJECT TESTS
    // ==========================================
    addSubjectTest: async function (req, res) {
        try {
            console.log("📥 [SUBJECT TEST] Received data:", req.body);  // ✅ Debug için

            const { subject, index, answerKey, questionURLs } = req.body;
            const topic = req.body.topic || "unknown";  // ✅ topic boş gelirse default "unknown"

            // ✅ topic kontrolünü kaldırdık
            if (!subject || index === undefined || !answerKey || !questionURLs) {
                console.log("❌ [SUBJECT TEST] Missing fields");
                return res.json({ success: false, msg: "Missing fields" });
            }

            if (answerKey.length !== questionURLs.length) {
                console.log("❌ [SUBJECT TEST] Array length mismatch");
                return res.json({ success: false, msg: "AnswerKey and questionURLs count mismatch" });
            }

            const test = new SubjectTest({
                subject,
                index,
                answerKey,
                questionURLs,
                topic
            });

            await test.save();

            console.log("✅ [SUBJECT TEST] Test created successfully");
            return res.json({ success: true, msg: "Subject test created" });

        } catch (err) {
            console.error("❌ [SUBJECT TEST] Error:", err);
            return res.json({ success: false, msg: "Failed to create subject test" });
        }
    },

    getSubjectTest: async function (req, res) {
        try {
            const { subject, index } = req.params;
            const test = await SubjectTest.findOne({ subject, index });
            if (!test) return res.json({ success: false, msg: "Test not found" });
            return res.json({ success: true, test });
        } catch (err) {
            console.log(err);
            return res.json({ success: false, msg: "Server error" });
        }
    },

    getSubjectTestsBySubject: async function (req, res) {
        try {
            const { subject } = req.params;
            const tests = await SubjectTest.find({ subject }).sort({ index: 1 });
            return res.json({ success: true, tests });
        } catch (err) {
            console.log(err);
            return res.json({ success: false, msg: "Server error" });
        }
    },


    // ==========================================
    // PAYMENT VERIFICATION
    // ==========================================
    verifyPayment: async function (req, res) {
        try {
            const { userId } = req.body;

            if (!userId) {
                return res.json({ success: false, msg: "User ID required" });
            }

            const user = await User.findById(userId);

            if (!user) {
                return res.json({ success: false, msg: "User not found" });
            }

            if (!user.verified) {
                return res.json({
                    success: false,
                    msg: "Please verify your email first"
                });
            }

            if (user.isPaid) {
                return res.json({
                    success: false,
                    msg: "Payment already completed"
                });
            }

            // ✅ isPaid'i true yap
            user.isPaid = true;
            await user.save();

            console.log(`✅ [PAYMENT] Payment verified for user ${user.email}`);

            // ✅ Bilgilendirme email'i gönder
            const mailOptions = {
                from: process.env.AUTH_EMAIL,
                to: user.email,
                subject: "Payment Successful - Practico",
                html: `
                <div style="font-family: Arial, sans-serif; padding: 20px;">
                    <h2>Payment Successful!</h2>
                    <p>Your payment has been verified successfully.</p>
                    <p>You can now login to your account and start using Practico.</p>
                    <p style="margin-top: 20px;">Thank you for choosing us!</p>
                </div>
            `
            };

            await transporter.sendMail(mailOptions);

            return res.json({
                success: true,
                msg: "Payment verified successfully"
            });

        } catch (err) {
            console.error("❌ [PAYMENT] Error:", err);
            return res.status(500).json({
                success: false,
                msg: "Payment verification failed"
            });
        }
    },

    // actions.js - DÜZELTME: Token vs ConversationId sorunu çözüldü

    // ==========================================
    // 1. PAYMENT INITIALIZATION
    initializePayment: async function (req, res) {
        try {
            const { userId, email, name, acceptedTerms, acceptedPreliminaryInformation } = req.body;

            if (!userId || !email || !name) {
                return res.json({ success: false, msg: "Missing required fields" });
            }

            // ✅ YENİ: Terms kontrolü
            if (!acceptedTerms || !acceptedPreliminaryInformation) {
                return res.json({
                    success: false,
                    msg: "You must accept Terms of Service, Privacy Policy, and Distance Sales Agreement to proceed"
                });
            }

            const user = await User.findById(userId);
            if (!user) {
                return res.json({ success: false, msg: "User not found" });
            }

            if (!user.verified) {
                return res.json({ success: false, msg: "Please verify your email first" });
            }

            if (user.isPaid) {
                return res.json({ success: false, msg: "You already have an active membership" });
            }

            // ✅ IP'den ülke tespit et
            const clientIP = req.headers['x-forwarded-for']?.split(',')[0].trim() ||
                req.connection.remoteAddress ||
                '85.34.78.112';

            const country = getCountryFromIP(clientIP);
            const settings = getPaymentSettings(country);

            console.log('🌍 [PAYMENT] Detected Country:', country);
            console.log('💰 [PAYMENT] Currency:', settings.currency);
            console.log('💵 [PAYMENT] Price:', settings.price);

            const conversationId = `user_${userId}_${Date.now()}`;
            const callbackUrl = `${process.env.BACKEND_URL}/payment/callback`;

            // ✅ Buyer bilgileri - ülkeye göre
            const nameParts = name.split(' ');
            const buyer = {
                id: userId,
                name: nameParts[0] || settings.buyerDefaults.name,
                surname: nameParts[1] || settings.buyerDefaults.surname,
                gsmNumber: settings.buyerDefaults.gsmNumber,
                email: email,
                identityNumber: settings.buyerDefaults.identityNumber,
                lastLoginDate: new Date().toISOString().slice(0, 19).replace('T', ' '),
                registrationDate: new Date(user.createdAt || Date.now()).toISOString().slice(0, 19).replace('T', ' '),
                registrationAddress: settings.buyerDefaults.address,
                ip: clientIP,
                city: settings.buyerDefaults.city,
                country: settings.buyerDefaults.country,
                zipCode: settings.buyerDefaults.zipCode
            };

            // ✅ Adres bilgileri - ülkeye göre
            const addressInfo = {
                contactName: name,
                city: settings.buyerDefaults.city,
                country: settings.buyerDefaults.country,
                address: settings.buyerDefaults.address,
                zipCode: settings.buyerDefaults.zipCode
            };

            // ✅ İyzico request
            const request = {
                locale: settings.locale,
                conversationId: conversationId,
                price: settings.price,
                paidPrice: settings.price,
                currency: settings.currency,
                basketId: `basket_${userId}`,
                paymentGroup: Iyzipay.PAYMENT_GROUP.PRODUCT,
                callbackUrl: callbackUrl,
                enabledInstallments: [1],
                buyer: buyer,
                shippingAddress: addressInfo,
                billingAddress: addressInfo,
                basketItems: [
                    {
                        id: 'membership_premium',
                        name: country === 'TR' ? 'Premium Üyelik' : 'Premium Membership',
                        category1: 'Membership',
                        category2: 'Digital',
                        itemType: Iyzipay.BASKET_ITEM_TYPE.VIRTUAL,
                        price: settings.price
                    }
                ]
            };

            console.log('🚀 [PAYMENT] Initializing checkout...');
            console.log(`   User: ${email} (${country})`);
            console.log(`   Amount: ${settings.price} ${settings.currency}`);
            console.log(`   Terms Accepted: ${acceptedTerms}`);

            iyzipay.checkoutFormInitialize.create(request, async (err, result) => {
                if (err) {
                    console.error('❌ [PAYMENT] Error:', err);
                    return res.json({
                        success: false,
                        msg: "Payment initialization failed",
                        error: err.message
                    });
                }

                if (result.status === 'success') {
                    console.log('✅ [PAYMENT] Checkout form created');

                    // ✅ Payment history kaydet
                    user.paymentHistory.push({
                        conversationId: conversationId,
                        amount: parseFloat(settings.price),
                        currency: settings.currency,
                        country: country,
                        status: 'PENDING',
                        date: Date.now()
                    });

                    await user.save();

                    return res.json({
                        success: true,
                        paymentPageUrl: result.paymentPageUrl,
                        token: result.token,
                        conversationId: conversationId,
                        currency: settings.currency,
                        amount: settings.price,
                        country: country
                    });
                } else {
                    console.error('❌ [PAYMENT] Failed:', result.errorMessage);
                    return res.json({
                        success: false,
                        msg: result.errorMessage || "Payment initialization failed"
                    });
                }
            });

        } catch (err) {
            console.error('❌ [PAYMENT] Server error:', err);
            return res.status(500).json({ success: false, msg: "Server error" });
        }
    },

    // ==========================================
    // 2. PAYMENT CALLBACK -
    // ==========================================


    paymentCallback: async function (req, res) {
        try {
            console.log('🔍 [DEBUG] Request Method:', req.method);
            console.log('🔍 [DEBUG] Request Body:', JSON.stringify(req.body, null, 2));
            console.log('🔍 [DEBUG] Request Query:', JSON.stringify(req.query, null, 2));

            const token = req.body.token || req.query.token;

            if (!token) {
                console.error('❌ [CALLBACK] No token provided');
                return res.redirect('https://practicotesting.com');
            }

            console.log('📥 [CALLBACK] Received callback');
            console.log('   Token:', token);
            console.log('   Method:', req.method);

            const retrieveRequest = {
                locale: Iyzipay.LOCALE.TR,
                token: token
            };

            console.log('🔍 [CALLBACK] Retrieving payment result...');

            iyzipay.checkoutForm.retrieve(retrieveRequest, async (err, result) => {
                if (err) {
                    console.error('❌ [CALLBACK] İyzico retrieve error:', err);
                    return res.redirect('https://practicotesting.com');
                }

                console.log('📦 [CALLBACK] Payment result received');
                console.log('   Status:', result.status);
                console.log('   Payment Status:', result.paymentStatus);
                console.log('   Basket ID:', result.basketId);

                if (result.status === 'success' && result.paymentStatus === 'SUCCESS') {
                    console.log('✅ [CALLBACK] Payment successful!');

                    const basketId = result.basketId;

                    if (!basketId) {
                        console.error('❌ [CALLBACK] No basketId in response');
                        return res.redirect('https://practicotesting.com');
                    }

                    console.log('🔍 [CALLBACK] Using basketId:', basketId);

                    const parts = basketId.split('_');

                    if (parts.length !== 2 || parts[0] !== 'basket') {
                        console.error('❌ [CALLBACK] Invalid basketId format:', basketId);
                        return res.redirect('https://practicotesting.com');
                    }

                    const userId = parts[1];
                    const paymentId = result.paymentId;

                    console.log('👤 [CALLBACK] Extracted User ID from basketId:', userId);

                    const user = await User.findById(userId);

                    if (!user) {
                        console.error('❌ [CALLBACK] User not found:', userId);
                        return res.redirect('https://practicotesting.com');
                    }

                    console.log('✅ [CALLBACK] User found:', user.email);

                    // ✅ Kullanıcıyı premium yap
                    user.isPaid = true;
                    user.isPaidMember = true;
                    user.membershipExpiryDate = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000);

                    // ✅ YENİ: Terms acceptance kaydet
                    user.acceptedTerms = true;
                    user.acceptedPreliminaryInformation = true;
                    user.termsAcceptanceDate = Date.now();

                    // ✅ Payment history güncelle
                    const paymentRecord = user.paymentHistory.find(
                        p => p.conversationId && p.conversationId.includes(userId)
                    );

                    if (paymentRecord) {
                        paymentRecord.status = 'SUCCESS';
                        paymentRecord.paymentId = paymentId;
                        paymentRecord.iyzicoPaymentId = result.iyzicoPaymentId || paymentId;
                    } else {
                        user.paymentHistory.push({
                            conversationId: basketId,
                            paymentId: paymentId,
                            iyzicoPaymentId: result.iyzicoPaymentId || paymentId,
                            amount: parseFloat(result.paidPrice),
                            currency: result.currency,
                            status: 'SUCCESS',
                            date: Date.now()
                        });
                    }

                    await user.save();

                    console.log(`💰 [CALLBACK] User ${user.email} is now premium member`);
                    console.log(`📋 [CALLBACK] Terms accepted and recorded`);

                    // ✅ Email gönder
                    try {
                        const mailOptions = {
                            from: process.env.AUTH_EMAIL,
                            to: user.email,
                            subject: "Payment Successful - PractiCo Premium",
                            html: `
                    <div style="font-family: Arial, sans-serif; padding: 20px;">
                        <h2 style="color: #4CAF50;">🎉 Payment Successful!</h2>
                        <p>Your payment has been processed successfully.</p>
                        <div style="background-color: #f9f9f9; padding: 20px; border-radius: 5px; margin: 20px 0;">
                            <p><strong>Amount:</strong> ${result.paidPrice} ${result.currency}</p>
                            <p><strong>Payment ID:</strong> ${paymentId}</p>
                            <p><strong>Expires:</strong> ${user.membershipExpiryDate.toLocaleDateString()}</p>
                        </div>
                        <p>You can now login and access all premium features!</p>
                        <p style="margin-top: 20px; font-size: 12px; color: #666;">
                            By completing this payment, you have accepted our Terms of Service, Privacy Policy, and Distance Sales Agreement.
                        </p>
                    </div>
                `
                        };

                        await transporter.sendMail(mailOptions);
                        console.log('📧 [CALLBACK] Success email sent');
                    } catch (mailErr) {
                        console.error('⚠️ [CALLBACK] Failed to send email:', mailErr);
                    }

                    return res.redirect('https://practicotesting.com');

                } else {
                    console.error('❌ [CALLBACK] Payment failed');
                    console.log('   Status:', result.status);
                    console.log('   Payment Status:', result.paymentStatus);

                    const basketId = result.basketId;
                    if (basketId && basketId.startsWith('basket_')) {
                        const parts = basketId.split('_');
                        if (parts.length === 2) {
                            const userId = parts[1];
                            const user = await User.findById(userId);

                            if (user) {
                                const paymentRecord = user.paymentHistory.find(
                                    p => p.conversationId && p.conversationId.includes(userId)
                                );

                                if (paymentRecord) {
                                    paymentRecord.status = 'FAILED';
                                    await user.save();
                                }
                            }
                        }
                    }

                    return res.redirect('https://practicotesting.com');
                }
            });

        } catch (err) {
            console.error('❌ [CALLBACK] Server error:', err);
            return res.redirect('https://practicotesting.com');
        }
    },
    //================================
    // 3. CHECK PAYMENT STATUS
    // ==========================================
    checkPaymentStatus: async function (req, res) {
        try {
            const { userId } = req.body;

            if (!userId) {
                return res.json({ success: false, msg: "User ID required" });
            }

            const user = await User.findById(userId);

            if (!user) {
                return res.json({ success: false, msg: "User not found" });
            }

            return res.json({
                success: true,
                isPaid: user.isPaid,
                isPaidMember: user.isPaidMember,
                membershipExpiryDate: user.membershipExpiryDate,
                acceptedTerms: user.acceptedTerms,
                acceptedPreliminaryInformation: user.acceptedPreliminaryInformation,
                termsAcceptanceDate: user.termsAcceptanceDate,
                lastPayment: user.paymentHistory[user.paymentHistory.length - 1]
            });

        } catch (err) {
            console.error('❌ [CHECK PAYMENT] Error:', err);
            return res.status(500).json({ success: false, msg: "Server error" });
        }
    },
    // AI part

    analyzeQuestion: async function (req, res) {
        await validateToken(req, res, async () => {
            try {
                const { questionImageUrl, conversationHistory } = req.body;

                if (!questionImageUrl) {
                    return res.json({ success: false, msg: "Question image URL required" });
                }

                console.log('🤖 [AI] Analyzing question:', questionImageUrl);

                // Gemini 1.5 Flash (vision + hızlı)
                const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

                // Resmi fetch et
                const imageResponse = await fetch(questionImageUrl);
                const imageBuffer = await imageResponse.arrayBuffer();
                const imageBase64 = Buffer.from(imageBuffer).toString('base64');

                // İlk analiz için prompt
                const firstAnalysisPrompt = `You are an expert tutor helping students prepare for the Bocconi entrance exam.

Analyze this question image and provide:
1. **Question Type**: (e.g., Mathematics, Logic, Reading Comprehension, etc.)
2. **Main Concept**: What is this question testing?
3. **Step-by-Step Solution**: Break down how to solve it
4. **Key Insights**: Important points to remember
5. **Answer**: The correct answer with explanation

Be clear, educational, and encouraging. Format your response in Markdown.`;

                // Conversation history varsa ekle
                let prompt = firstAnalysisPrompt;
                let parts = [
                    {
                        inlineData: {
                            mimeType: "image/png",
                            data: imageBase64
                        }
                    },
                    { text: prompt }
                ];

                // Eğer conversation history varsa, chat olarak devam et
                if (conversationHistory && conversationHistory.length > 0) {
                    const lastUserMessage = conversationHistory[conversationHistory.length - 1];
                    prompt = lastUserMessage.text;
                    parts = [{ text: prompt }];
                }

                const result = await model.generateContent(parts);
                const response = await result.response;
                const text = response.text();

                console.log('✅ [AI] Analysis complete');

                return res.json({
                    success: true,
                    analysis: text,
                    usage: {
                        promptTokens: response.usageMetadata?.promptTokenCount || 0,
                        completionTokens: response.usageMetadata?.candidatesTokenCount || 0,
                        totalTokens: response.usageMetadata?.totalTokenCount || 0
                    }
                });

            } catch (err) {
                console.error('❌ [AI] Error:', err);
                return res.status(500).json({
                    success: false,
                    msg: "AI analysis failed",
                    error: err.message
                });
            }
        });
    },

    // Chat continuation için endpoint
    chatWithAI: async function (req, res) {
        await validateToken(req, res, async () => {
            try {
                const { questionImageUrl, userMessage, conversationHistory } = req.body;

                if (!userMessage) {
                    return res.json({ success: false, msg: "Message required" });
                }

                console.log('💬 [AI] Chat message:', userMessage);

                const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

                // Resmi ilk mesajda gönder
                let parts = [];

                if (conversationHistory.length === 0 && questionImageUrl) {
                    const imageResponse = await fetch(questionImageUrl);
                    const imageBuffer = await imageResponse.arrayBuffer();
                    const imageBase64 = Buffer.from(imageBuffer).toString('base64');

                    parts = [
                        {
                            inlineData: {
                                mimeType: "image/png",
                                data: imageBase64
                            }
                        },
                        { text: `This is a Bocconi entrance exam question. ${userMessage}` }
                    ];
                } else {
                    // Conversation history'yi kur
                    const chatHistory = conversationHistory.map(msg => ({
                        role: msg.role,
                        parts: [{ text: msg.text }]
                    }));

                    const chat = model.startChat({
                        history: chatHistory,
                    });

                    const result = await chat.sendMessage(userMessage);
                    const response = await result.response;
                    const text = response.text();

                    return res.json({
                        success: true,
                        response: text,
                        usage: {
                            promptTokens: response.usageMetadata?.promptTokenCount || 0,
                            completionTokens: response.usageMetadata?.candidatesTokenCount || 0,
                            totalTokens: response.usageMetadata?.totalTokenCount || 0
                        }
                    });
                }

                // İlk mesaj için
                const result = await model.generateContent(parts);
                const response = await result.response;
                const text = response.text();

                console.log('✅ [AI] Response generated');

                return res.json({
                    success: true,
                    response: text,
                    usage: {
                        promptTokens: response.usageMetadata?.promptTokenCount || 0,
                        completionTokens: response.usageMetadata?.candidatesTokenCount || 0,
                        totalTokens: response.usageMetadata?.totalTokenCount || 0
                    }
                });

            } catch (err) {
                console.error('❌ [AI] Chat error:', err);
                return res.status(500).json({
                    success: false,
                    msg: "Chat failed",
                    error: err.message
                });
            }
        });
    }



}

module.exports = functions;