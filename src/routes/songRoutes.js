const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload'); // Middleware upload file
const songController = require('../controllers/songController');
const verifyAdmin = require('../middleware/authMiddleware');

// Định tuyến cho các chức năng
// router.post('/songs', upload.single('file'), songController.createSong); // Thêm nhạc
router.post('/songs', upload, songController.createSong); // Thêm nhạc
router.put('/songs/:id', songController.updateSong); // Cập nhật nhạc
router.delete('/songs/:id',verifyAdmin, songController.deleteSong); // Xóa nhạc
router.get('/songs/search/:key', songController.searchSongs);
router.get('/songs/play/:id', songController.playSongById); // Thêm route này
router.get('/songs', songController.getAllSongs); // Route mới để lấy tất cả bài hát
router.post('/songs/:songId/status', verifyAdmin, songController.updateSongStatus);
router.get('/songs/pending', verifyAdmin, songController.getAllSongsPending);
router.get('/songs/play/:id/pending', verifyAdmin, songController.playSongByIdPending);
router.get('/songs/popular', songController.getPopularSongs);
router.get('/songs/:id', songController.getSongById);

module.exports = router;