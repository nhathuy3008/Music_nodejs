const Account = require('../models/Account');
const { sendVerificationEmail } = require('../services/emailService');
const bcrypt = require("bcryptjs");
const cloudinary = require('../cloudinary');
const fetch = require('node-fetch');
const jwt = require('jsonwebtoken');
// Tạo tài khoản
const createAccount = async (req, res) => {
    const { fullName, email, password, image } = req.body;

    const existingAccount = await Account.findOne({ email });
    if (existingAccount) {
        return res.status(400).send('Email này đã được sử dụng.');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Tạo mã xác thực 6 số ngẫu nhiên
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();

    const newAccount = new Account({
        fullName,
        email,
        password: hashedPassword,
        verificationToken: verificationCode, // Lưu mã xác thực vào trường verificationToken
        enabled: false     // Mặc định là không xác thực
    });

    if (image) {
        try {
            let uploadedImage;
            if (image.startsWith("data:")) {
                uploadedImage = await uploadImageToCloudinary(image);
            } else {
                const base64Image = await convertImageUrlToBase64(image);
                uploadedImage = await uploadImageToCloudinary(base64Image);
            }
            newAccount.image = uploadedImage;
        } catch (error) {
            return res.status(500).send('Đã xảy ra lỗi khi tải lên ảnh.');
        }
    }

    await newAccount.save();

    try {
        await sendVerificationEmail(email, verificationCode); // Gửi mã xác thực
        res.status(201).send('Tài khoản đã được tạo. Vui lòng kiểm tra email để nhận mã xác thực.');
    } catch (error) {
        return res.status(500).send('Đã xảy ra lỗi khi gửi email xác thực.');
    }
};



// Xác thực tài khoản
const verifyAccount = async (req, res) => {
    const { email, code } = req.body; // Lấy email và mã từ body

    try {
        const account = await Account.findOne({ email });

        if (!account) {
            return res.status(404).json({
                status: "thất bại",
                message: "Tài khoản không tồn tại."
            });
        }

        // Kiểm tra mã xác thực
        if (account.verificationToken === code) {
            account.enabled = true; // Kích hoạt tài khoản
            account.verificationToken = null; // Xóa mã xác thực
            await account.save();
            return res.status(200).json({
                status: "thành công",
                message: "Tài khoản đã được xác thực thành công!"
            });
        } else {
            return res.status(400).json({
                status: "thất bại",
                message: "Mã xác thực không đúng."
            });
        }
    } catch (error) {
        return res.status(500).json({
            status: "thất bại",
            message: "Đã xảy ra lỗi khi xác thực tài khoản."
        });
    }
};

// Đăng nhập
// const login = async (req, res) => {
//     const { email, password } = req.body;
//     const account = await Account.findOne({ email });

//     if (!account) {
//         return res.status(401).json({
//             status: "thất bại",
//             message: "Tài khoản không tồn tại hoặc chưa được xác thực."
//         });
//     }

//     if (!account.enabled) {
//         return res.status(401).json({
//             status: "thất bại",
//             message: "Tài khoản chưa được xác thực."
//         });
//     }

//     const isMatch = await bcrypt.compare(password, account.password);
//     if (!isMatch) {
//         return res.status(401).json({
//             status: "thất bại",
//             message: "Mật khẩu không đúng."
//         });
//     }

//     // Nếu đăng nhập thành công, trả về thông tin tài khoản
//     res.status(200).json({
//         id: account._id,
//         fullName: account.fullName,
//         image: account.image, // Trả về URL hình ảnh
//         message: "Đăng nhập thành công",
//         status: "thành công"
//     });
// };
const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const account = await Account.findOne({ email }).populate('roles');

        if (!account) {
            return res.status(401).json({
                status: "thất bại",
                message: "Tài khoản không tồn tại hoặc chưa được xác thực."
            });
        }

        if (!account.enabled) {
            return res.status(401).json({
                status: "thất bại",
                message: "Tài khoản chưa được xác thực."
            });
        }

        const isMatch = await bcrypt.compare(password, account.password);
        if (!isMatch) {
            return res.status(401).json({
                status: "thất bại",
                message: "Mật khẩu không đúng."
            });
        }

        // Tạo token nếu đăng nhập thành công
        const token = jwt.sign(
            { id: account._id, roles: account.roles.map(role => role.name) },
            process.env.JWT_SECRET,  // Lấy secret từ file .env
            { expiresIn: '1h' } // Token có hiệu lực trong 1 giờ
        );

        res.status(200).json({
            id: account._id,
            fullName: account.fullName,
            image: account.image, 
            token, // Trả về token
            message: "Đăng nhập thành công",
            status: "thành công"
        });

    } catch (error) {
        res.status(500).json({ message: "Lỗi máy chủ", error: error.message });
    }
};

