# Smart Task Manager – Backend API

Smart Task Manager is a RESTful backend API built using **Node.js** and **Express.js**.  
It powers a task management application with **automatic task classification**, **priority detection**, **pagination**, and **dashboard-friendly task statistics**.  
The backend is designed to work seamlessly with Flutter or web frontends.

---

## 🚀 Key Features

- Full CRUD operations for tasks
- Automatic task **category** and **priority** detection
- Task status tracking (Pending, In Progress, Completed)
- Pagination for optimized data fetching
- Status-wise and category-wise task counts and search
- Input validation and centralized error handling
- Swagger-based API documentation
- Supabase integration as the database layer

---

## 🛠 Technology Stack

- **Node.js**
- **Express.js**
- **Supabase**
- **Swagger UI**
- **dotenv**
- **CORS**

---

## ⚙️ Setup Instructions – Run Locally

### 🔹 Backend Setup

````bash
# Clone repository
git clone <repository-url>

# Navigate to backend
cd backend

# Install dependencies
npm install

# Create .env file
PORT=5000
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Start server
npm run dev
Backend will run at:

arduino
Copy code
http://localhost:5000

---

## 📁 Project Structure

```text
backend/
│── src/
│   ├── app.js                     # Express app configuration
│   ├── server.js                  # Server entry point
│
│   ├── config/
│   │   └── supabase.js            # Supabase client setup
│
│   ├── controllers/
│   │   └── task.controller.js     # API controllers
│
│   ├── routes/
│   │   └── task.routes.js         # API routes
│
│   ├── services/
│   │   └── task.service.js        # Business logic
│
│   ├── middlewares/
│   │   ├── error.middleware.js    # Global error handler
│   │   └── validate.middleware.js # Request validation
│
│   ├── validations/
│   │   └── task.validation.js     # Task validation schemas
│
│   ├── utils/
│   │   └── classifier.js          # Auto classification logic
│
│   └── testClassifier.js          # Classifier testing utility
│
│── .env
│── package.json
│── README.md
````

---

## 🔗 API Endpoints

### Base URL

```
http://localhost:5000
```

### Task APIs

| Method | Endpoint         | Description                           |
| ------ | ---------------- | ------------------------------------- |
| GET    | `/api/tasks`     | Fetch tasks with pagination & filters |
| POST   | `/api/tasks`     | Create a new task                     |
| PATCH  | `/api/tasks/:id` | Update task                           |
| DELETE | `/api/tasks/:id` | Delete task                           |

---

## 📌 Query Parameters (GET /api/tasks)

- `page` – Page number
- `limit` – Number of tasks per page
- `status` – Filter by task status
- `category` – Filter by category
- `priority` – Filter by priority

---

## 🧠 Automatic Task Classification

When a task is created:

- The system analyzes the **title** and **description**
- Automatically assigns:

  - **Category** (Scheduling, Finance, Technical, Safety, General)
  - **Priority** (High, Medium, Low)

- Classification is keyword-based and can be overridden by the user

---

## 📊 Pagination & Dashboard Counts

- Guest requests are limited to improve performance
- Total task count and status-wise counts are calculated independently
- This ensures accurate dashboard data without extra API endpoints

---

## 📘 Swagger API Documentation

Swagger UI is available at:

```
http://localhost:5000/api-docs
```

You can:

- Explore all APIs
- View request/response schemas
- Test endpoints directly from the browser

---

## ⚙️ Installation & Setup

```bash
# Clone the repository
git clone <repository-url>

# Move to backend directory
cd backend

# Install dependencies
npm install

# Create .env file
PORT=5000
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Start the development server
npm run dev
```

Server will start at:

```
http://localhost:5000
```

---

## 🧪 Testing

- Use **Postman** or **Swagger UI**
- Validate pagination, filters, and auto classification
- `testClassifier.js` can be used to test keyword detection logic

---

## 🔮 Future Enhancements

- Authentication & role-based access
- Rate limiting for guest users
- Caching for task counts
- Unit and integration testing
- Activity logs and audit trail

---

## 👤 Author

Developed by **kanchan**
MCA Student | Backend & Full-Stack Developer

---
