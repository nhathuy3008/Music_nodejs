const jwt = require('jsonwebtoken');
const Account = require('../models/Account');

const verifyAdmin = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(403).json({ message: 'Không có token, quyền truy cập bị từ chối!' });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Tìm tài khoản và kiểm tra role
        const account = await Account.findById(decoded.id).populate('roles');

        if (!account) {
            return res.status(403).json({ message: 'Tài khoản không tồn tại!' });
        }

        // Kiểm tra xem account có role 'admin' không
        const isAdmin = account.roles.some(role => role.name.toLowerCase() === 'admin');

        if (!isAdmin) {
            return res.status(403).json({ message: 'Bạn không có quyền thực hiện thao tác này!' });
        }

        req.user = account;
        next(); // Tiếp tục thực hiện request
    } catch (error) {
        return res.status(401).json({ message: 'Xác thực thất bại!' });
    }
};

module.exports = verifyAdmin;
