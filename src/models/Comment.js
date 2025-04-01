const mongoose = require('mongoose');
const { Schema } = mongoose;

// Định nghĩa mô hình Comment
const commentSchema = new Schema({
    comment: {
        type: String,
        required: [true, 'Bình luận bắt buộc điền'], // Thêm thông báo lỗi
    },
    account: {
        type: Schema.Types.ObjectId,
        ref: 'Account', // Tham chiếu đến mô hình Account
        required: true, // Bắt buộc nếu cần
    },
    song: {
        type: Schema.Types.ObjectId,
        ref: 'Song', // Tham chiếu đến mô hình Song
        required: true, // Bắt buộc nếu cần
    },
}, { timestamps: true }); // Tự động thêm createdAt và updatedAt

module.exports = mongoose.model('Comment', commentSchema);