// Lấy thông tin tài khoản theo ID
const getAccountById = async (req, res) => {
    const { id } = req.params;

    try {
        const account = await Account.findById(id);

        if (!account) {
            return res.status(404).json({
                status: "thất bại",
                message: "Tài khoản không tồn tại."
            });
        }

        res.status(200).json({
            status: "thành công",
            account
        });
    } catch (error) {
        return res.status(500).json({
            status: "thất bại",
            message: "Đã xảy ra lỗi khi lấy thông tin tài khoản."
        });
    }
};

// Lấy tất cả tài khoản
const getAllAccounts = async (req, res) => {
    try {
        const accounts = await Account.find();
        res.status(200).json(accounts);
    } catch (error) {
        return res.status(500).json({
            status: "thất bại",
            message: "Đã xảy ra lỗi khi lấy danh sách tài khoản."
        });
    }
};

// Cập nhật tài khoản
// const updateAccount = async (req, res) => {
//     const { id } = req.params; // id từ tham số URL
//     const { fullName, password, image } = req.body;

//     try {
//         // Tìm tài khoản theo _id
//         const account = await Account.findById(id);
//         if (!account) {
//             return res.status(404).json({
//                 status: "thất bại",
//                 message: "Tài khoản không tồn tại."
//             });
//         }

//         // Kiểm tra và cập nhật fullName
//         if (fullName) {
//             console.log('Updating fullName from:', account.fullName, 'to:', fullName);
//             account.fullName = fullName; // Cập nhật fullName
//         }

//         // Cập nhật mật khẩu
//         if (password) {
//             console.log('Updating password.');
//             account.password = await bcrypt.hash(password, 10);
//         }

//         // Cập nhật hình ảnh
//         if (image) {
//             try {
//                 let uploadedImage;
//                 if (image.startsWith("data:")) {
//                     uploadedImage = await uploadImageToCloudinary(image);
//                 } else {
//                     const base64Image = await convertImageUrlToBase64(image);
//                     uploadedImage = await uploadImageToCloudinary(base64Image);
//                 }
//                 console.log('Updating image from:', account.image, 'to:', uploadedImage);
//                 account.image = uploadedImage; // Cập nhật hình ảnh
//             } catch (error) {
//                 console.error('Image upload error:', error);
//                 return res.status(500).json({
//                     status: "thất bại",
//                     message: "Đã xảy ra lỗi khi tải lên hình ảnh."
//                 });
//             }
//         }

//         // Gọi save() để lưu thay đổi
//         const updatedAccount = await account.save();
//         console.log('Updated Account:', updatedAccount); // Ghi log tài khoản đã cập nhật

//         res.status(200).json({
//             status: "thành công",
//             message: "Cập nhật tài khoản thành công!",
//             account: updatedAccount
//         });
//     } catch (error) {
//         console.error('Error updating account:', error);
//         return res.status(500).json({
//             status: "thất bại",
//             message: "Đã xảy ra lỗi khi cập nhật tài khoản."
//         });
//     }
// };


// // Tải ảnh lên Cloudinary
// const uploadImageToCloudinary = async (image) => {
//     return new Promise((resolve, reject) => {
//         if (image.startsWith("data:")) {
//             const base64Image = image.split(",")[1];
//             cloudinary.uploader.upload_stream({ resource_type: 'image' }, (error, result) => {
//                 if (error) {
//                     console.error('Error uploading to Cloudinary:', error);
//                     return reject(error);
//                 }
//                 resolve(result.secure_url); // Trả về URL hình ảnh đã tải lên
//             }).end(Buffer.from(base64Image, 'base64'));
//         } else {
//             resolve(image); // Nếu không phải base64, trả về URL
//         }
//     });
// };
// // Hàm chuyển đổi URL thành base64
// const convertImageUrlToBase64 = async (url) => {
//     const response = await fetch(url);
//     const buffer = await response.buffer();
//     return `data:image/jpeg;base64,${buffer.toString('base64')}`;
// };
// Chức năng để chuyển đổi URL hình ảnh thành base64
const convertImageUrlToBase64 = async (url) => {
    const response = await fetch(url);
    const buffer = await response.buffer();
    return `data:image/jpeg;base64,${buffer.toString('base64')}`;
};

// Chức năng cập nhật tài khoản
// Chức năng cập nhật tài khoản
const updateAccount = async (req, res) => {
    const { id } = req.params;
    const { fullName, password, image } = req.body; // Nhận ảnh base64 từ frontend

    try {
        const account = await Account.findById(id);
        if (!account) {
            return res.status(404).json({ status: "thất bại", message: "Tài khoản không tồn tại." });
        }

        // Cập nhật tên đầy đủ
        if (fullName) {
            account.fullName = fullName;
        }

        // Cập nhật mật khẩu
        if (password) {
            account.password = await bcrypt.hash(password, 10);
        }

        // Xử lý ảnh từ base64
        if (image && image.startsWith('data:image')) { // Kiểm tra có phải base64 không
            try {
                const uploadedImage = await uploadImageToCloudinary(image); // Upload base64 trực tiếp
                account.image = uploadedImage;
            } catch (error) {
                console.error('Image upload error:', error);
                return res.status(500).json({ status: "thất bại", message: "Đã xảy ra lỗi khi tải lên hình ảnh." });
            }
        }

        // Lưu tài khoản đã cập nhật
        const updatedAccount = await account.save();
        res.status(200).json({
            status: "thành công",
            message: "Cập nhật tài khoản thành công!",
            account: updatedAccount
        });
    } catch (error) {
        console.error('Error updating account:', error);
        return res.status(500).json({ status: "thất bại", message: "Đã xảy ra lỗi khi cập nhật tài khoản." });
    }
};


