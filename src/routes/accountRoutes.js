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
module.exports = router;