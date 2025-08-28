# Simple Library Management System Database

## Description
A MySQL database system for managing library operations including books, authors, members, and loans. Demonstrates relational database concepts with proper constraints and relationships.

## Database Structure
- **6 Tables**: Categories, Authors, Books, Book_Authors, Members, Loans
- **Relationships**: 1-to-Many (Categories→Books, Members→Loans), Many-to-Many (Books↔Authors)
- **Features**: Book cataloging, member management, loan tracking, fine calculation


## Setup Instructions

### Prerequisites
- MySQL Server (5.7+)
- MySQL client (Workbench, phpMyAdmin, or command line)

### Installation
1. Download `simple_library_system.sql`
2. Import using one of these methods:

**Command Line:**
\`\`\`bash
mysql -u username -p < simple_library_system.sql
\`\`\`

**MySQL Workbench:**
- Server → Data Import → Import from Self-Contained File → Select SQL file → Start Import

**phpMyAdmin:**
- Import tab → Choose file → Go

### Verification
\`\`\`sql
USE simple_library;
SHOW TABLES;
SELECT * FROM book_details;
\`\`\`

## Sample Queries
\`\`\`sql
-- Available books
SELECT title, available_copies FROM books WHERE available_copies > 0;

-- Books by author
SELECT b.title FROM books b 
JOIN book_authors ba ON b.book_id = ba.book_id 
JOIN authors a ON ba.author_id = a.author_id 
WHERE a.last_name = 'Orwell';

-- Overdue loans
SELECT * FROM active_loans WHERE days_overdue > 0;
\`\`\`

## Sample Data
Includes 4 categories, 3 authors, 3 books, 3 members, and 2 active loans for immediate testing.

