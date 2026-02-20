-- Create database
CREATE DATABASE IF NOT EXISTS Library_manaement_system;
-- Database 'Library_manaement_system' for task 1 to task 12
-- Database 'library_project_db' for task 13 to task 20
USE Library_manaement_system;

-- Create tables
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
 (
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id VARCHAR(10),
	branch_address VARCHAR(60),
    contact_no VARCHAR(10)
);
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
 (
	emp_id VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(25),
	position VARCHAR(25),
    salary INT,
    branch_id VARCHAR(25) --FK
);
DROP TABLE IF EXISTS books;
CREATE TABLE books
 (
	isbn VARCHAR(20) PRIMARY KEY,
	book_title VARCHAR(75),
	category VARCHAR(20),
    rental_price FLOAT,
    status VARCHAR(10),
    author VARCHAR(35),
    publisher VARCHAR(50)
);
DROP TABLE IF EXISTS members;
CREATE TABLE members
 (
	member_id VARCHAR(20) PRIMARY KEY,
	member_name VARCHAR(25),
	member_address VARCHAR(75),
    reg_date DATE
);
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
 (
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10), --FK
	issued_book_name VARCHAR(75),
    issued_date DATE,
    issued_book_isbn VARCHAR(20), --FK
    issued_emp_id VARCHAR(10) --FK
);
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
 (
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(10), --FK
	return_book_name VARCHAR(75),
    return_date DATE,
    return_book_isbn VARCHAR(10)
);

--Assign foreign key

ALTER TABLE issued_status
ADD CONSTRAINT fk_member_id
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_book_isbn
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_emp_id
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_id
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

ALTER TABLE books
MODIFY category VARCHAR(20);
ALTER TABLE branch
MODIFY contact_no VARCHAR(25);
ALTER TABLE issued_status
MODIFY issued_book_name VARCHAR(50);

/*
Task 1: Create a new book record 
"978-1-60129-456-2", "To kill a mocking bird", "Classic", "6.00", "Yes",
"Harper Lee", "J.B. Lippincott & Co."
*/

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ("978-1-60129-456-2", "To kill a mocking bird", "Classic", "6.00", "Yes", "Harper Lee", "J.B. Lippincott & Co.")

SELECT * FROM books
WHERE isbn = "978-1-60129-456-2";

/*
Task 2: Update an existing member address
*/

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101'

/*
Task 3: Delete a record from issued status table
Objective: Delete the record with issued_id = 'IS121' from the issued status table
*/

DELETE FROM issued_status
WHERE issued_id = 'IS121'
/*
Task 4:Retrieve all books issued by a specific employee
Objective: Select all books issued by the employee with emp_id = 'E101'
*/

SELECT * FROM employees
JOIN issued_status ON issued_status.issued_emp_id = employees.emp_id
WHERE emp_id = 'E101'

/*
Task 5: List members who have issued more than one book
Objective: Use group by to find members who have issued more than one book
*/

SELECT emp_id, emp_name, COUNT(issued_status.issued_id) AS book_count
FROM employees
JOIN issued_status ON issued_status.issued_emp_id = employees.emp_id
GROUP BY emp_id, emp_name
HAVING COUNT(issued_id) > 1
ORDER BY book_count DESC;

/*
Task 6: Create summary table using CTAS to create new tables based on query results
each book and total book_issued_cnt
*/

CREATE TABLE book_cnts
AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2
ORDER BY 3 DESC;
SELECT * FROM book_cnts

/*
Task 7: Retrieve all books from specific category
*/

SELECT *
FROM books
WHERE category = 'Classic'

/*
Task 8: Find Total Rental Income by Category
*/

SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1
ORDER BY 2 DESC;

/*
Task 9: List members who registered in last 180 days
*/

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('120', 'Sam', '145 Main st', '2026-02-16'),
('C121', 'John', '133 Main st', '2026-02-16')

SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 day;

/*
Task 10: List the employees with thier branch manager's name and branch details
*/

SELECT
	e1.*,
    b.branch_id,
    b.branch_address,
    e2.emp_name as manager
FROM employees as e1
JOIN
branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id

/*
Task 11: Create a table of books with rental price above a certain threshold above 7USD
*/

CREATE TABLE books_above_7USD
AS
SELECT *
FROM books
WHERE rental_price > 7;

SELECT * FROM books_above_7USD;

/*
Task 12: Retrieve the list of books not yet returned
*/

SELECT
	DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
