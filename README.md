# 💰 Expense Tracker App

A full-stack expense tracking application with a Node.js/Express backend and React + Vite frontend.

---

## 📁 Project Structure

```
expense_tracker_app/
├── backend/
│   ├── config/
│   │   ├── database.js         # Sequelize MySQL config
│   │   └── passport.js         # Local + Google OAuth + JWT strategies
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── expenseController.js
│   │   ├── categoryController.js
│   │   ├── budgetController.js
│   │   └── userController.js
│   ├── middleware/
│   │   ├── auth.js             # JWT authenticate middleware
│   │   └── logger.js           # Request logger
│   ├── models/
│   │   ├── index.js            # Associations
│   │   ├── User.js
│   │   ├── Expense.js
│   │   ├── Category.js
│   │   └── Budget.js
│   ├── pagination/
│   │   └── index.js            # Standalone pagination module
│   ├── routes/
│   │   ├── auth.js
│   │   ├── expenses.js
│   │   ├── categories.js
│   │   ├── budgets.js
│   │   └── users.js
│   ├── services/
│   │   ├── authService.js
│   │   ├── expenseService.js
│   │   ├── categoryService.js
│   │   ├── budgetService.js
│   │   └── userService.js
│   ├── utils/
│   │   ├── jwt.js              # Token generation/verification
│   │   ├── hashing.js          # bcryptjs password utilities
│   │   ├── fileUpload.js       # File upload handler
│   │   └── reports/
│   │       ├── pdfReport.js    # PDFKit PDF generation
│   │       └── excelReport.js  # xlsx Excel generation
│   ├── validation/
│   │   ├── rules.js            # express-validator rules
│   │   └── handler.js          # Validation error handler
│   ├── uploads/                # Uploaded files (auto-created)
│   ├── reports/                # Generated reports (auto-created)
│   ├── .env.example
│   ├── package.json
│   └── server.js
│
└── frontend/
    ├── src/
    │   ├── api/
    │   │   └── index.js        # Fetch API wrappers
    │   ├── components/
    │   │   ├── layout/
    │   │   │   └── AppLayout.jsx
    │   │   ├── ui/
    │   │   │   ├── Modal.jsx
    │   │   │   ├── Toast.jsx
    │   │   │   ├── StatCard.jsx
    │   │   │   ├── Loader.jsx
    │   │   │   └── Pagination.jsx
    │   │   ├── dashboard/
    │   │   │   ├── Dashboard.jsx
    │   │   │   ├── Reports.jsx
    │   │   │   └── Profile.jsx
    │   │   ├── expenses/
    │   │   │   ├── Expenses.jsx
    │   │   │   └── ExpenseForm.jsx
    │   │   ├── budgets/
    │   │   │   └── Budgets.jsx
    │   │   └── categories/
    │   │       └── Categories.jsx
    │   ├── context/
    │   │   └── AuthContext.jsx
    │   ├── hooks/
    │   │   └── index.js
    │   ├── pages/
    │   │   ├── Login.jsx
    │   │   ├── Register.jsx
    │   │   ├── AuthCallback.jsx
    │   │   └── ProtectedRoute.jsx
    │   ├── utils/
    │   │   └── index.js
    │   ├── App.jsx
    │   ├── main.jsx
    │   └── index.css
    ├── index.html
    ├── vite.config.js
    ├── tailwind.config.js
    └── postcss.config.js
```

---

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- MySQL 8+

### Backend Setup

```bash
cd expense_tracker_app/backend
npm install
cp .env.example .env
# Edit .env with your database credentials and secrets
npm run dev
```

### Frontend Setup

```bash
cd expense_tracker_app/frontend
npm install
npm run dev
```

---

## ⚙️ Environment Variables (backend/.env)

```env
PORT=5000
DB_HOST=localhost
DB_PORT=3306
DB_NAME=expense_tracker
DB_USER=root
DB_PASSWORD=yourpassword
JWT_SECRET=your_very_secret_key
JWT_EXPIRES_IN=7d
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_secret
GOOGLE_CALLBACK_URL=http://localhost:5000/api/auth/google/callback
FRONTEND_URL=http://localhost:5173
```

---

## 📡 API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register |
| POST | `/api/auth/login` | Login |
| GET | `/api/auth/me` | Current user |
| GET | `/api/auth/google` | Google OAuth start |
| GET | `/api/auth/google/callback` | Google OAuth callback |

### Expenses
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/expenses` | List (paginated, filterable) |
| GET | `/api/expenses/:id` | Get one |
| POST | `/api/expenses` | Create (supports file upload) |
| PUT | `/api/expenses/:id` | Update |
| DELETE | `/api/expenses/:id` | Delete |
| GET | `/api/expenses/summary` | Analytics summary |
| GET | `/api/expenses/export?format=pdf\|excel` | Export report |

### Budgets, Categories, Users
- Standard CRUD endpoints on `/api/budgets`, `/api/categories`, `/api/users`

---

## ✨ Features

- **Authentication**: JWT + Passport local + Google OAuth 2.0
- **Expenses**: Full CRUD with file receipt uploads, filtering, search, pagination
- **Budgets**: Spending limits with progress tracking
- **Categories**: Custom + default categories with icons & colors
- **Reports**: PDF (PDFKit) and Excel (xlsx) export
- **Dashboard**: Interactive charts (Recharts) — area, pie, bar
- **Pagination**: Standalone module separate from routes/controllers
- **Validation**: express-validator with clean handler
- **UI**: React + Vite + TailwindCSS v3, Fetch API (no axios)
