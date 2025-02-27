const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload'); // Middleware upload file
const songController = require('../controllers/songController');

// Định tuyến cho các chức năng
// router.post('/songs', upload.single('file'), songController.createSong); // Thêm nhạc
router.post('/songs', upload, songController.createSong); // Thêm nhạc
router.put('/songs/:id', songController.updateSong); // Cập nhật nhạc
router.delete('/songs/:id', songController.deleteSong); // Xóa nhạc
router.get('/songs/search/:key', songController.searchSongs);
router.get('/songs/play/:id', songController.playSongById); // Thêm route này

module.exports = router;