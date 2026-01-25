var mongoose = require("mongoose");
var bcrypt = require("bcrypt");

var Schema = mongoose.Schema;

var userSchema = new Schema({
    name: {
        type: String,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true
    },
    isDarkMode: {
        type: Boolean,
        default: false
    },
    practicesSolved: {
        type: [Boolean],
        default: [false, false, false, false]
    },
    practiceTest1Answers: {
        type: [String],
    },
    practiceTest2Answers: {
        type: [String],
    },
    practiceTest3Answers: {
        type: [String],
    },
    practiceTest4Answers: {
        type: [String],
    },
    practiceTestResults: {
        type: [{
            testNumber: {
                type: Number,
                min: 1,
                max: 4
            },
            correctAnswers: {
                type: Number,
                default: 0
            },
            wrongAnswers: {
                type: Number,
                default: 0
            },
            emptyAnswers: {
                type: Number,
                default: 0
            },
            score: {
                type: Number,
                default: 0
            },
            date: {
                type: Date,
                default: Date.now
            }
        }],
        default: []
    },
    // ✅ Aktif session token (null = logout)
    activeSessionToken: {
        type: String,
        default: null,
        index: true
    },
    // ✅ YENİ: Son heartbeat zamanı
    lastHeartbeat: {
        type: Date,
        default: null
    },
    lastLoginDate: {
        type: Date,
        default: null
    },
    lastLoginDevice: {
        type: String,
        default: null
    },
    verified: {
        type: Boolean,
        default: false
    },
    // User Schema'ya eklenecek alanlar (practiceTestResults'tan sonra)
    isPaidMember: {
        type: Boolean,
        default: false
    },
    membershipExpiryDate: {
        type: Date,
        default: null
    },
    paymentHistory: {
        type: [{
            paymentId: String,
            amount: Number,
            currency: String,
            country: String,
            status: String, // SUCCESS, FAILED
            date: {
                type: Date,
                default: Date.now
            },
            iyzicoPaymentId: String,
            conversationId: String
        }],
        default: []

    },

    isPaid: {  // ✅ YENİ ALAN
        type: Boolean,
        default: false
    },

    acceptedTerms: {
        type: Boolean,
        default: false
    },
    acceptedPreliminaryInformation: {
        type: Boolean,
        default: false
    },
    termsAcceptanceDate: {
        type: Date,
        default: null
    }


});

// Hash password before saving
userSchema.pre("save", async function (next) {
    const user = this;

    if (!user.isModified("password")) return next();

    try {
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(user.password, salt);
        user.password = hash;
        next();
    } catch (err) {
        next(err);
    }
});

// Compare password method
userSchema.methods.comparePassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model("User", userSchema);