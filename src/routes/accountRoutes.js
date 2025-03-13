const express = require('express');
const router = express.Router();
const accountController = require('../controllers/accountController');

router.post('/create', accountController.createAccount);
router.get('/verify', accountController.verifyAccount);
router.post('/login', accountController.login);
router.get('/', accountController.getAllAccounts);
router.get('/:id', accountController.getAccountById);
router.put('/:id', accountController.updateAccount);
router.post('/validate-password', accountController.validatePassword);
router.post('/verify', accountController.verifyAccount);

// Route để gửi mã xác minh quên mật khẩu
router.post('/forgot-password', accountController.forgotPassword);
// Route để đặt lại mật khẩu
router.post('/reset-password', accountController.resetPassword);
// Route để xác minh mã xác nhận
router.post('/verify-code', accountController.verifyCode); // Thêm route xác minh mã
module.exports = router;