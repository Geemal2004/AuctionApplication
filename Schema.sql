
CREATE DATABASE auction_db;

psql -U postgres -d auction_db

-- =========================================
-- USERS
-- =========================================
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role VARCHAR(30) NOT NULL, -- ADMIN, SELLER, BIDDER, INSPECTOR
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- PRODUCTS
-- =========================================
CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    seller_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    status VARCHAR(30) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    rejection_reason TEXT,
    reviewed_by BIGINT,
    reviewed_at TIMESTAMP,
    handling_fee_paid BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_seller FOREIGN KEY (seller_id) REFERENCES users(id),
    CONSTRAINT fk_product_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id)
);

-- =========================================
-- PRODUCT DOCUMENTS
-- =========================================
CREATE TABLE product_documents (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    document_url TEXT NOT NULL,
    document_type VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_document_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- =========================================
-- PRODUCT IMAGES
-- =========================================
CREATE TABLE product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    image_url TEXT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_image_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- =========================================
-- INSPECTIONS
-- =========================================
CREATE TABLE inspections (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    inspector_id BIGINT NOT NULL,
    inspection_type VARCHAR(50), -- ON_SITE, VISIT
    inspection_fee NUMERIC(10,2),
    status VARCHAR(30), -- APPROVED, REJECTED
    remarks TEXT,
    inspected_at TIMESTAMP,
    CONSTRAINT fk_inspection_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_inspection_inspector FOREIGN KEY (inspector_id) REFERENCES users(id)
);

-- =========================================
-- AUCTIONS
-- =========================================
CREATE TABLE auctions (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT UNIQUE NOT NULL,
    start_price NUMERIC(10,2) NOT NULL,
    current_price NUMERIC(10,2),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(30) DEFAULT 'SCHEDULED', -- SCHEDULED, LIVE, ENDED
    winner_id BIGINT,
    CONSTRAINT fk_auction_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_auction_winner FOREIGN KEY (winner_id) REFERENCES users(id)
);

-- =========================================
-- BIDS (MANUAL)
-- =========================================
CREATE TABLE bids (
    id BIGSERIAL PRIMARY KEY,
    auction_id BIGINT NOT NULL,
    bidder_id BIGINT NOT NULL,
    bid_amount NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bid_auction FOREIGN KEY (auction_id) REFERENCES auctions(id),
    CONSTRAINT fk_bid_user FOREIGN KEY (bidder_id) REFERENCES users(id)
);

-- =========================================
-- PROXY BIDS
-- =========================================
CREATE TABLE proxy_bids (
    id BIGSERIAL PRIMARY KEY,
    auction_id BIGINT NOT NULL,
    bidder_id BIGINT NOT NULL,
    max_amount NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_proxy_auction FOREIGN KEY (auction_id) REFERENCES auctions(id),
    CONSTRAINT fk_proxy_user FOREIGN KEY (bidder_id) REFERENCES users(id),
    CONSTRAINT unique_proxy_bid UNIQUE (auction_id, bidder_id)
);

-- =========================================
-- PAYMENTS
-- =========================================
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    auction_id BIGINT NOT NULL,
    bidder_id BIGINT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    stripe_payment_id TEXT,
    status VARCHAR(30), -- PENDING, SUCCESS, FAILED
    paid_at TIMESTAMP,
    CONSTRAINT fk_payment_auction FOREIGN KEY (auction_id) REFERENCES auctions(id),
    CONSTRAINT fk_payment_user FOREIGN KEY (bidder_id) REFERENCES users(id)
);

-- =========================================
-- DELIVERY
-- =========================================
CREATE TABLE deliveries (
    id BIGSERIAL PRIMARY KEY,
    auction_id BIGINT UNIQUE NOT NULL,
    delivery_type VARCHAR(30), -- PICKUP, DELIVERY
    delivery_fee NUMERIC(10,2),
    status VARCHAR(30) DEFAULT 'PENDING', -- PENDING, COMPLETED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delivery_auction FOREIGN KEY (auction_id) REFERENCES auctions(id)
);

-- =========================================
-- COMMISSIONS
-- =========================================
CREATE TABLE commissions (
    id BIGSERIAL PRIMARY KEY,
    auction_id BIGINT UNIQUE NOT NULL,
    percentage NUMERIC(5,2),
    amount NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_commission_auction FOREIGN KEY (auction_id) REFERENCES auctions(id)
);

-- =========================================
-- NOTIFICATIONS
-- =========================================
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(200),
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id)
);