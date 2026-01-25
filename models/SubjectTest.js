const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const subjectTestSchema = new Schema({
    subject: {
        type: String,
        enum: [
            "Mathematics",
            "Reading Comprehension",
            "Logic",
            "Critical Thinking",
            "Numerical Reasoning"

        ],
        required: true
    },
    index: {
        type: Number,     // 1–10
        required: true
    },
    answerKey: {
        type: [String],   // 10 eleman
        required: true
    },
    questionURLs: {
        type: [String],   // 10 URL
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    topic: {
        type: String,
        default: "unknown"
    }

});

module.exports = mongoose.model("SubjectTest", subjectTestSchema);
