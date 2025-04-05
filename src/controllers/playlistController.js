const express = require('express');
const Playlist = require('../models/Playlist');
const Song = require('../models/Song');
const mongoose = require('mongoose');
const cloudinary = require('../cloudinary');

// Lấy tất cả playlist
const getAllPlaylists = async (req, res) => {
    try {
        const playlists = await Playlist.find();  // Xóa phần populate account
        return res.status(200).json(playlists);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Lấy playlist theo ID
const getPlaylistById = async (req, res) => {
    try {
        const playlist = await Playlist.findById(req.params.id); // Xóa phần populate account
        if (!playlist) {
            return res.status(404).json({ message: 'Playlist không tìm thấy' });
        }
        return res.status(200).json(playlist);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Upload hình ảnh lên Cloudinary
const uploadImageToCloudinary = async (base64Image) => {
    return new Promise((resolve, reject) => {
        cloudinary.uploader.upload(base64Image, { resource_type: 'image' }, (error, result) => {
            if (error) {
                console.error('Lỗi khi tải lên Cloudinary:', error);
                return reject(error);
            }
            resolve(result.secure_url);
        });
    });
};

// Tạo playlist mới với ảnh Base64 upload lên Cloudinary
const createPlaylist = async (req, res) => {
    try {
        const { name, artist, image } = req.body;

        if (!name || !artist || !image) {
            return res.status(400).json({ message: 'Thiếu thông tin bắt buộc' });
        }

        // Upload ảnh Base64 lên Cloudinary
        let imageUrl;
        try {
            imageUrl = await uploadImageToCloudinary(image);
        } catch (uploadError) {
            return res.status(500).json({ message: 'Lỗi khi tải ảnh lên Cloudinary', error: uploadError.message });
        }

        // Tạo playlist mới với URL ảnh từ Cloudinary
        const newPlaylist = new Playlist({ 
            name, 
            image: imageUrl, 
            artist, 
        });

        await newPlaylist.save();
        return res.status(201).json(newPlaylist);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Thêm bài hát vào playlist
const addSongToPlaylist = async (req, res) => {
    const { playlistId, songId } = req.body;

    // Kiểm tra ObjectId
    if (!mongoose.Types.ObjectId.isValid(playlistId) || !mongoose.Types.ObjectId.isValid(songId)) {
        return res.status(400).json({ message: 'ID không hợp lệ' });
    }

    const playlist = await Playlist.findById(playlistId);
    if (!playlist) {
        return res.status(404).json({ message: 'Playlist không tồn tại' });
    }

    // Tìm bài hát nhưng chỉ lấy bài đã được approved
    const song = await Song.findOne({ _id: songId, status: 'approved' });
    if (!song) {
        return res.status(400).json({ message: 'Bài hát không tồn tại hoặc chưa được duyệt' });
    }

    // Kiểm tra khớp nghệ sĩ
    if (playlist.artist !== song.artist) {
        return res.status(400).json({ message: 'Artist của bài hát không khớp với artist của playlist' });
    }

    // Tránh thêm trùng
    if (!playlist.songs.includes(song._id)) {
        playlist.songs.push(song._id);
        await playlist.save();
    }

    return res.status(200).json({ message: 'Đã thêm bài hát vào playlist', playlist });
};





// Lấy bài hát trong playlist
const getSongsInPlaylist = async (req, res) => {
    try {
        const { playlistId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(playlistId)) {
            return res.status(400).json({ message: 'ID playlist không hợp lệ' });
        }

        const playlist = await Playlist.findById(playlistId).populate('songs');

        if (!playlist) {
            return res.status(404).json({ message: 'Playlist không tồn tại' });
        }

        return res.status(200).json({ songs: playlist.songs });
    } catch (error) {
        console.error("Lỗi khi lấy danh sách bài hát:", error);
        return res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
};
// playlistController.js
const getSongsByArtist = async (req, res) => {
    try {
        const artist = String(req.query.artist || '').trim();

        if (!artist) {
            return res.status(400).json({ message: 'Nghệ sĩ không hợp lệ' });
        }

        // Kiểm tra xem nghệ sĩ có tồn tại trong bất kỳ playlist nào không
        const artistExistsInPlaylist = await Playlist.exists({ artist });

        // if (!artistExistsInPlaylist) {
        //     return res.status(404).json({ message: 'Không có playlist nào của nghệ sĩ này' });
        // }

        // Lấy các bài hát đã duyệt của nghệ sĩ đó
        const songs = await Song.find({
            artist,
            status: 'approved'
        }).select('name artist url image');

        if (!songs.length) {
            return res.status(404).json({ message: 'Không tìm thấy bài hát nào đã duyệt của nghệ sĩ này' });
        }

        return res.status(200).json({ songs });
    } catch (error) {
        console.error("Lỗi khi lấy bài hát theo nghệ sĩ:", error);
        return res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
};












module.exports = {
    getAllPlaylists,
    getPlaylistById,
    createPlaylist,
    addSongToPlaylist,
    getSongsInPlaylist,
    getSongsByArtist
};
