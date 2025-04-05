const express = require('express');
const {
    getAllPlaylists,
    getPlaylistById,
    createPlaylist,
    addSongToPlaylist,
    getSongsInPlaylist,
    getSongsByArtist
} = require('../controllers/playlistController');

const router = express.Router();

// Route cụ thể nên đặt trước
router.get('/songs', getSongsByArtist);
router.get('/', getAllPlaylists);
router.get('/:playlistId/songs', getSongsInPlaylist);
router.post('/create', createPlaylist);
router.post('/add-song', addSongToPlaylist);

// Route động nên đặt sau cùng
router.get('/:id', getPlaylistById);

module.exports = router;
