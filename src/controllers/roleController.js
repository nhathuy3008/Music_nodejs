const Role = require('../models/Role');
const Account = require('../models/Account');
const roleController = require('../controllers/songController');
// Lấy tất cả vai trò
const getAllRoles = async (req, res) => {
    try {
        const roles = await Role.find();
        return res.status(200).json(roles);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Lấy vai trò theo ID
const getRoleById = async (req, res) => {
    const { id } = req.params;
    try {
        const role = await Role.findById(id);
        if (!role) {
            return res.status(404).json({ message: 'Vai trò không tìm thấy' });
        }
        return res.status(200).json(role);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Tạo vai trò mới
const createRole = async (req, res) => {
    try {
        const role = new Role(req.body);
        await role.save();
        return res.status(201).json(role);
    } catch (error) {
        return res.status(400).json({ message: error.message });
    }
};

// Cập nhật vai trò
const updateRole = async (req, res) => {
    const { id } = req.params;
    try {
        const role = await Role.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });
        if (!role) {
            return res.status(404).json({ message: 'Vai trò không tìm thấy' });
        }
        return res.status(200).json(role);
    } catch (error) {
        return res.status(400).json({ message: error.message });
    }
};

// Xóa vai trò
const deleteRole = async (req, res) => {
    const { id } = req.params;
    try {
        const role = await Role.findByIdAndDelete(id);
        if (!role) {
            return res.status(404).json({ message: 'Vai trò không tìm thấy' });
        }
        return res.status(200).json({ message: `Vai trò ${role.name} đã được xóa thành công!` });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};
const assignRoleToAccount = async (req, res) => {
    const { accountId, roleId } = req.body;

    try {
        // Kiểm tra tài khoản có tồn tại không
        const account = await Account.findById(accountId);
        if (!account) {
            return res.status(404).json({ message: 'Tài khoản không tồn tại' });
        }

        // Kiểm tra vai trò có tồn tại không
        const role = await Role.findById(roleId);
        if (!role) {
            return res.status(404).json({ message: 'Vai trò không tồn tại' });
        }

        // Kiểm tra nếu tài khoản đã có vai trò này chưa
        if (account.roles.includes(roleId)) {
            return res.status(400).json({ message: 'Tài khoản đã có vai trò này' });
        }

        // Thêm vai trò vào tài khoản
        account.roles.push(roleId);
        await account.save();

        return res.status(200).json({ message: 'Gán vai trò thành công', account });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getAllRoles,
    getRoleById,
    createRole,
    updateRole,
    deleteRole,
    assignRoleToAccount
};
