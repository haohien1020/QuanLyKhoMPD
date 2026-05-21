DROP DATABASE IF EXISTS SWP391_Generator_Management;

CREATE DATABASE SWP391_Generator_Management
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE SWP391_Generator_Management;

-- =========================
-- ROLES
-- =========================
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    status VARCHAR(20) DEFAULT 'ACTIVE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    avatar VARCHAR(255),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_users_roles
        FOREIGN KEY (role_id) REFERENCES roles(role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- PASSWORD RESET
-- =========================
CREATE TABLE password_reset_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    expired_at DATETIME NOT NULL,
    is_used TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_password_reset_users
        FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- WAREHOUSES
-- =========================
CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    manager_id INT,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_warehouses_manager
        FOREIGN KEY (manager_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- SUPPLIERS
-- =========================
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(255),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- GENERATORS
-- =========================
CREATE TABLE generators (
    generator_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    supplier_id INT NULL,

    generator_name VARCHAR(100) NOT NULL,
    serial_number VARCHAR(100) UNIQUE,
    brand VARCHAR(100),
    power_value VARCHAR(50),
    fuel_type VARCHAR(50),

    origin_type VARCHAR(30) DEFAULT 'SUPPLIER',
    import_date DATETIME,
    purchase_price DECIMAL(15,2),

    location VARCHAR(100),
    status VARCHAR(30) DEFAULT 'IN_STOCK',
    note TEXT,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_generators_warehouses
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_generators_suppliers
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- PARTS
-- =========================
CREATE TABLE parts (
    part_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    part_name VARCHAR(100) NOT NULL,
    part_code VARCHAR(50) UNIQUE,
    quantity INT DEFAULT 0,
    min_quantity INT DEFAULT 0,
    unit VARCHAR(20),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_parts_warehouses
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- INVENTORY TRANSACTIONS
-- =========================
CREATE TABLE inventory_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    supplier_id INT,
    created_by INT NOT NULL,

    transaction_type VARCHAR(20) NOT NULL,
    item_type VARCHAR(20) NOT NULL,

    generator_id INT,
    part_id INT,
    quantity INT DEFAULT 1,

    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    note TEXT,
    status VARCHAR(30) DEFAULT 'COMPLETED',

    CONSTRAINT fk_inventory_warehouses
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_inventory_suppliers
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),

    CONSTRAINT fk_inventory_created_by
        FOREIGN KEY (created_by) REFERENCES users(user_id),

    CONSTRAINT fk_inventory_generators
        FOREIGN KEY (generator_id) REFERENCES generators(generator_id),

    CONSTRAINT fk_inventory_parts
        FOREIGN KEY (part_id) REFERENCES parts(part_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- PART REQUESTS
-- =========================
CREATE TABLE part_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    part_id INT NOT NULL,
    requested_by INT NOT NULL,
    approved_by INT,
    quantity INT NOT NULL,
    reason TEXT,
    status VARCHAR(30) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    approved_at DATETIME,

    CONSTRAINT fk_part_requests_warehouses
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_part_requests_parts
        FOREIGN KEY (part_id) REFERENCES parts(part_id),

    CONSTRAINT fk_part_requests_requested_by
        FOREIGN KEY (requested_by) REFERENCES users(user_id),

    CONSTRAINT fk_part_requests_approved_by
        FOREIGN KEY (approved_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- PURCHASE REQUESTS
-- =========================
CREATE TABLE purchase_requests (
    purchase_request_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    requested_by INT NOT NULL,
    approved_by INT,
    reason TEXT,
    status VARCHAR(30) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    approved_at DATETIME,

    CONSTRAINT fk_purchase_requests_warehouses
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_purchase_requests_requested_by
        FOREIGN KEY (requested_by) REFERENCES users(user_id),

    CONSTRAINT fk_purchase_requests_approved_by
        FOREIGN KEY (approved_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE purchase_request_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_request_id INT NOT NULL,
    part_id INT,
    item_name VARCHAR(100),
    quantity INT NOT NULL,

    CONSTRAINT fk_purchase_request_details_requests
        FOREIGN KEY (purchase_request_id) REFERENCES purchase_requests(purchase_request_id),

    CONSTRAINT fk_purchase_request_details_parts
        FOREIGN KEY (part_id) REFERENCES parts(part_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- PURCHASE ORDERS
-- =========================
CREATE TABLE purchase_orders (
    purchase_order_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    created_by INT NOT NULL,
    status VARCHAR(30) DEFAULT 'PENDING',
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    note TEXT,

    CONSTRAINT fk_purchase_orders_suppliers
        FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),

    CONSTRAINT fk_purchase_orders_warehouses
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_purchase_orders_created_by
        FOREIGN KEY (created_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE purchase_order_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id INT NOT NULL,
    part_id INT,
    item_name VARCHAR(100),
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2),

    CONSTRAINT fk_purchase_order_details_orders
        FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(purchase_order_id),

    CONSTRAINT fk_purchase_order_details_parts
        FOREIGN KEY (part_id) REFERENCES parts(part_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- STOCK TRANSFERS
-- =========================
CREATE TABLE stock_transfers (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    from_warehouse_id INT NOT NULL,
    to_warehouse_id INT NOT NULL,
    created_by INT NOT NULL,
    approved_by INT,
    status VARCHAR(30) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    approved_at DATETIME,

    CONSTRAINT fk_stock_transfers_from_warehouse
        FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_stock_transfers_to_warehouse
        FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(warehouse_id),

    CONSTRAINT fk_stock_transfers_created_by
        FOREIGN KEY (created_by) REFERENCES users(user_id),

    CONSTRAINT fk_stock_transfers_approved_by
        FOREIGN KEY (approved_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE stock_transfer_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    transfer_id INT NOT NULL,
    item_type VARCHAR(20) NOT NULL,
    generator_id INT,
    part_id INT,
    quantity INT DEFAULT 1,

    CONSTRAINT fk_stock_transfer_details_transfers
        FOREIGN KEY (transfer_id) REFERENCES stock_transfers(transfer_id),

    CONSTRAINT fk_stock_transfer_details_generators
        FOREIGN KEY (generator_id) REFERENCES generators(generator_id),

    CONSTRAINT fk_stock_transfer_details_parts
        FOREIGN KEY (part_id) REFERENCES parts(part_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- MAINTENANCE / REPAIR
-- =========================
CREATE TABLE maintenance_repairs (
    repair_id INT AUTO_INCREMENT PRIMARY KEY,
    generator_id INT NOT NULL,
    reported_by INT NOT NULL,
    assigned_to INT,
    issue_description TEXT,
    repair_status VARCHAR(30) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,

    CONSTRAINT fk_maintenance_generators
        FOREIGN KEY (generator_id) REFERENCES generators(generator_id),

    CONSTRAINT fk_maintenance_reported_by
        FOREIGN KEY (reported_by) REFERENCES users(user_id),

    CONSTRAINT fk_maintenance_assigned_to
        FOREIGN KEY (assigned_to) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- NOTIFICATIONS
-- =========================
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50),
    is_read TINYINT(1) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notifications_users
        FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- REPORT EXPORTS
-- =========================
CREATE TABLE report_exports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    created_by INT NOT NULL,
    report_name VARCHAR(150) NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    file_type VARCHAR(20) NOT NULL,
    file_path VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_report_exports_created_by
        FOREIGN KEY (created_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- ACTIVITY LOGS
-- =========================
CREATE TABLE activity_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100),
    table_name VARCHAR(100),
    record_id INT,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_activity_logs_users
        FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- SEED DATA
-- =========================

INSERT INTO roles (role_name, description) VALUES
('ADMIN', 'System administrator'),
('MANAGER', 'Manage all warehouses and approval flow'),
('WAREHOUSE_MANAGER', 'Manage assigned warehouse'),
('STAFF', 'Warehouse staff');

INSERT INTO users (role_id, full_name, email, username, `password`, phone, address, status) VALUES
(1, 'System Admin', 'admin@gmail.com', 'admin', '123456', '0900000001', 'FPT University', 'ACTIVE'),
(2, 'Nguyen Van Manager', 'manager@gmail.com', 'manager', '123456', '0900000002', 'Ha Noi', 'ACTIVE'),
(3, 'Tran Thi Warehouse', 'warehouse.manager@gmail.com', 'warehousemanager', '123456', '0900000003', 'Ha Noi', 'ACTIVE'),
(4, 'Le Van Staff', 'staff@gmail.com', 'staff', '123456', '0900000004', 'Ha Noi', 'ACTIVE'),
(4, 'Pham Minh Staff', 'staff2@gmail.com', 'staff2', '123456', '0900000005', 'Da Nang', 'ACTIVE');

INSERT INTO warehouses (warehouse_name, address, manager_id, status) VALUES
('Main Warehouse', 'Ha Noi', 3, 'ACTIVE'),
('Da Nang Branch Warehouse', 'Da Nang', 3, 'ACTIVE'),
('Ho Chi Minh Branch Warehouse', 'Ho Chi Minh City', 3, 'ACTIVE');

INSERT INTO suppliers (supplier_name, phone, email, address, status) VALUES
('Cummins Vietnam', '0281111222', 'sales@cummins.vn', 'Ho Chi Minh City', 'ACTIVE'),
('Mitsubishi Power Supplier', '0243333444', 'contact@mitsubishi.vn', 'Ha Noi', 'ACTIVE'),
('Generator Parts Co', '0236555666', 'parts@generator.vn', 'Da Nang', 'ACTIVE');

INSERT INTO generators
(warehouse_id, supplier_id, generator_name, serial_number, brand, power_value, fuel_type, origin_type, import_date, purchase_price, location, status, note)
VALUES
(1, 1, 'Cummins Generator 100KVA', 'GEN-CUM-001', 'Cummins', '100KVA', 'Diesel', 'SUPPLIER', '2026-05-01 09:00:00', 180000000, 'A1-01', 'IN_STOCK', 'Imported from Cummins Vietnam'),
(1, 2, 'Mitsubishi Generator 150KVA', 'GEN-MIT-001', 'Mitsubishi', '150KVA', 'Diesel', 'SUPPLIER', '2026-05-03 10:00:00', 250000000, 'A1-02', 'IN_STOCK', 'Imported from Mitsubishi Power Supplier'),
(2, NULL, 'Denyo Generator 80KVA', 'GEN-DEN-001', 'Denyo', '80KVA', 'Diesel', 'TRANSFER', '2026-05-06 14:00:00', 120000000, 'B1-01', 'IN_STOCK', 'Transferred from Main Warehouse'),
(3, NULL, 'Honda Generator 30KVA', 'GEN-HON-001', 'Honda', '30KVA', 'Gasoline', 'TRANSFER', '2026-05-08 15:30:00', 45000000, 'C1-01', 'MAINTENANCE', 'Transferred from Main Warehouse'),
(1, 1, 'Cummins Generator 200KVA', 'GEN-CUM-002', 'Cummins', '200KVA', 'Diesel', 'SUPPLIER', '2026-05-10 08:30:00', 320000000, 'A2-01', 'UNDER_REPAIR', 'Imported from Cummins Vietnam');

INSERT INTO parts 
(warehouse_id, part_name, part_code, quantity, min_quantity, unit, status) VALUES
(1, 'Oil Filter', 'PART-OF-001', 20, 5, 'pcs', 'ACTIVE'),
(1, 'Fuel Filter', 'PART-FF-001', 15, 5, 'pcs', 'ACTIVE'),
(1, 'Battery 12V', 'PART-BT-001', 6, 3, 'pcs', 'ACTIVE'),
(2, 'Spark Plug', 'PART-SP-001', 4, 5, 'pcs', 'ACTIVE'),
(3, 'Engine Oil 5L', 'PART-EO-001', 10, 4, 'bottle', 'ACTIVE');

INSERT INTO inventory_transactions
(warehouse_id, supplier_id, created_by, transaction_type, item_type, generator_id, part_id, quantity, note, status) VALUES
(1, 1, 2, 'IMPORT', 'GENERATOR', 1, NULL, 1, 'Import Cummins generator from supplier', 'COMPLETED'),
(1, 2, 2, 'IMPORT', 'GENERATOR', 2, NULL, 1, 'Import Mitsubishi generator from supplier', 'COMPLETED'),
(1, 3, 3, 'IMPORT', 'PART', NULL, 1, 20, 'Import oil filters', 'COMPLETED'),
(1, NULL, 4, 'EXPORT', 'PART', NULL, 2, 3, 'Used fuel filters for maintenance', 'COMPLETED');

INSERT INTO part_requests
(warehouse_id, part_id, requested_by, approved_by, quantity, reason, status, approved_at) VALUES
(2, 4, 4, NULL, 10, 'Spark Plug quantity is lower than minimum stock', 'PENDING', NULL),
(3, 5, 5, 2, 5, 'Need engine oil for maintenance', 'APPROVED', CURRENT_TIMESTAMP);

INSERT INTO purchase_requests
(warehouse_id, requested_by, approved_by, reason, status, approved_at) VALUES
(2, 4, NULL, 'Need to buy more spark plugs for Da Nang warehouse', 'PENDING', NULL),
(1, 3, 2, 'Buy more batteries for main warehouse', 'APPROVED', CURRENT_TIMESTAMP);

INSERT INTO purchase_request_details
(purchase_request_id, part_id, item_name, quantity) VALUES
(1, 4, 'Spark Plug', 20),
(2, 3, 'Battery 12V', 10);

INSERT INTO purchase_orders
(supplier_id, warehouse_id, created_by, status, note) VALUES
(3, 1, 2, 'PENDING', 'Order parts for main warehouse'),
(2, 1, 2, 'COMPLETED', 'Order generator from Mitsubishi supplier');

INSERT INTO purchase_order_details
(purchase_order_id, part_id, item_name, quantity, unit_price) VALUES
(1, 3, 'Battery 12V', 10, 850000),
(2, NULL, 'Mitsubishi Generator 150KVA', 1, 250000000);

INSERT INTO stock_transfers
(from_warehouse_id, to_warehouse_id, created_by, approved_by, status, approved_at) VALUES
(1, 2, 3, NULL, 'PENDING', NULL),
(1, 3, 2, 2, 'APPROVED', CURRENT_TIMESTAMP);

INSERT INTO stock_transfer_details
(transfer_id, item_type, generator_id, part_id, quantity) VALUES
(1, 'PART', NULL, 1, 5),
(2, 'GENERATOR', 2, NULL, 1);

INSERT INTO maintenance_repairs
(generator_id, reported_by, assigned_to, issue_description, repair_status, completed_at) VALUES
(5, 4, 4, 'Generator has abnormal engine noise', 'IN_PROGRESS', NULL),
(4, 5, 5, 'Scheduled maintenance for Honda generator', 'PENDING', NULL);