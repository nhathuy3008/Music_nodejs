require('dotenv').config(); // Nạp biến môi trường từ tệp .env
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); // Thêm gói cors
const accountRoutes = require('./routes/accountRoutes');
const cloudinary = require('./cloudinary');
const categoryRoutes = require("./routes/categoryRoutes");
const songRoutes = require("./routes/songRoutes");
const favoriteRoutes = require('./routes/favoriteRoutes');
const commentRoutes = require('./routes/commentsRoutes')
const playlistRoutes = require('./routes/playlistRoutes')
const multer = require('multer');



const app = express();
const PORT = process.env.PORT || 3000; // Lấy cổng từ biến môi trường hoặc mặc định là 3000

// Cấu hình CORS
const corsOptions = {
    origin: ['http://localhost:3000', 'http://localhost:5173','http://127.0.0.1:5500'], // Địa chỉ frontend
    methods: ['GET', 'POST', 'PUT', 'DELETE'], // Các phương thức HTTP được phép
    allowedHeaders: ['Content-Type'], // Các header được phép
    credentials: true, // Cho phép cookie và thông tin xác thực
};

app.use(cors(corsOptions)); // Thêm middleware CORS với cấu hình
app.use(express.json()); // Middleware để phân tích cú pháp JSON

// Định tuyến API
app.use('/api/accounts', accountRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api', songRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/comments', commentRoutes);
app.use('/api/playlists', playlistRoutes);
// Kết nối đến MongoDB
mongoose.connect('mongodb://localhost:27017/music', { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => {
        console.log('Kết nối MongoDB thành công');
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error('Kết nối MongoDB thất bại', err);
    });