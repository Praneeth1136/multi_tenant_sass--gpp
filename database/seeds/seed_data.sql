-- =========================
-- SEED DATA (Idempotent)
-- =========================

-- 1️⃣ SUPER ADMIN (NO TENANT)
INSERT INTO users (
    id, tenant_id, email, password_hash, full_name, role, is_active
)
SELECT uuid_generate_v4(), NULL, 'superadmin@system.com', '$2b$10$79U2uYNPwqHhY35ocJiK0O0/WOWfB4E0mz/58pLlcD1f/hmqlc86y', 'System Super Admin', 'super_admin', true
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE email = 'superadmin@system.com' AND tenant_id IS NULL
);

-- 2️⃣ DEMO TENANT
INSERT INTO tenants (
    id, name, subdomain, status, subscription_plan, max_users, max_projects
)
SELECT uuid_generate_v4(), 'Demo Company', 'demo', 'active', 'pro', 25, 15
WHERE NOT EXISTS (
    SELECT 1 FROM tenants WHERE subdomain = 'demo'
);

-- 3️⃣ TENANT ADMIN
-- We need to fetch the Correct tenant_id.
DO $$
DECLARE
    v_tenant_id UUID;
    v_admin_user_id UUID;
    v_user1_id UUID;
    v_user2_id UUID;
    v_project_alpha_id UUID;
    v_project_beta_id UUID;
BEGIN
    SELECT id INTO v_tenant_id FROM tenants WHERE subdomain = 'demo';

    -- Insert Tenant Admin if not exists
    INSERT INTO users (id, tenant_id, email, password_hash, full_name, role, is_active)
    SELECT uuid_generate_v4(), v_tenant_id, 'admin@demo.com', '$2b$10$GbR52VrRXMBuu.Qiq5d.MuSj6Fhx0j54fEbXAUxLoCmBlhVLIoMHy', 'Demo Tenant Admin', 'tenant_admin', true
    WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@demo.com' AND tenant_id = v_tenant_id)
    RETURNING id INTO v_admin_user_id;

    -- If not inserted (already existed), fetch ID
    IF v_admin_user_id IS NULL THEN
        SELECT id INTO v_admin_user_id FROM users WHERE email = 'admin@demo.com' AND tenant_id = v_tenant_id;
    END IF;

    -- 4️⃣ REGULAR USERS
    -- User 1
    INSERT INTO users (id, tenant_id, email, password_hash, full_name, role, is_active)
    SELECT uuid_generate_v4(), v_tenant_id, 'user1@demo.com', '$2b$10$hPTv4eJyPvQ3y9sjjDZaoe1TyHHit87L2jVTjg0NfgZG8055Rmxd.', 'Demo User One', 'user', true
    WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'user1@demo.com' AND tenant_id = v_tenant_id)
    RETURNING id INTO v_user1_id;

    IF v_user1_id IS NULL THEN
         SELECT id INTO v_user1_id FROM users WHERE email = 'user1@demo.com' AND tenant_id = v_tenant_id;
    END IF;

    -- User 2
    INSERT INTO users (id, tenant_id, email, password_hash, full_name, role, is_active)
    SELECT uuid_generate_v4(), v_tenant_id, 'user2@demo.com', '$2b$10$hPTv4eJyPvQ3y9sjjDZaoe1TyHHit87L2jVTjg0NfgZG8055Rmxd.', 'Demo User Two', 'user', true
    WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'user2@demo.com' AND tenant_id = v_tenant_id)
    RETURNING id INTO v_user2_id;

    IF v_user2_id IS NULL THEN
         SELECT id INTO v_user2_id FROM users WHERE email = 'user2@demo.com' AND tenant_id = v_tenant_id;
    END IF;

    -- 5️⃣ PROJECTS
    -- Project Alpha
    INSERT INTO projects (id, tenant_id, name, description, status, created_by)
    SELECT uuid_generate_v4(), v_tenant_id, 'Project Alpha', 'First demo project', 'active', v_admin_user_id
    WHERE NOT EXISTS (SELECT 1 FROM projects WHERE name = 'Project Alpha' AND tenant_id = v_tenant_id)
    RETURNING id INTO v_project_alpha_id;
    
    IF v_project_alpha_id IS NULL THEN
         SELECT id INTO v_project_alpha_id FROM projects WHERE name = 'Project Alpha' AND tenant_id = v_tenant_id;
    END IF;

    -- Project Beta
    INSERT INTO projects (id, tenant_id, name, description, status, created_by)
    SELECT uuid_generate_v4(), v_tenant_id, 'Project Beta', 'Second demo project', 'active', v_admin_user_id
    WHERE NOT EXISTS (SELECT 1 FROM projects WHERE name = 'Project Beta' AND tenant_id = v_tenant_id)
    RETURNING id INTO v_project_beta_id;

    IF v_project_beta_id IS NULL THEN
         SELECT id INTO v_project_beta_id FROM projects WHERE name = 'Project Beta' AND tenant_id = v_tenant_id;
    END IF;

    -- 6️⃣ TASKS
    -- Task 1
    INSERT INTO tasks (id, project_id, tenant_id, title, description, status, priority, assigned_to)
    SELECT uuid_generate_v4(), v_project_alpha_id, v_tenant_id, 'Setup project structure', 'Initial setup task', 'todo', 'high', v_user1_id
    WHERE NOT EXISTS (SELECT 1 FROM tasks WHERE title = 'Setup project structure' AND project_id = v_project_alpha_id);

    -- Task 2
    INSERT INTO tasks (id, project_id, tenant_id, title, description, status, priority, assigned_to)
    SELECT uuid_generate_v4(), v_project_beta_id, v_tenant_id, 'Design database schema', 'Create ERD and tables', 'in_progress', 'medium', v_user2_id
    WHERE NOT EXISTS (SELECT 1 FROM tasks WHERE title = 'Design database schema' AND project_id = v_project_beta_id);

END $$;
