const mongoose = require('mongoose');
const { Schema } = mongoose;

// Định nghĩa mô hình Playlist
const playlistSchema = new Schema({
    name: {
        type: String,
        required: [true, 'Tên playlist là bắt buộc'],
    },
    image: {
        type: String, // Đường dẫn hoặc URL ảnh của playlist
        required: [true, 'Ảnh playlist là bắt buộc'],
    },
    artist: {
        type: String, // Tên nghệ sĩ
        required: [true, 'Tên nghệ sĩ là bắt buộc'],
    },
    songs: [{
        type: Schema.Types.ObjectId,
        ref: 'Song', // Tham chiếu đến mô hình Song
        default: []
    }],
}, { timestamps: true }); // Tự động thêm createdAt và updatedAt

module.exports = mongoose.model('Playlist', playlistSchema);
