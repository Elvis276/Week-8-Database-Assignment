-- =====================================================
-- SIMPLE LIBRARY MANAGEMENT SYSTEM DATABASE
-- =====================================================
-- A concise database demonstrating key relationships and constraints
-- Use case: Small library book lending system

-- Create database
CREATE DATABASE IF NOT EXISTS simple_library;
USE simple_library;

-- =====================================================
-- 1. CATEGORIES TABLE (Master data)
-- =====================================================
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- =====================================================
-- 2. AUTHORS TABLE 
-- =====================================================
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    birth_date DATE,
    CONSTRAINT chk_author_email CHECK (email LIKE '%@%.%')
);

-- =====================================================
-- 3. BOOKS TABLE (Main entity)
-- =====================================================
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(13) UNIQUE NOT NULL,
    publication_year YEAR,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    category_id INT NOT NULL,
    
    -- Foreign key constraint
    CONSTRAINT fk_book_category 
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Business rule: available copies cannot exceed total copies
    CONSTRAINT chk_copies CHECK (available_copies <= total_copies AND available_copies >= 0)
);

-- =====================================================
-- 4. BOOK_AUTHORS TABLE (Many-to-Many relationship)
-- =====================================================
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    role ENUM('Primary Author', 'Co-Author', 'Editor') DEFAULT 'Primary Author',
    
    PRIMARY KEY (book_id, author_id),
    
    CONSTRAINT fk_ba_book 
        FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    CONSTRAINT fk_ba_author 
        FOREIGN KEY (author_id) REFERENCES authors(author_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- 5. MEMBERS TABLE 
-- =====================================================
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    
    CONSTRAINT chk_member_email CHECK (email LIKE '%@%.%')
);

-- =====================================================
-- 6. LOANS TABLE (Transaction table - Many-to-Many)
-- =====================================================
CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE NULL,
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    
    -- Foreign key constraints
    CONSTRAINT fk_loan_book 
        FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    CONSTRAINT fk_loan_member 
        FOREIGN KEY (member_id) REFERENCES members(member_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Business rules
    CONSTRAINT chk_due_date CHECK (due_date > loan_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date),
    CONSTRAINT chk_fine_amount CHECK (fine_amount >= 0)
);

-- =====================================================
-- INDEXES for Performance
-- =====================================================
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_loans_due_date ON loans(due_date);

-- =====================================================
-- SAMPLE DATA
-- =====================================================

-- Insert categories
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Fictional literature and novels'),
('Science', 'Scientific and technical books'),
('History', 'Historical books and biographies'),
('Technology', 'Computer science and technology books');

-- Insert authors
INSERT INTO authors (first_name, last_name, email, birth_date) VALUES
('George', 'Orwell', 'g.orwell@email.com', '1903-06-25'),
('Isaac', 'Asimov', 'i.asimov@email.com', '1920-01-02'),
('Agatha', 'Christie', 'a.christie@email.com', '1890-09-15');

-- Insert books
INSERT INTO books (title, isbn, publication_year, total_copies, available_copies, category_id) VALUES
('1984', '9780451524935', 1949, 3, 2, 1),
('Foundation', '9780553293357', 1951, 2, 2, 2),
('Murder on the Orient Express', '9780062693662', 1934, 2, 1, 1);

-- Link books to authors
INSERT INTO book_authors (book_id, author_id, role) VALUES
(1, 1, 'Primary Author'),
(2, 2, 'Primary Author'),
(3, 3, 'Primary Author');

-- Insert members
INSERT INTO members (first_name, last_name, email, phone, address) VALUES
('John', 'Doe', 'john.doe@email.com', '555-0101', '123 Main St'),
('Jane', 'Smith', 'jane.smith@email.com', '555-0102', '456 Oak Ave'),
('Bob', 'Johnson', 'bob.johnson@email.com', '555-0103', '789 Pine Rd');

-- Insert sample loans
INSERT INTO loans (book_id, member_id, loan_date, due_date, status) VALUES
(1, 1, '2024-01-15', '2024-02-15', 'Active'),
(3, 2, '2024-01-10', '2024-02-10', 'Active');

-- =====================================================
-- USEFUL VIEWS
-- =====================================================

-- View: Books with author information
CREATE VIEW book_details AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    b.publication_year,
    b.available_copies,
    b.total_copies,
    c.category_name,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors
FROM books b
JOIN categories c ON b.category_id = c.category_id
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
GROUP BY b.book_id;

-- View: Active loans with member and book details
CREATE VIEW active_loans AS
SELECT 
    l.loan_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,
    b.title AS book_title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.status = 'Active';

-- =====================================================
-- END OF SCRIPT
-- =====================================================
