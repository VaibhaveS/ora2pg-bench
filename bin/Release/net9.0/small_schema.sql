-- Small schema with basic tables
CREATE TABLE customers (
    customer_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(255),
    created_date DATE
);

CREATE TABLE orders (
    order_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10),
    order_date DATE,
    total_amount NUMBER(10,2),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Add some indexes
CREATE INDEX idx_customer_email ON customers(email);
CREATE INDEX idx_order_date ON orders(order_date);
