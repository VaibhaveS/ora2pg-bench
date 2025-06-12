-- Large schema with complex relationships, partitioning, and advanced features
CREATE TABLE departments (
    department_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(100),
    location VARCHAR2(200),
    manager_id NUMBER(10)
);

CREATE TABLE employees (
    employee_id NUMBER(10) PRIMARY KEY,
    department_id NUMBER(10),
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(255),
    phone VARCHAR2(20),
    hire_date DATE,
    salary NUMBER(10,2),
    commission_pct NUMBER(4,2),
    manager_id NUMBER(10),
    CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Add manager_id foreign key to departments after employees table is created
ALTER TABLE departments ADD CONSTRAINT fk_dept_manager 
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

CREATE TABLE categories (
    category_id NUMBER(10) PRIMARY KEY,
    parent_category_id NUMBER(10),
    name VARCHAR2(100),
    description VARCHAR2(500),
    created_date DATE,
    modified_date DATE,
    CONSTRAINT fk_parent_category FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE suppliers (
    supplier_id NUMBER(10) PRIMARY KEY,
    company_name VARCHAR2(200),
    contact_name VARCHAR2(100),
    email VARCHAR2(255),
    phone VARCHAR2(20),
    address CLOB,
    created_date DATE,
    status VARCHAR2(20)
);

-- Partitioned table example
CREATE TABLE products (
    product_id NUMBER(10) PRIMARY KEY,
    category_id NUMBER(10),
    supplier_id NUMBER(10),
    name VARCHAR2(200),
    description CLOB,
    price NUMBER(10,2),
    stock_quantity NUMBER(10),
    min_stock_level NUMBER(10),
    max_stock_level NUMBER(10),
    created_date DATE,
    modified_date DATE,
    status VARCHAR2(20),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
)
PARTITION BY RANGE (created_date) (
    PARTITION products_2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION products_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD')),
    PARTITION products_future VALUES LESS THAN (MAXVALUE)
);

CREATE TABLE customers (
    customer_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(255),
    phone VARCHAR2(20),
    address CLOB,
    created_date DATE,
    modified_date DATE,
    status VARCHAR2(20),
    credit_limit NUMBER(10,2),
    credit_score NUMBER(5,2)
);

CREATE TABLE orders (
    order_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10),
    employee_id NUMBER(10),
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    shipping_address CLOB,
    total_amount NUMBER(10,2),
    status VARCHAR2(20),
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_order_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
)
PARTITION BY RANGE (order_date) (
    PARTITION orders_2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION orders_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD')),
    PARTITION orders_future VALUES LESS THAN (MAXVALUE)
);

CREATE TABLE order_items (
    order_item_id NUMBER(10) PRIMARY KEY,
    order_id NUMBER(10),
    product_id NUMBER(10),
    quantity NUMBER(5),
    unit_price NUMBER(10,2),
    discount NUMBER(4,2),
    CONSTRAINT fk_orderitem_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_orderitem_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE inventory_transactions (
    transaction_id NUMBER(10) PRIMARY KEY,
    product_id NUMBER(10),
    transaction_type VARCHAR2(20),
    quantity NUMBER(10),
    transaction_date DATE,
    order_id NUMBER(10),
    notes CLOB,
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_inventory_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Create materialized view for sales analysis
CREATE MATERIALIZED VIEW sales_analysis
BUILD IMMEDIATE
REFRESH ON COMMIT AS
SELECT 
    p.category_id,
    c.name as category_name,
    p.product_id,
    p.name as product_name,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    AVG(oi.unit_price) as avg_unit_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'COMPLETED'
GROUP BY p.category_id, c.name, p.product_id, p.name;

-- Create complex views
CREATE VIEW employee_hierarchy AS
WITH RECURSIVE emp_hierarchy AS (
    -- Base case: employees with no manager (top level)
    SELECT 
        employee_id, 
        first_name,
        last_name,
        manager_id,
        1 as level,
        CAST(employee_id AS VARCHAR2(1000)) as path
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    -- Recursive case: employees with managers
    SELECT 
        e.employee_id,
        e.first_name,
        e.last_name,
        e.manager_id,
        h.level + 1,
        h.path || ',' || e.employee_id
    FROM employees e
    JOIN emp_hierarchy h ON e.manager_id = h.employee_id
)
SELECT * FROM emp_hierarchy;

CREATE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    MIN(o.order_date) as first_order_date,
    MAX(o.order_date) as last_order_date,
    COUNT(DISTINCT p.category_id) as categories_purchased
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Add indexes
CREATE INDEX idx_emp_department ON employees(department_id);
CREATE INDEX idx_emp_manager ON employees(manager_id);
CREATE INDEX idx_product_category ON products(category_id);
CREATE INDEX idx_product_supplier ON products(supplier_id);
CREATE INDEX idx_product_status ON products(status);
CREATE INDEX idx_customer_email ON customers(email);
CREATE INDEX idx_customer_status ON customers(status);
CREATE INDEX idx_order_customer ON orders(customer_id);
CREATE INDEX idx_order_employee ON orders(employee_id);
CREATE INDEX idx_order_date ON orders(order_date);
CREATE INDEX idx_order_status ON orders(status);
CREATE INDEX idx_orderitems_order ON order_items(order_id);
CREATE INDEX idx_orderitems_product ON order_items(product_id);
CREATE INDEX idx_inventory_product ON inventory_transactions(product_id);
CREATE INDEX idx_inventory_date ON inventory_transactions(transaction_date);

-- Add some function-based indexes
CREATE INDEX idx_customer_fullname ON customers(UPPER(first_name || ' ' || last_name));
CREATE INDEX idx_product_price_category ON products(category_id, ROUND(price, 2));
