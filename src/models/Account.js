const mongoose = require('mongoose');
const validator = require('validator');

const accountSchema = new mongoose.Schema({
    id: {
        type: String,
        default: () => new mongoose.Types.ObjectId().toString(),
        unique: true
    },
    fullName: {
        type: String,
        required: [true, 'Họ và tên bắt buộc điền']
    },
    email: {
        type: String,
        required: [true, 'Email bắt buộc điền'],
        validate: [validator.isEmail, 'Vui lòng nhập một địa chỉ email hợp lệ']
    },
    password: {
        type: String,
        required: [true, 'Mật khẩu bắt buộc điền']
    },
    image: {
        type: String,
        default: null
    },
    enabled: {
        type: Boolean,
        default: false
    },
    verificationToken: {
        type: String,
        default: null
    },
    roles: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Role'
    }]
});

module.exports = mongoose.model('Account', accountSchema);