Display the memner's id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which have been returned
-- overdue > 30 days

-- Database 'Library_manaement_system' for task 1 to task 12
-- Database 'library_project_db' for task 13 to task 20
USE library_project_db;
SELECT
	ist.issued_member_id,
    m.member_name,
    bks.book_title,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date AS overdue_days
FROM issued_status AS ist
JOIN members AS m
	ON m.member_id = ist.issued_member_id
JOIN books AS bks
ON bks.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rs
ON rs.issued_id = ist.issued_id
WHERE
	return_date IS NULL
    AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes"
when they are returned (based on entries in the return_status table).
*/
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-330-25864-8';
-- IS104

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';

-- 
INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS125', 'IS130', CURRENT_DATE, 'Good');
SELECT * FROM return_status
WHERE issued_id = 'IS130';


-- Store Procedures
DELIMITER //

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert return record
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE(), p_book_quality);

    -- Get book details
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book availability
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END //

DELIMITER ;

CALL add_return_records('RS138', 'IS135', 'Good');

SELECT * FROM return_status
WHERE issued_id = 'IS135'
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned,
and the total revenue generated from book rentals.
*/
SELECT * FROM branch
SELECT * FROM books
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM return_status

CREATE TABLE branch_report
AS
SELECT
	b.branch_id,
    b.manager_id,
	SUM(bk.rental_price) AS revenue_generated,
    COUNT(ist.issued_id) AS books_issued,
    COUNT(rs.return_id) AS books_returned
FROM issued_status AS ist
JOIN
employees AS e
ON e.emp_id = ist.issued_emp_id
JOIN
branch AS b
ON e.branch_id = b.branch_id
LEFT JOIN 
return_status AS rs
ON rs.issued_id = ist.issued_id
JOIN
books AS bk
ON bk.isbn = ist.issued_book_isbn
GROUP BY 1, 2;

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at
least one book in the last 6 months.
*/

SELECT * FROM employees
SELECT * FROM issued_status

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN(SELECT
					DISTINCT issued_member_id
					FROM issued_status
					WHERE issued_date > CURRENT_DATE - INTERVAL 6 MONTH
					);

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.
*/

SELECT * FROM employees
SELECT * FROM issued_status

SELECT e.emp_id,
		e.emp_name,
        b.*,
		COUNT(ist.issued_id) as books_processed
FROM employees AS e
JOIN issued_status AS ist
ON ist.issued_emp_id = e.emp_id
JOIN branch AS b
ON e.branch_id = b.branch_id
GROUP BY 1
ORDER BY books_processed DESC
LIMIT 3;

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
Display the member name, book title, and the number of times they've issued damaged books.    
*/

SELECT
	m.member_name,
	ist.issued_book_name AS book_title,
    COUNT(*) AS issued_count
FROM issued_status as ist
JOIN
members as m
ON m.member_id = ist.issued_member_id
JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.book_quality = 'Damaged'
GROUP BY 1,2
HAVING COUNT(*) > 2;
-- Zero rows returned as no member issued damaged book more than 2 times

/*
Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.
*/

DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Get book status
    SELECT status 
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    -- If book does not exist
    IF v_status IS NULL THEN
        SELECT CONCAT('Book with ISBN ', p_issued_book_isbn, ' does not exist.') AS message;

    -- If book is available
    ELSEIF v_status = 'yes' THEN

        INSERT INTO issued_status(
            issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES(
            p_issued_id,
            p_issued_member_id,
            CURRENT_DATE(),
            p_issued_book_isbn,
            p_issued_emp_id
        );

        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        SELECT 'Book issued successfully' AS message;

    -- If book is unavailable
    ELSE
        SELECT CONCAT('Book is currently unavailable. ISBN: ', p_issued_book_isbn) AS message;

    END IF;

END $$

DELIMITER ;

SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'
-- 

/*
Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/

CREATE TABLE Fine_overdue_books
AS
SELECT
	ist.issued_member_id AS member_id,
    COUNT(*) AS Overdue_books,
    SUM(DATEDIFF(CURRENT_DATE, ist.issued_date) - 30) * 0.50 AS Total_fine_$
FROM issued_status AS ist
JOIN members AS m
	ON m.member_id = ist.issued_member_id
JOIN books AS bks
ON bks.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rs
ON rs.issued_id = ist.issued_id
WHERE
	rs.return_date IS NULL
    AND (CURRENT_DATE - ist.issued_date) > 30
GROUP BY 1;