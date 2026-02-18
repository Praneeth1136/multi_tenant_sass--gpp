# Technical Specification

## Project Structure

The project is organized as a monorepo containing both the backend API and the frontend application.

```
/
├── backend/                # Node.js/Express Backend
│   ├── src/
│   │   ├── config/         # Configuration files (DB, etc.)
│   │   ├── controllers/    # Route controllers (logic)
│   │   ├── middleware/     # Custom middleware (Auth, Error handling)
│   │   ├── models/         # Database models (if using ORM) or SQL queries
│   │   ├── routes/         # API Route definitions
│   │   ├── utils/          # Utility functions
│   │   ├── app.js          # Express app setup
│   │   └── server.js       # Server entry point
│   ├── migrations/         # Database migration scripts
│   ├── seeds/              # Database seed data
│   ├── Dockerfile          # Docker build instructions for backend
│   └── package.json        # Backend dependencies
├── frontend/               # React Frontend
│   ├── public/             # Static assets
│   ├── src/
│   │   ├── api/            # API client services
│   │   ├── components/     # Reusable UI components
│   │   ├── context/        # React Context (Auth, Theme)
│   │   ├── pages/          # Page components (routed)
│   │   ├── App.jsx         # Main App component
│   │   └── main.jsx        # Entry point
│   ├── Dockerfile          # Docker build instructions for frontend
│   └── package.json        # Frontend dependencies
├── database/               # Database initialization scripts (docker-entrypoint-initdb.d)
│   ├── migrations/         # SQL migration files
│   └── seeds/              # SQL seed files
├── docs/                   # Documentation
│   ├── research.md         # Architecture research
│   ├── PRD.md              # Product Requirements Document
│   ├── architecture.md     # System Architecture & ERD
│   └── API.md              # API Documentation
├── docker-compose.yml      # Docker orchestration configuration
└── README.md               # Project overview and setup guide
```

## Development Setup Guide

### Prerequisites
- **Docker Desktop**: Must be installed and running.
- **Node.js**: v18+ (Optional, only for local non-Docker development).
- **Git**: For version control.

### Environment Variables
Environment variables are managed via `.env` files or directly in `docker-compose.yml`.
The key variables are:
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`: Database connection details.
- `JWT_SECRET`: Secret key for signing JWTs.
- `FRONTEND_URL`: URL of the frontend application (for CORS).
- `PORT`: Backend server port (default 5000).

### Instructions (Docker - Recommended)
1.  **Build and Start**:
    ```bash
    docker-compose up -d --build
    ```
    This command builds the images and starts the containers in detached mode.
    - Database: localhost:5432
    - Backend: localhost:5000
    - Frontend: localhost:3000

2.  **Verify Status**:
    ```bash
    docker-compose ps
    ```
    Ensure all services (`database`, `backend`, `frontend`) are up and healthy.
    - Backend Health Check: `curl http://localhost:5000/api/health`

3.  **Stop Services**:
    ```bash
    docker-compose down
    ```

### Instructions (Local - Non-Docker)
1.  **Database**: Start a PostgreSQL instance locally.
2.  **Backend**:
    ```bash
    cd backend
    npm install
    cp .env.example .env # Configure your .env
    npm run dev
    ```
3.  **Frontend**:
    ```bash
    cd frontend
    npm install
    npm run dev
    ```
