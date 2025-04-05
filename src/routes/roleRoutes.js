const express = require('express');
const roleController = require('../controllers/roleController');
const  verifyAdmin  = require('../middleware/authMiddleware');

const router = express.Router();

// Lấy tất cả vai trò (chỉ admin)
router.get('/', verifyAdmin, roleController.getAllRoles);

// Lấy vai trò theo ID (chỉ admin)
router.get('/:id', verifyAdmin, roleController.getRoleById);

// Tạo vai trò mới (chỉ admin)
router.post('/create', verifyAdmin, roleController.createRole);

// Cập nhật vai trò (chỉ admin)
router.put('/:id', verifyAdmin, roleController.updateRole);

// Xóa vai trò (chỉ admin)
router.delete('/:id', verifyAdmin, roleController.deleteRole);

// Gán vai trò cho tài khoản (chỉ admin)
router.post('/assign', verifyAdmin, roleController.assignRoleToAccount);

module.exports = router;