require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fileUpload = require('express-fileupload');
const path = require('path');

const sequelize = require('./config/database');
const passport = require('./config/passport');
const logger = require('./middleware/logger');
const { seedDefaultCategories } = require('./services/categoryService');

// Route imports
const authRoutes = require('./routes/auth');
const expenseRoutes = require('./routes/expenses');
const categoryRoutes = require('./routes/categories');
const budgetRoutes = require('./routes/budgets');
const userRoutes = require('./routes/users');

const app = express();
const PORT = process.env.PORT || 5000;

// ── Middleware ────────────────────────────────────────
app.use(cors({ origin: process.env.FRONTEND_URL || 'http://localhost:5173', credentials: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(fileUpload({ limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024 } }));
app.use(passport.initialize());
app.use(logger);

// Static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ── API Routes ────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/expenses', expenseRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/budgets', budgetRoutes);
app.use('/api/users', userRoutes);

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ message: `Route ${req.originalUrl} not found` });
});

// ── Database & Server Start ────────────────────────────
const start = async() => {
    try {
        await sequelize.authenticate();
        console.log('Database connected');

        await seedDefaultCategories();
        console.log(' Default categories seeded');

        app.listen(PORT, () => {
            console.log(` Server running on http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error(' Failed to start server:', error.message);
        process.exit(1);
    }
};

start();