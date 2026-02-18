# Research Document: Multi-Tenancy Architecture & Technology Stack

## Multi-Tenancy Architecture Analysis

### Approaches to Multi-Tenancy

There are three primary approaches to architecting a multi-tenant application:

1.  **Shared Database, Shared Schema (Row-Level Isolation)**
    *   **Description**: All tenants share the same database and tables. A `tenant_id` column is added to every table to associate records with a specific tenant.
    *   **Pros**:
        *   Lowest infrastructure cost (single DB instance).
        *   Easiest to maintain and migrate (schema changes apply to all).
        *   Simplified backup/restore for the entire system.
    *   **Cons**:
        *   Strict developer discipline required to ensure `tenant_id` filter is always applied (risk of data leak).
        *   Harder to backup/restore individual tenants.
        *   Performance can degrade as table sizes grow.

2.  **Shared Database, Separate Schemas**
    *   **Description**: All tenants share the same database instance, but each tenant gets their own schema (e.g., `tenant_a.users`, `tenant_b.users`).
    *   **Pros**:
        *   Better isolation than shared schema.
        *   Easier to backup/restore individual tenants.
    *   **Cons**:
        *   Migration complexity increases (must run migrations per schema).
        *   Higher connection overhead.

3.  **Separate Database per Tenant**
    *   **Description**: Each tenant has their own database instance.
    *   **Pros**:
        *   Highest level of isolation (physically separate).
        *   Can scale resources per tenant.
    *   **Cons**:
        *   Most expensive infrastructure.
        *   Complex deployment and management.

### Chosen Approach: Shared Database, Shared Schema

We have chosen the **Shared Database, Shared Schema** approach for this project due to its simplicity and cost-effectiveness for a SaaS startup MVP. The primary risk (data leakage) is mitigated by using robust middleware and query encapsulation to enforce `tenant_id` filtering at the application level.

## Technology Stack Justification

### Backend: Node.js with Express
*   **Why**: Node.js offers high performance for I/O-bound applications (like APIs). Its non-blocking architecture handles concurrent requests efficiently. Setup is minimal, and the ecosystem (Express, npm) is vast.
*   **Alternatives**: Python/Django (too heavy), Go (steeper learning curve).

### Frontend: React with Vite
*   **Why**: React is the industry standard for building dynamic UIs. Vite provides a fast development experience with instant HMR. The component-based architecture suits the dashboard and project management UI perfectly.
*   **Alternatives**: Vue.js, Angular.

### Database: PostgreSQL
*   **Why**: PostgreSQL is a robust, open-source relational database that handles complex queries and transactions (ACID compliance) required for financial/SaaS data. It supports JSONB for flexible data needs if required.
*   **Alternatives**: MySQL (less strict), MongoDB (NoSQL, not ideal for structured relational data).

### Authentication: JWT (JSON Web Tokens)
*   **Why**: JWTs are stateless, meaning the server doesn't need to store session data, aiding scalability. They carry user identity and role information securely.
*   **Alternatives**: Session-based auth (requires server state/Redis).

### Deployment: Docker & Docker Compose
*   **Why**: Containerization ensures consistency across development, testing, and production environments. Docker Compose simplifies orchestrating the multi-container setup (DB + Backend + Frontend).

## Security Considerations

1.  **Data Isolation**: Strict `tenant_id` enforcement in all database queries. Middleware will strip `tenant_id` from incoming requests to prevent spoofing.
2.  **Authentication & Authorization**:
    *   **JWT**: Used for stateless auth. Tokens expire in 24 hours.
    *   **RBAC**: Role-Based Access Control (Super Admin, Tenant Admin, User) enforces permission levels.
3.  **Input Validation**: All API inputs are validated to prevent injection attacks and ensure data integrity.
4.  **Password Security**: Passwords are hashed using `bcrypt` (salt rounds >= 10) before storage. Plain text passwords are never stored.
5.  **Secure Headers**: Use of Helmet (or similar) to set secure HTTP headers (HSTS, X-Frame-Options).
6.  **Environment Variables**: Sensitive configuration (DB creds, JWT secrets) are stored in environment variables, not hardcoded.
