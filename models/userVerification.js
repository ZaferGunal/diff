var mongoose = require("mongoose");

var Schema = mongoose.Schema;

var userVerificationSchema = new Schema({
    userId: String,
    uniqueString: String,
    createdAt: Date,
    expiresAt: Date,
    verificationType: {
        type: String,
        enum: ['email_verification', 'password_reset'],
        default: 'email_verification'
    }
});

module.exports = mongoose.model("UserVerification", userVerificationSchema);