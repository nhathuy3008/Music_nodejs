const mongoose = require('mongoose');
const Favorite = require('../models/Favorite'); // Đường dẫn tới mô hình Favorite
const Account = require('../models/Account'); // Đường dẫn tới mô hình Account
const Song = require('../models/Song'); // Đường dẫn tới mô hình Song

// Thích bài hát
const likeSong = async (req, res) => {
    try {
        const { accountId, songId } = req.body;

        // Kiểm tra xem đã thích bài hát chưa
        const existingFavorite = await Favorite.findOne({ account: accountId, song: songId });
        if (existingFavorite) {
            return res.status(400).json({ message: 'Bạn đã thích bài hát này rồi.' });
        }

        // Tạo mục yêu thích
        const favorite = new Favorite({
            account: accountId,
            song: songId
        });

        // Lưu vào cơ sở dữ liệu
        await favorite.save();

        // Cập nhật số lượt thích cho bài hát
        await Song.findByIdAndUpdate(songId, { $inc: { likeCount: 1 } });

        return res.status(200).json(favorite);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Lấy danh sách bài hát yêu thích theo tài khoản
const getFavoriteSongs = async (req, res) => {
    try {
        const { accountId } = req.params;

        // Lấy danh sách yêu thích, populate song
        const favorites = await Favorite.find({ account: accountId }).populate('song');
        // Lọc bỏ các favorite có song là null (bị xóa)
        const favoriteSongs = favorites
            .filter(fav => fav.song !== null)
            .map(fav => fav.song);

        return res.status(200).json(favoriteSongs);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};


// Đếm số lượt thích cho bài hát
const countLikesForSong = async (req, res) => {
    try {
        const { songId } = req.params;
        const likeCount = await Favorite.countDocuments({ song: songId });

        // In ra tổng lượt thích
        console.log(`Tổng lượt thích cho bài hát với ID ${songId}: ${likeCount}`);

        return res.status(200).json(likeCount);
    } catch (error) {
        console.error(error); // In lỗi ra console để dễ theo dõi
        return res.status(500).json({ message: error.message });
    }
};
const unlikeSong = async (req, res) => {
    try {
        const { accountId, songId } = req.params;

        // Chuyển đổi các ID thành ObjectId
        // Khởi tạo ObjectId bằng từ khóa new
        const accountObjectId = new mongoose.Types.ObjectId(accountId);
        const songObjectId = new mongoose.Types.ObjectId(songId);

        // Xóa mục yêu thích
        const result = await Favorite.deleteOne({ account: accountObjectId, song: songObjectId });

        if (result.deletedCount > 0) {
            // Cập nhật số lượt thích cho bài hát (giảm 1)
            await Song.findByIdAndUpdate(songObjectId, { $inc: { likeCount: -1 } });
            return res.status(200).json("Bạn đã hủy thích bài hát này.");
        } else {
            return res.status(200).json("Bạn chưa thích bài hát này.");
        }
    } catch (error) {
        console.error(error); // Ghi lỗi ra console
        return res.status(500).json({ message: error.message });
    }
};

// Kiểm tra xem bài hát có được thích hay không
const isSongLiked = async (req, res) => {
    try {
        const { accountId, songId } = req.params;

        // Kiểm tra xem tài khoản đã thích bài hát chưa
        const isLiked = await Favorite.exists({ account: accountId, song: songId });

        // Trả về true hoặc false dựa trên kết quả
        return res.status(200).json(!!isLiked); // Sử dụng !! để chuyển đổi kết quả sang boolean
    } catch (error) {
        console.error(error); // Ghi lỗi ra console để dễ theo dõi
        return res.status(500).json({ message: error.message });
    }
};

module.exports = {
    likeSong,
    getFavoriteSongs,
    countLikesForSong,
    unlikeSong,
    isSongLiked,
};