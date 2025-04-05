const Notification = require('../models/Notification');

const getNotifications = async (req, res) => {
    try {
        const { accountId } = req.params;

        const notifications = await Notification.find({ account: accountId })
            .sort({ createdAt: -1 }); // Mới nhất trước

        res.status(200).json(notifications);
    } catch (error) {
        res.status(500).json({ message: 'Lỗi khi lấy thông báo.' });
    }
};
const markNotificationsAsRead = async (req, res) => {
    try {
      const { accountId } = req.params;
  
      await Notification.updateMany(
        { account: accountId, isRead: false }, // chỉ update thông báo chưa đọc
        { $set: { isRead: true } }
      );
  
      res.status(200).json({ message: 'Đã đánh dấu tất cả thông báo là đã đọc.' });
    } catch (error) {
      console.error("Lỗi đánh dấu đã đọc:", error);
      res.status(500).json({ message: 'Lỗi khi đánh dấu thông báo đã đọc.' });
    }
  };
  const countUnreadNotifications = async (req, res) => {
    try {
      const { accountId } = req.params;
  
      const count = await Notification.countDocuments({
        account: accountId,
        isRead: false,
      });
  
      res.status(200).json({ unreadCount: count });
    } catch (error) {
      console.error('Lỗi khi đếm thông báo chưa đọc:', error);
      res.status(500).json({ message: 'Lỗi server khi đếm thông báo.' });
    }
  };
  

module.exports = { getNotifications,markNotificationsAsRead,countUnreadNotifications};
