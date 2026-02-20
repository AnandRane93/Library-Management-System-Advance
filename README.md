# Library Management System using SQL Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**:'Library_manaement_system' for task 1 to task 12 & 'library_project_db' for task 13 to task 20

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.


![Library_project](https://github.com/AnandRane93/Library-Management-System-Advance/blob/main/library.jpg)


## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/AnandRane93/Library-Management-System-Advance/blob/main/library_erd.png)

- **Database Creation**: Created a database named `Library_manaement_system` and `library_project_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
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

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ("978-1-60129-456-2", "To kill a mocking bird", "Classic", "6.00", "Yes", "Harper Lee", "J.B. Lippincott & Co.")

SELECT * FROM books
WHERE isbn = "978-1-60129-456-2";
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101'
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121'
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM employees
JOIN issued_status ON issued_status.issued_emp_id = employees.emp_id
WHERE emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT emp_id, emp_name, COUNT(issued_status.issued_id) AS book_count
FROM employees
JOIN issued_status ON issued_status.issued_emp_id = employees.emp_id
GROUP BY emp_id, emp_name
HAVING COUNT(issued_id) > 1
ORDER BY book_count DESC;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_cnts
AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2
ORDER BY 3 DESC;
SELECT * FROM book_cnts
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT *
FROM books
WHERE category = 'Classic'
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT b.category, SUM(b.rental_price), COUNT(*)
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1
ORDER BY 2 DESC;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('120', 'Sam', '145 Main st', '2026-02-16'),
('C121', 'John', '133 Main st', '2026-02-16')
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 day;
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
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
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE books_above_7USD
AS
SELECT *
FROM books
WHERE rental_price > 7;

SELECT * FROM books_above_7USD;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT
	DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
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
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

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

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
SELECT * FROM branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN(SELECT
                        DISTINCT issued_member_id
                        FROM issued_status
                        WHERE issued_date > CURRENT_DATE - INTERVAL 6 MONTH
                        );
SELECT * FROM active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT
            e.emp_id,
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
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

```sql

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

```


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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
```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql

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

```



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


## Author - Anand M Rane

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/anand-rane-630297185)

Thank you for your interest in this project!
