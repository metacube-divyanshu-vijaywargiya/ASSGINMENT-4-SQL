-- Assignment1

-- Create a function to calculate number of orders in a month. Month and year will be input parameter to function. 
DELIMITER //
CREATE FUNCTION GetOrderCountByMonth(monthInput INT, yearInput INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE orderCount INT;

    SELECT COUNT(*)
    INTO orderCount
    FROM orders
    WHERE MONTH(OrderDate) = monthInput AND YEAR(OrderDate) = yearInput;

    RETURN orderCount;
END //

SELECT GetOrderCountByMonth(11, 2024) AS OrderCount;

-- Create a function to return month in a year having maximum orders. Year will be input parameter.
DELIMITER //

CREATE FUNCTION GetMaxOrdersInMonth (yearInput INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE maxMonth INT;

    SELECT MONTH(OrderDate) 
    INTO maxMonth
    FROM orders
    WHERE YEAR(OrderDate) = yearInput
    GROUP BY MONTH(OrderDate)
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    RETURN maxMonth;
END //

SELECT GetMaxOrdersInMonth(2024) AS Month;

-- Assignment 2
-- Create a Stored procedure to retrieve average sales of each product in a month. Month and year will be input parameter to function.
DELIMITER //

CREATE PROCEDURE GetAverageSalesByProduct(IN monthInput INT, IN yearInput INT)
BEGIN
    SELECT 
        p.product_id AS ProductId,
        p.product_name AS ProductName,
        AVG(oi.product_quantity * p.product_price) AS AverageSales
    FROM product p
	JOIN order_item oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE MONTH(o.OrderDate) = monthInput AND YEAR(o.OrderDate) = yearInput
    GROUP BY p.product_id, p.product_name;
END //

DELIMITER ;

-- Calling procedure
CALL GetAverageSalesByProduct(11,2024);


-- Create a stored procedure to retrieve table having order detail with status for a given period. Start date and end date will be input parameter. Put validation on input dates like start date is less than end date. If start date is greater than end date take first date of month as start date.
DELIMITER //

CREATE PROCEDURE get_order_details_by_date(IN input_start_date DATE, IN input_end_date DATE)
BEGIN
    DECLARE new_adjusted_start_date DATE;

    IF input_start_date > input_end_date THEN
        SET new_adjusted_start_date = CONCAT(YEAR(input_end_date),'-',MONTH(input_end_date),'-','01');
    ELSE
        SET new_adjusted_start_date = input_start_date;
    END IF;

    SELECT 
        o.order_id AS OrderId,
        o.order_amount AS OrderAmount,
        o.OrderDate,
        o.user_id AS UserId,
        o.shipping_address AS ShippingAddress,
        oi.order_status AS OrderStatus
    FROM 
        orders o
    JOIN 
        order_item oi ON o.order_id = oi.order_id
    WHERE 
        o.OrderDate BETWEEN new_adjusted_start_date AND input_end_date;
END //

DELIMITER ;

CALL get_order_details_by_date('2024-11-30','2024-11-16');


-- Assignment 3 

-- Identify the columns require indexing in order, product, category tables and create indexes.
-- Answer
-- 1. Orders Table
-- Columns to Consider for Indexing:
--     Foreign Key: user_id (to speed up lookups for orders by user)
--     Date Column: OrderDate (to speed up queries filtering by date)

-- 2. Product Table
-- Columns to Consider for Indexing:
--     Foreign Key: product_category_id (to speed up lookups for products by category)

-- For Orders Table
CREATE INDEX idx_user_id ON orders(user_id);
CREATE INDEX idx_order_date ON orders(OrderDate);

-- For the Product Table
CREATE INDEX idx_product_category_id ON product(product_category_id);