// Chức năng upload hình ảnh lên Cloudinary
const uploadImageToCloudinary = async (base64Image) => {
    return new Promise((resolve, reject) => {
        cloudinary.uploader.upload(base64Image, { resource_type: 'image' }, (error, result) => {
            if (error) {
                console.error('Error uploading to Cloudinary:', error);
                return reject(error);
            }
            resolve(result.secure_url);
        });
    });
};

// Xác thực mật khẩu
const validatePassword = async (req, res) => {
    const { id } = req.query;
    const oldPassword = req.query.oldPassword;

    try {
        const account = await Account.findById(id);
        if (!account) {
            return res.status(404).json({
                status: "thất bại",
                message: "Tài khoản không tồn tại."
            });
        }

        // Kiểm tra mật khẩu
        const isValid = await bcrypt.compare(oldPassword, account.password);
        if (isValid) {
            return res.status(200).json({
                message: "Mật khẩu hợp lệ",
                status: "thành công"
            });
        } else {
            return res.status(400).json({
                message: "Mật khẩu cũ không hợp lệ",
                status: "lỗi"
            });
        }
    } catch (error) {
        return res.status(500).json({
            status: "thất bại",
            message: "Đã xảy ra lỗi khi xác thực mật khẩu."
        });
    }
};
// Gửi mã xác minh để đặt lại mật khẩu
const forgotPassword = async (req, res) => {
    const { email } = req.body;

    try {
        const account = await Account.findOne({ email });
        if (!account) {
            return res.status(404).json({
                status: "thất bại",
                message: "Email không tồn tại."
            });
        }

        // Tạo mã xác minh ngẫu nhiên
        const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
        account.verificationToken = resetCode; // Lưu mã xác minh vào tài khoản
        await account.save();

        await sendVerificationEmail(email, resetCode); // Gửi email chứa mã xác minh
        res.status(200).json({
            status: "thành công",
            message: "Mã xác minh đã được gửi đến email của bạn."
        });
    } catch (error) {
        return res.status(500).json({
            status: "thất bại",
            message: "Đã xảy ra lỗi khi gửi mã xác minh."
        });
    }
};

// Đặt lại mật khẩu
const resetPassword = async (req, res) => {
    const { email, verificationCode, newPassword } = req.body;

    try {
        const account = await Account.findOne({ email });
        if (!account) {
            return res.status(404).json({
                status: "thất bại",
                message: "Tài khoản không tồn tại."
            });
        }

        // Kiểm tra mã xác minh trong cơ sở dữ liệu
        if (account.verificationToken !== verificationCode) {
            return res.status(400).json({
                status: "thất bại",
                message: "Mã xác minh không hợp lệ."
            });
        }

        // Cập nhật mật khẩu
        account.password = await bcrypt.hash(newPassword, 10);
        account.verificationToken = null; // Xóa mã xác minh sau khi đã sử dụng
        await account.save();

        res.status(200).json({
            status: "thành công",
            message: "Mật khẩu đã được thay đổi thành công."
        });
    } catch (error) {
        console.error(error); // Log lỗi để kiểm tra
        return res.status(500).json({
            status: "thất bại",
            message: "Đã xảy ra lỗi khi đặt lại mật khẩu."
        });
    }
};
// Xác minh mã xác nhận
const verifyCode = async (req, res) => {
    const { email, verificationCode } = req.body; // Lấy email và mã từ body

    try {
        const account = await Account.findOne({ email });

        if (!account) {
            return res.status(404).json({
                status: "thất bại",
                message: "Tài khoản không tồn tại."
            });
        }

        // Kiểm tra mã xác minh
        if (account.verificationToken === verificationCode) {
            account.enabled = true; // Kích hoạt tài khoản
            account.verificationToken = null; // Xóa mã xác thực
            await account.save();
            return res.status(200).json({
                status: "thành công",
                message: "Tài khoản đã được xác thực thành công!"
            });
        } else {
            return res.status(400).json({
                status: "thất bại",
                message: "Mã xác thực không đúng."
            });
        }
    } catch (error) {
        return res.status(500).json({
            status: "thất bại",
            message: "Đã xảy ra lỗi khi xác thực tài khoản."
        });
    }
};

module.exports = {
    createAccount,
    verifyAccount,
    login,
    getAllAccounts,
    getAccountById,
    updateAccount,
    validatePassword,
    forgotPassword,     // Thêm vào để xuất khẩu phương thức forgotPassword
    resetPassword,
    verifyCode
};