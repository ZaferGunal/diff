const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const practiceTestSchema = new Schema({
    index: {
        type: Number,      // 1, 2, 3, 4
        required: true,
        unique: true
    },
    title: {
        type: String,
        required: true
    },
    answerKey: {
        type: [String],    // ["A","B","C", ...] → 50 eleman
        required: true
    },
    questionURLs: {
        type: [String],    // 50 URL
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("PracticeTest", practiceTestSchema);
