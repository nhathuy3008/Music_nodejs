const express = require('express');
const {
    getAllPlaylists,
    getPlaylistById,
    createPlaylist,
    addSongToPlaylist,
    getSongsInPlaylist
} = require('../controllers/playlistController');

const router = express.Router();

router.get('/', getAllPlaylists); // Lấy tất cả playlist
router.get('/:id', getPlaylistById); // Lấy playlist theo ID
router.post('/create', createPlaylist); // Tạo playlist mới
router.post('/add-song', addSongToPlaylist);
router.get('/:playlistId/songs', getSongsInPlaylist);


module.exports = router;
