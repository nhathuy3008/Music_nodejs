const Song = require('../models/Song');
const cloudinary = require('../cloudinary');
const { v4: uuidv4 } = require('uuid'); // Thư viện để tạo ID ngẫu nhiên

// Thêm nhạc
const createSong = async (req, res) => {
    try {
        // Kiểm tra xem file có tồn tại không
        if (!req.files || !req.files.file) {
            return res.status(400).json({ message: 'File nhạc không được gửi.' });
        }

        const musicFile = req.files.file[0]; // Lấy file nhạc từ req.files

        // Mã hóa file nhạc
        const musicBuffer = musicFile.buffer; // Lấy buffer từ file nhạc
        const musicBase64 = musicBuffer.toString('base64'); // Chuyển đổi sang base64

        // Upload file nhạc lên Cloudinary
        const musicResult = await cloudinary.uploader.upload(`data:${musicFile.mimetype};base64,${musicBase64}`, {
            resource_type: 'auto',
            public_id: uuidv4()
        });

        let imageUrl = null;

        // Kiểm tra hình ảnh
        if (req.files.image && req.files.image.length > 0) {
            const imageFile = req.files.image[0]; // Lấy file hình ảnh
            const imageBuffer = imageFile.buffer; // Lấy buffer từ hình ảnh
            const imageBase64 = imageBuffer.toString('base64'); // Chuyển đổi sang base64

            // Upload hình ảnh lên Cloudinary
            const imageResult = await cloudinary.uploader.upload(`data:${imageFile.mimetype};base64,${imageBase64}`, {
                resource_type: 'image',
                public_id: uuidv4()
            });
            imageUrl = imageResult.secure_url; // Lưu URL hình ảnh
        }

        const song = new Song({
            fileName: musicResult.public_id,
            name: req.body.name,
            artist: req.body.artist,
            url: musicResult.secure_url,
            image: imageUrl,
            category: req.body.category
        });

        await song.save();
        return res.status(201).json(song);
    } catch (error) {
        return res.status(400).json({ message: error.message });
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
        const song = await Song.findByIdAndDelete(id);
        if (!song) {
            return res.status(404).json({ message: 'Bài hát không tìm thấy' });
        }
        return res.status(200).json({ message: `Bài hát ${song.name} đã được xóa thành công!` });
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

// Xuất khẩu các hàm
module.exports = {
    createSong,
    updateSong,
    deleteSong,
    searchSongs,
    playSongById // Đảm bảo hàm này có ở đây
};