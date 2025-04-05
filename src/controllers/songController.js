const Song = require('../models/Song');
const cloudinary = require('../cloudinary');
const { v4: uuidv4 } = require('uuid'); // Thư viện để tạo ID ngẫu nhiên
const Notification = require('../models/Notification');
// Thêm nhạc

const createSong = async (req, res) => {
    try {
        if (!req.files || !req.files.file) {
            return res.status(400).json({ message: 'File nhạc không được gửi.' });
        }

        const musicFile = req.files.file[0];
        const musicBase64 = musicFile.buffer.toString('base64');

        const musicResult = await cloudinary.uploader.upload(
            `data:${musicFile.mimetype};base64,${musicBase64}`,
            { resource_type: 'auto', public_id: uuidv4() }
        );

        let imageUrl = null;
        if (req.files.image && req.files.image.length > 0) {
            const imageFile = req.files.image[0];
            const imageBase64 = imageFile.buffer.toString('base64');

            const imageResult = await cloudinary.uploader.upload(
                `data:${imageFile.mimetype};base64,${imageBase64}`,
                { resource_type: 'image', public_id: uuidv4() }
            );
            imageUrl = imageResult.secure_url;
        }

        const song = new Song({
            fileName: musicResult.public_id,
            name: req.body.name,
            artist: req.body.artist,
            url: musicResult.secure_url,
            image: imageUrl,
            category: req.body.category,
            account: req.body.account || null,  // 👈 Thêm dòng này
            status: 'pending'
        });

        await song.save();
        return res.status(201).json({ message: "Bài hát đang chờ xét duyệt!", song });
    } catch (error) {
        return res.status(400).json({ message: error.message });
    }
};

// Lấy tất cả bài hát
// const getAllSongs = async (req, res) => {
//     try {
//         const songs = await Song.find(); // Lấy tất cả bài hát từ cơ sở dữ liệu
//         return res.status(200).json(songs); // Trả về danh sách bài hát
//     } catch (error) {
//         return res.status(500).json({ message: error.message }); // Xử lý lỗi
//     }
// };
const getAllSongs = async (req, res) => {
    try {
        const songs = await Song.find({ status: 'approved' });
        return res.status(200).json(songs);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Cập nhật nhạc
const updateSong = async (req, res) => {
    const { id } = req.params;
    try {
        const song = await Song.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });
        if (!song) {
            return res.status(404).json({ message: 'Bài hát không tìm thấy' });
        }
        return res.status(200).json(song);
    } catch (error) {
        return res.status(400).json({ message: error.message });
    }
};

// Xóa nhạc
const deleteSong = async (req, res) => {
    const { id } = req.params;
    try {
        const song = await Song.findOneAndDelete({ _id: id, status: 'approved' });
        if (!song) {
            return res.status(404).json({ message: 'Bài hát không tìm thấy hoặc chưa được duyệt' });
        }
        return res.status(200).json({ message: `Bài hát "${song.name}" đã được xóa thành công!` });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Tìm kiếm theo key
const removeDiacritics = (str) => {
    return str
        .replace(/à|á|ả|ã|ạ/g, 'a')
        .replace(/è|é|ẻ|ẽ|ẹ/g, 'e')
        .replace(/ì|í|ỉ|ĩ|ị/g, 'i')
        .replace(/ò|ó|ỏ|õ|ọ/g, 'o')
        .replace(/ù|ú|ủ|ũ|ụ/g, 'u')
        .replace(/ỳ|ý|ỷ|ỹ|ỵ/g, 'y')
        .replace(/đ/g, 'd');
};

const searchSongs = async (req, res) => {
    const { key } = req.params; // Lấy từ khóa từ tham số route
    const sanitizedKey = removeDiacritics(key); // Loại bỏ dấu từ từ khóa tìm kiếm
    try {
        const songs = await Song.find({
            $or: [
                { name: { $regex: key, $options: 'i' } }, // Tìm theo tên bài hát có dấu
                { artist: { $regex: key, $options: 'i' } }, // Tìm theo tên nghệ sĩ có dấu
                { name: { $regex: sanitizedKey, $options: 'i' } }, // Tìm theo tên bài hát không có dấu
                { artist: { $regex: sanitizedKey, $options: 'i' } } // Tìm theo tên nghệ sĩ không có dấu
            ]
        });
        return res.status(200).json(songs); // Trả về danh sách bài hát
    } catch (error) {
        return res.status(500).json({ message: error.message }); // Xử lý lỗi
    }
};
// Phát nhạc theo ID
const playSongById = async (req, res) => {
    const { id } = req.params;
    try {
        const song = await Song.findById(id);
        if (!song) {
            return res.status(404).json({ message: 'Bài hát không tìm thấy' });
        }
        return res.status(200).json({ url: song.url });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};
const playSongByIdPending = async (req, res) => {
    const { id } = req.params;
    try {
        const song = await Song.findOne({ _id: id, status: 'pending' });
        if (!song) {
            return res.status(404).json({ message: 'Bài hát không có trong trạng thái pending' });
        }
        return res.status(200).json({ url: song.url });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

const updateSongStatus = async (req, res) => {
    try {
        const { songId } = req.params;
        const { status } = req.body;

        if (!['approved', 'rejected'].includes(status)) {
            return res.status(400).json({ message: 'Trạng thái không hợp lệ!' });
        }

        const song = await Song.findById(songId).populate('account');
        if (!song) {
            return res.status(404).json({ message: 'Bài hát không tồn tại!' });
        }

        song.status = status;
        await song.save();

        // Gửi thông báo
        const statusText = status === 'approved' ? 'được duyệt' : 'bị từ chối';
        const message = `Bài hát "${song.name}" của bạn đã ${statusText}.`;

        await Notification.create({
            account: song.account._id,
            message: message,
        });

        return res.status(200).json({ message: `Bài hát đã được cập nhật thành ${status}.`, song });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};
const getAllSongsPending = async (req, res) => {
    try {
        const songs = await Song.find({ status: 'pending' });
        return res.status(200).json(songs);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};
const getSongById = async (req, res) => {
    try {
      const songId = req.params.id;
      const song = await Song.findById(songId);
  
      if (!song) {
        return res.status(404).json({ message: 'Song not found' });
      }
  
      res.json(song); // Trả về bài hát dưới dạng JSON
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error' });
    }
};
const getPopularSongs = async (req, res) => {
    try {
        // Chỉ lấy các bài hát đã được duyệt và có số lượt like >= 1
        const songs = await Song.find({ status: 'approved', likeCount: { $gte: 1 } });
        return res.status(200).json(songs);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Xuất khẩu các hàm
module.exports = {
    createSong,
    updateSong,
    deleteSong,
    searchSongs,
    playSongById, // Đảm bảo hàm này có ở đây
    getAllSongs,
    updateSongStatus,
    getAllSongsPending,
    playSongByIdPending,
    getSongById,
    getPopularSongs
};