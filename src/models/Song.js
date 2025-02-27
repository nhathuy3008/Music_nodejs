const mongoose = require('mongoose');
const { Schema } = mongoose;

const songSchema = new Schema({
    fileName: {
        type: String,
        required: true, // Bắt buộc nếu cần
    },
    name: {
        type: String,
        required: [true, 'Tên bài hát là bắt buộc !!!'],
    },
    artist: {
        type: String,
        required: [true, 'Tên nghệ sĩ là bắt buộc!'],
    },
    url: {
        type: String,
        required: [true, 'URL bài hát là bắt buộc!'],
    },
    image: {
        type: String,
        required: false, // Có thể không bắt buộc
    },
    category: {
        type: Schema.Types.ObjectId,
        ref: 'Category', // Tham chiếu đến mô hình Category
        required: true, // Bắt buộc
    },
    likeCount: {
        type: Number,
        default: 0, // Giá trị mặc định
    },
    commentCount: {
        type: Number,
        default: 0, // Giá trị mặc định
    }
}, { timestamps: true }); // Tự động thêm createdAt và updatedAt

module.exports = mongoose.model('Song', songSchema);