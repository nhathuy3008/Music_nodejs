const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favoriteController'); // Đảm bảo đường dẫn này đúng

router.post('/like', favoriteController.likeSong);
router.get('/account/:accountId/songs', favoriteController.getFavoriteSongs);
router.get('/song/:songId/likes/count', favoriteController.countLikesForSong);
router.get('/account/:accountId/song/:songId/liked', favoriteController.isSongLiked);
router.delete('/unlike/:accountId/:songId', (req, res) => {
    console.log('Yêu cầu DELETE nhận được với params:', req.params);
    favoriteController.unlikeSong(req, res);
});
module.exports = router;