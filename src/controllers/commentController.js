require('dotenv').config();
console.log("HUGGINGFACE_TOKEN from commentController:", process.env.HUGGINGFACE_TOKEN);


const Comment = require('../models/Comment'); // Đảm bảo đường dẫn đến model là chính xác
const Account = require('../models/Account');
const Song = require('../models/Song');
const axios = require('axios'); // Cài đặt axios nếu chưa có

const HUGGINGFACE_API_URL = "https://api-inference.huggingface.co/models/unitary/toxic-bert";
const HUGGINGFACE_TOKEN = process.env.HUGGINGFACE_TOKEN; // Lấy từ biến môi trường



// Endpoint để tạo một bình luận mới
const createComment = async (req, res) => {
    try {
        const { comment, account, song } = req.body;

        // Kiểm tra xem người dùng và bài hát có tồn tại không
        const userAccount = await Account.findById(account);
        const songRecord = await Song.findById(song);
        
        if (!userAccount) {
            return res.status(400).json({ message: "Người dùng không tồn tại" });
        }
        
        if (!songRecord) {
            return res.status(400).json({ message: "Bài hát không tồn tại" });
        }

        // Kiểm tra bình luận xem có phải là không phù hợp không
        if (await isCommentInappropriate(comment)) {
            return res.status(400).json({ message: getReplacementComment() }); // Trả về bình luận thay thế
        }

        // Tạo một bình luận mới
        const newComment = new Comment({ comment, account: userAccount._id, song: songRecord._id });
        
        // Lưu bình luận vào cơ sở dữ liệu
        await newComment.save();

        // Tăng commentCount của bài hát
        songRecord.commentCount += 1;
        await songRecord.save(); // Lưu thay đổi vào cơ sở dữ liệu

        return res.status(201).json({ message: "Bình luận đã được thêm thành công!" });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Hàm kiểm tra bình luận có phải là độc hại không
const isCommentInappropriate = async (comment) => {
    if (!comment || comment.trim().length === 0) {
        return false; // Không kiểm tra nếu bình luận rỗng
    }

    try {
        const response = await axios.post(HUGGINGFACE_API_URL, {
            inputs: comment,
        }, {
            headers: {
                Authorization: `Bearer ${HUGGINGFACE_TOKEN}`,
                'Content-Type': 'application/json',
            },
        });

        if (response.status === 200) {
            const toxicityScore = response.data[0][0].score; // Giả định rằng nhãn đầu tiên là nhãn "toxic"
            return toxicityScore > 0.35; // Ngưỡng có thể điều chỉnh  
        }
    } catch (error) {
        console.error("Lỗi khi gửi yêu cầu đến API:", error.message);
        return true; // Nếu có lỗi khi gửi yêu cầu, coi như bình luận là không phù hợp
    }
    return false; // Mặc định không độc hại
};

// Hàm trả về bình luận thay thế
const getReplacementComment = () => {
    return "Bạn hãy giữ bình tĩnh và comment văn minh hơn!";
};

// Các endpoint khác...
const getCommentsBySongId = async (req, res) => {
    try {
        const songId = req.params.songId; // Lấy ID bài hát từ tham số

        // Tìm tất cả bình luận cho bài hát
        const comments = await Comment.find({ song: songId }).populate('account', 'fullName'); // Thay đổi để lấy tên người dùng

        return res.status(200).json(comments);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};
const deleteComment = async (req, res) => {
    try {
        const commentId = req.params.id; // Lấy ID bình luận từ tham số

        // Tìm và xóa bình luận
        const deletedComment = await Comment.findByIdAndDelete(commentId);

        if (!deletedComment) {
            return res.status(404).json({ message: "Bình luận không tồn tại" });
        }

        // Cập nhật commentCount của bài hát nếu cần
        const songId = deletedComment.song;
        await Song.findByIdAndUpdate(songId, { $inc: { commentCount: -1 } }); // Giảm commentCount

        return res.status(204).send(); // Trả về mã trạng thái 204 Không nội dung
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};
const getCommentCountBySongId = async (req, res) => {
    try {
        const songId = req.params.songId; // Lấy ID bài hát từ tham số

        // Tính tổng số bình luận cho bài hát
        const count = await Comment.countDocuments({ song: songId });

        return res.status(200).json({ count }); // Trả về số lượng bình luận
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createComment,
    getCommentsBySongId,
    deleteComment,
    getCommentCountBySongId,
};