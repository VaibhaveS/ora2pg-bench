-- Medium schema with more tables and relationships
CREATE TABLE categories (
    category_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(100),
    description VARCHAR2(500)
);

CREATE TABLE products (
    product_id NUMBER(10) PRIMARY KEY,
    category_id NUMBER(10),
    name VARCHAR2(200),
    description CLOB,
    price NUMBER(10,2),
    stock_quantity NUMBER(10),
    created_date DATE,
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE customers (
    customer_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(255),
    phone VARCHAR2(20),
    address CLOB,
    created_date DATE
);

CREATE TABLE orders (
    order_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10),
    order_date DATE,
    shipping_address CLOB,
    total_amount NUMBER(10,2),
    status VARCHAR2(20),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id NUMBER(10) PRIMARY KEY,
    order_id NUMBER(10),
    product_id NUMBER(10),
    quantity NUMBER(5),
    unit_price NUMBER(10,2),
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Create some views
CREATE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Add some indexes
CREATE INDEX idx_product_category ON products(category_id);
CREATE INDEX idx_customer_email ON customers(email);
CREATE INDEX idx_order_customer ON orders(customer_id);
CREATE INDEX idx_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
