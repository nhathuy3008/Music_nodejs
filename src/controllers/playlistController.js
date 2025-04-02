const express = require('express');
const Playlist = require('../models/Playlist');
const Song = require('../models/Song');
const mongoose = require('mongoose');
const cloudinary = require('../cloudinary');
// Lấy tất cả playlist
const getAllPlaylists = async (req, res) => {
    try {
        const playlists = await Playlist.find().populate('account', 'fullName email');
        return res.status(200).json(playlists);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Lấy playlist theo ID
const getPlaylistById = async (req, res) => {
    try {
        const playlist = await Playlist.findById(req.params.id).populate('account', 'fullName email');
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
        const { name, artist, account, image } = req.body;

        if (!name || !artist || !account || !image) {
            return res.status(400).json({ message: 'Thiếu thông tin bắt buộc' });
        }

        // Chuyển đổi account thành ObjectId
        if (!mongoose.Types.ObjectId.isValid(account)) {
            return res.status(400).json({ message: 'ID tài khoản không hợp lệ' });
        }
        const accountId = new mongoose.Types.ObjectId(account);

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
            account: accountId 
        });

        await newPlaylist.save();
        return res.status(201).json(newPlaylist);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};


// Thêm bài hát vào playlist
const addSongToPlaylist = async (req, res) => {
    try {
        const { playlistId, songId } = req.body; // Lấy dữ liệu từ body

        if (!mongoose.Types.ObjectId.isValid(playlistId) || !mongoose.Types.ObjectId.isValid(songId)) {
            return res.status(400).json({ message: 'ID không hợp lệ' });
        }

        const playlist = await Playlist.findById(playlistId);
        const song = await Song.findById(songId);

        if (!playlist || !song) {
            return res.status(404).json({ message: 'Playlist hoặc bài hát không tồn tại' });
        }

        if (playlist.artist !== song.artist) {
            return res.status(400).json({ message: 'Artist của bài hát không khớp với artist của playlist' });
        }

        if (!playlist.songs.includes(songId)) {
            playlist.songs.push(songId);
            await playlist.save();
        }

        return res.status(200).json(playlist);
    } catch (error) {
        console.error("Lỗi chi tiết:", error);
        return res.status(500).json({ message: "Lỗi server", error: error.message });
    }
};

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

module.exports = {
    getAllPlaylists,
    getPlaylistById,
    createPlaylist,
    addSongToPlaylist,
    getSongsInPlaylist
};
