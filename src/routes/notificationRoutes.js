const express = require('express');
const router = express.Router();
const { getNotifications,markNotificationsAsRead,countUnreadNotifications } = require('../controllers/notificationController');

router.get('/:accountId', getNotifications);
router.post('/mark-read/:accountId',markNotificationsAsRead);
router.get('/unread-count/:accountId', countUnreadNotifications);
module.exports = router;
