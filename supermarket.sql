-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 12, 2024 at 06:28 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `supermarket`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `getMostBuyCustomer` ()   BEGIN
   SELECT
    customers.id,
    CONCAT(
        customers.first_name,
        ' ',
        customers.last_name
    ) AS customer_name,
    SUM(invoice_details.quantity) AS total_quantity,
    SUM(invoice_details.price) AS total_price
FROM
    customers
RIGHT JOIN invoices ON customers.id = invoices.customer_id
LEFT JOIN invoice_details ON invoices.id = invoice_details.invoice_id
GROUP BY
    customers.id
ORDER BY
    total_price DESC
    LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getPendingOrder` ()   BEGIN
    SELECT
        orders.id AS order_id,
        orders.date AS order_date,
        distributors.name AS distributor_name,
        CONCAT(employees.first_name, ' ', employees.last_name) AS employee_name,
        orders.order_number AS order_number,
        order_details.order_quantity AS order_quantity,
        order_details.import_quantity AS import_quantity
    FROM
        orders
    LEFT JOIN
        distributors ON orders.distributor_id = distributors.id
    LEFT JOIN
        employees ON orders.employee_id = employees.id
    LEFT JOIN
        order_details ON orders.id = order_details.order_id
    WHERE
        orders.status = 1
    ORDER BY order_date ASC
    LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProductsByDateRange` (IN `startDate` DATE, IN `endDate` DATE)   BEGIN
    SELECT
        products.id,
        products.name,
        COUNT(invoice_details.invoice_id) AS count_of_invoices,
        SUM(invoice_details.quantity) AS total_quantity
    FROM
        products
    LEFT JOIN invoice_details ON invoice_details.product_id = products.id
    LEFT JOIN invoices ON invoices.id = invoice_details.invoice_id
    WHERE
        invoices.date BETWEEN startDate AND endDate  -- Filter invoices by date range
    GROUP BY
        products.id, products.name
    ORDER BY
        total_quantity DESC;  -- Optional: to order by total quantity in descending order
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertRandomOrderDetails` ()   BEGIN
    DECLARE orderID INT DEFAULT 1; -- For order IDs from 1 to 5
    DECLARE itemCount INT DEFAULT 5; -- Each order will have 5 items
    DECLARE itemIndex INT DEFAULT 1; -- Item index for each order

    WHILE orderID <= 5 DO  -- Loop through each order_id (1 to 5)
        SET itemIndex = 1;  -- Reset item index for each order

        WHILE itemIndex <= itemCount DO  -- Loop for each item (1 to 5)
            INSERT INTO order_details (order_id, type, product, price, unit, quantity)
            VALUES (
                orderID,                                       -- Random order_id (1 to 5)
                CONCAT('Type ', itemIndex),                    -- Random type
                CONCAT('Product ', orderID, ' Item ', itemIndex),  -- Product name
                ROUND(RAND() * 100, 2),                        -- Random price between 0 and 100
                'kg',                                          -- Example unit
                FLOOR(RAND() * 10) + 1                         -- Random quantity between 1 and 10
            );

            SET itemIndex = itemIndex + 1;  -- Increment item index
        END WHILE;

        SET orderID = orderID + 1;  -- Increment order_id for the next order
    END WHILE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `NAME` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `NAME`, `created_at`, `updated_at`) VALUES
(1, 'Category One', '2024-10-12 03:29:39', '2024-10-12 10:29:39'),
(2, 'Category Two', '2024-10-12 03:29:39', '2024-10-12 10:29:39'),
(3, 'Category Three', '2024-10-12 03:29:39', '2024-10-12 10:29:39'),
(4, 'Category Four', '2024-10-12 03:29:39', '2024-10-12 10:29:39'),
(5, 'Category Five', '2024-10-12 03:29:39', '2024-10-12 10:29:39');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `gender` tinyint(1) NOT NULL DEFAULT 3,
  `phone` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `identity_number` varchar(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `first_name`, `last_name`, `gender`, `phone`, `email`, `address`, `avatar`, `identity_number`, `user_id`, `created_at`, `updated_at`) VALUES
(1, 'FirstName', 'LastName', 3, '(555) 119-8679', 'user1@example.com', '456 Default Ave.', 'default_avatar.jpg', '00000000000098212513', 1, '2024-09-19 03:27:23', '2024-10-11 03:27:23'),
(2, 'FirstName', 'LastName', 3, '(555) 306-5880', 'user2@example.com', '456 Default Ave.', 'default_avatar.jpg', '00000000000001959674', 2, '2024-10-05 03:27:23', '2024-09-26 03:27:23'),
(3, 'FirstName', 'LastName', 3, '(555) 333-6103', 'user7@example.com', '456 Default Ave.', 'default_avatar.jpg', '00000000000005036262', 7, '2024-09-26 03:27:23', '2024-09-25 03:27:23'),
(4, 'FirstName', 'LastName', 3, '(555) 420-9523', 'user9@example.com', '456 Default Ave.', 'default_avatar.jpg', '00000000000049989936', 9, '2024-09-22 03:27:23', '2024-10-04 03:27:23'),
(5, 'FirstName', 'LastName', 3, '(555) 642-7118', 'user10@example.com', '456 Default Ave.', 'default_avatar.jpg', '00000000000063216022', 10, '2024-09-23 03:27:23', '2024-10-13 03:27:23');

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` int(11) NOT NULL,
  `NAME` varchar(255) NOT NULL,
  `manager` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `NAME`, `manager`, `created_at`, `updated_at`) VALUES
(1, 'Sales', NULL, '2024-10-11 13:44:01', '2024-10-11 20:44:01'),
(2, 'Marketing', NULL, '2024-10-11 13:44:01', '2024-10-11 20:44:01'),
(3, 'Human Resources', NULL, '2024-10-11 13:44:01', '2024-10-11 20:44:01'),
(4, 'IT', NULL, '2024-10-11 13:44:01', '2024-10-11 20:44:01'),
(5, 'Finance', NULL, '2024-10-11 13:44:01', '2024-10-11 20:44:01');

-- --------------------------------------------------------

--
-- Table structure for table `distributors`
--

CREATE TABLE `distributors` (
  `id` int(11) NOT NULL,
  `NAME` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `phone_number` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `distributors`
--

INSERT INTO `distributors` (`id`, `NAME`, `address`, `phone_number`, `created_at`, `updated_at`) VALUES
(1, 'Distributor One', '123 Main St, Anytown, USA', '555-1234', '2024-10-11 13:47:16', '2024-10-11 20:47:16'),
(2, 'Distributor Two', '456 Elm St, Othertown, USA', '555-5678', '2024-10-11 13:47:16', '2024-10-11 20:47:16'),
(3, 'Distributor Three', '789 Oak St, Thistown, USA', '555-9012', '2024-10-11 13:47:16', '2024-10-11 20:47:16'),
(4, 'Distributor Four', '101 Pine St, Thatown, USA', '555-3456', '2024-10-11 13:47:16', '2024-10-11 20:47:16'),
(5, 'Distributor Five', '202 Maple St, Everytown, USA', '555-7890', '2024-10-11 13:47:16', '2024-10-11 20:47:16');

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `gender` tinyint(1) NOT NULL DEFAULT 3,
  `phone` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `salary` decimal(15,2) NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `department_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employees`
--

INSERT INTO `employees` (`id`, `first_name`, `last_name`, `gender`, `phone`, `email`, `address`, `salary`, `avatar`, `department_id`, `user_id`, `created_at`, `updated_at`) VALUES
(1, 'user3', 'LastName', 3, '(555) 025-2303', 'user3@example.com', '123 Default St.', 50000.00, 'default_avatar.jpg', 1, 3, '2024-09-27 03:27:23', '2024-10-14 03:27:23'),
(2, 'user4', 'LastName', 3, '(555) 686-2069', 'user4@example.com', '123 Default St.', 50000.00, 'default_avatar.jpg', 5, 4, '2024-09-26 03:27:23', '2024-10-07 03:27:23'),
(3, 'user5', 'LastName', 3, '(555) 252-3376', 'user5@example.com', '123 Default St.', 50000.00, 'default_avatar.jpg', 5, 5, '2024-10-03 03:27:23', '2024-09-29 03:27:23'),
(4, 'user6', 'LastName', 3, '(555) 643-4241', 'user6@example.com', '123 Default St.', 50000.00, 'default_avatar.jpg', 1, 6, '2024-10-05 03:27:23', '2024-09-19 03:27:23'),
(5, 'user8', 'LastName', 3, '(555) 676-8124', 'user8@example.com', '123 Default St.', 50000.00, 'default_avatar.jpg', 1, 8, '2024-09-26 03:27:23', '2024-10-07 03:27:23');

-- --------------------------------------------------------

--
-- Table structure for table `invoices`
--

CREATE TABLE `invoices` (
  `id` int(11) NOT NULL,
  `number` varchar(25) NOT NULL,
  `date` date NOT NULL,
  `employee_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `invoices`
--

INSERT INTO `invoices` (`id`, `number`, `date`, `employee_id`, `customer_id`, `created_at`, `updated_at`) VALUES
(1, '1', '2024-10-04', 4, 3, '2024-10-12 03:40:15', '2024-10-12 10:40:15'),
(2, '2', '2024-09-26', 1, 2, '2024-10-12 03:40:15', '2024-10-12 10:40:15'),
(3, '3', '2024-09-23', 3, 4, '2024-10-12 03:40:15', '2024-10-12 10:40:15'),
(4, '4', '2024-09-21', 4, 1, '2024-10-12 03:40:15', '2024-10-12 10:40:15'),
(5, '5', '2024-09-15', 5, 2, '2024-10-12 03:40:15', '2024-10-12 10:40:15'),
(6, '6', '2024-10-04', 4, 1, '2024-10-12 03:40:15', '2024-10-12 10:40:15'),
(7, '7', '2024-10-09', 1, 1, '2024-10-12 03:40:15', '2024-10-12 10:40:15'),
(8, '8', '2024-10-03', 2, 2, '2024-10-12 03:40:15', '2024-10-12 10:40:15'),
(9, '9', '2024-09-26', 5, 2, '2024-10-12 03:40:15', '2024-10-12 10:40:15'),
(10, '10', '2024-09-29', 3, 4, '2024-10-12 03:40:15', '2024-10-12 10:40:15');

-- --------------------------------------------------------

--
-- Table structure for table `invoice_details`
--

CREATE TABLE `invoice_details` (
  `id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `unit` varchar(10) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(15,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `invoice_details`
--

INSERT INTO `invoice_details` (`id`, `invoice_id`, `product_id`, `unit`, `quantity`, `price`, `created_at`, `updated_at`) VALUES
(1, 1, 44, 'kg', 4, 39.55, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(2, 1, 9, 'pcs', 1, 142.85, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(3, 1, 24, 'ltr', 5, 10.08, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(4, 1, 43, 'kg', 1, 99.60, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(5, 1, 10, 'pcs', 10, 46.14, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(6, 1, 31, 'kg', 1, 101.52, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(7, 1, 5, 'pcs', 5, 125.99, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(8, 1, 47, 'ltr', 2, 137.97, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(9, 1, 9, 'kg', 1, 135.95, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(10, 1, 15, 'pcs', 8, 101.06, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(11, 2, 13, 'kg', 3, 64.03, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(12, 2, 22, 'pcs', 9, 143.40, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(13, 2, 13, 'ltr', 4, 143.34, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(14, 2, 39, 'kg', 10, 95.61, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(15, 2, 11, 'pcs', 2, 28.56, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(16, 2, 23, 'kg', 7, 3.52, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(17, 2, 5, 'pcs', 5, 110.23, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(18, 2, 24, 'ltr', 2, 23.42, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(19, 2, 23, 'kg', 9, 97.13, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(20, 2, 42, 'pcs', 3, 87.94, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(21, 3, 15, 'kg', 7, 62.51, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(22, 3, 7, 'pcs', 4, 76.32, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(23, 3, 21, 'ltr', 6, 68.24, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(24, 3, 33, 'kg', 10, 98.55, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(25, 3, 26, 'pcs', 6, 41.52, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(26, 3, 36, 'kg', 8, 61.07, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(27, 3, 46, 'pcs', 4, 14.71, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(28, 3, 19, 'ltr', 6, 127.55, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(29, 3, 24, 'kg', 8, 57.30, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(30, 3, 33, 'pcs', 2, 89.65, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(31, 4, 33, 'kg', 5, 75.32, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(32, 4, 2, 'pcs', 7, 4.83, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(33, 4, 15, 'ltr', 4, 2.75, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(34, 4, 48, 'kg', 7, 89.83, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(35, 4, 47, 'pcs', 9, 62.24, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(36, 4, 28, 'kg', 6, 3.97, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(37, 4, 26, 'pcs', 5, 137.23, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(38, 4, 5, 'ltr', 8, 71.39, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(39, 4, 6, 'kg', 2, 55.57, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(40, 4, 22, 'pcs', 1, 117.96, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(41, 5, 45, 'kg', 2, 136.36, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(42, 5, 10, 'pcs', 3, 73.60, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(43, 5, 42, 'ltr', 7, 106.32, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(44, 5, 33, 'kg', 1, 68.63, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(45, 5, 4, 'pcs', 10, 69.71, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(46, 5, 27, 'kg', 3, 123.41, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(47, 5, 13, 'pcs', 9, 40.81, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(48, 5, 47, 'ltr', 9, 82.57, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(49, 5, 7, 'kg', 1, 103.38, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(50, 5, 20, 'pcs', 9, 41.18, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(51, 6, 36, 'kg', 7, 52.83, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(52, 6, 35, 'pcs', 4, 114.50, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(53, 6, 37, 'ltr', 4, 83.88, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(54, 6, 38, 'kg', 1, 18.50, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(55, 6, 20, 'pcs', 6, 115.64, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(56, 6, 5, 'kg', 2, 51.75, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(57, 6, 19, 'pcs', 8, 117.84, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(58, 6, 31, 'ltr', 7, 80.25, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(59, 6, 34, 'kg', 8, 88.25, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(60, 6, 40, 'pcs', 2, 93.15, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(61, 7, 26, 'kg', 7, 119.27, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(62, 7, 50, 'pcs', 6, 126.31, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(63, 7, 27, 'ltr', 1, 134.73, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(64, 7, 11, 'kg', 4, 17.82, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(65, 7, 28, 'pcs', 4, 38.27, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(66, 7, 7, 'kg', 10, 30.55, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(67, 7, 13, 'pcs', 7, 60.74, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(68, 7, 7, 'ltr', 5, 134.06, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(69, 7, 5, 'kg', 8, 84.67, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(70, 7, 27, 'pcs', 10, 4.16, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(71, 8, 20, 'kg', 9, 146.80, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(72, 8, 21, 'pcs', 2, 81.28, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(73, 8, 12, 'ltr', 6, 139.03, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(74, 8, 4, 'kg', 6, 78.05, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(75, 8, 49, 'pcs', 4, 90.49, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(76, 8, 6, 'kg', 8, 31.33, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(77, 8, 47, 'pcs', 1, 63.50, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(78, 8, 50, 'ltr', 7, 34.26, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(79, 8, 12, 'kg', 6, 126.12, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(80, 8, 34, 'pcs', 9, 14.70, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(81, 9, 2, 'kg', 9, 20.40, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(82, 9, 8, 'pcs', 4, 35.03, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(83, 9, 8, 'ltr', 1, 1.45, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(84, 9, 38, 'kg', 8, 70.36, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(85, 9, 6, 'pcs', 2, 39.23, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(86, 9, 49, 'kg', 1, 38.62, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(87, 9, 10, 'pcs', 3, 80.14, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(88, 9, 50, 'ltr', 4, 118.86, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(89, 9, 46, 'kg', 2, 144.79, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(90, 9, 22, 'pcs', 3, 124.06, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(91, 10, 24, 'kg', 10, 15.27, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(92, 10, 40, 'pcs', 7, 122.11, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(93, 10, 9, 'ltr', 4, 56.85, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(94, 10, 39, 'kg', 8, 50.71, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(95, 10, 25, 'pcs', 5, 121.90, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(96, 10, 35, 'kg', 10, 132.57, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(97, 10, 23, 'pcs', 7, 114.11, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(98, 10, 47, 'ltr', 4, 149.81, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(99, 10, 47, 'kg', 7, 54.10, '2024-10-12 03:40:41', '2024-10-12 10:40:41'),
(100, 10, 47, 'pcs', 6, 132.83, '2024-10-12 03:40:41', '2024-10-12 10:40:41');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `distributor_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `order_number` int(11) NOT NULL,
  `status` tinyint(1) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `date`, `distributor_id`, `employee_id`, `order_number`, `status`, `address`, `phone`, `note`, `created_at`, `updated_at`) VALUES
(1, '2024-09-21', 5, 3, 1001, 1, '123 Main St, Cityville', '555-1234', 'First order note', '2024-09-30 03:27:23', '2024-10-12 03:27:23'),
(2, '2024-10-07', 3, 5, 1002, 0, '456 Elm St, Townsville', '555-5678', 'Second order note', '2024-10-12 03:27:23', '2024-10-12 03:27:23'),
(3, '2024-10-11', 2, 2, 1003, 1, '789 Oak St, Villageville', '555-9012', 'Third order note', '2024-09-21 03:27:23', '2024-10-12 03:27:23'),
(4, '2024-09-29', 1, 1, 1004, 0, '101 Pine St, Hamletville', '555-3456', 'Fourth order note', '2024-10-10 03:27:23', '2024-10-12 03:27:23'),
(5, '2024-10-03', 5, 4, 1005, 1, '202 Maple St, Boroughville', '555-7890', 'Fifth order note', '2024-10-02 03:27:23', '2024-10-12 03:27:23');

-- --------------------------------------------------------

--
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `type` tinyint(1) NOT NULL,
  `product` varchar(255) NOT NULL,
  `price` decimal(15,2) NOT NULL,
  `unit` varchar(255) NOT NULL,
  `order_quantity` int(11) NOT NULL,
  `import_quantity` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Dumping data for table `order_details`
--

INSERT INTO `order_details` (`id`, `order_id`, `type`, `product`, `price`, `unit`, `order_quantity`, `import_quantity`, `created_at`, `updated_at`) VALUES
(1, 1, 0, 'Product 1 Item 1', 98.51, 'kg', 7, 5, '2024-09-27 03:27:23', '2024-10-12 03:27:23'),
(2, 1, 0, 'Product 1 Item 2', 45.88, 'kg', 3, 2, '2024-09-29 03:27:23', '2024-10-12 03:27:23'),
(3, 1, 0, 'Product 1 Item 3', 85.11, 'kg', 6, 5, '2024-09-22 03:27:23', '2024-10-12 03:27:23'),
(4, 1, 0, 'Product 1 Item 4', 4.20, 'kg', 7, 3, '2024-10-09 03:27:23', '2024-10-12 03:27:23'),
(5, 1, 0, 'Product 1 Item 5', 13.71, 'kg', 8, 6, '2024-09-26 03:27:23', '2024-10-12 03:27:23'),
(6, 2, 0, 'Product 2 Item 1', 22.69, 'kg', 10, 5, '2024-10-02 03:27:23', '2024-10-12 03:27:23'),
(7, 2, 0, 'Product 2 Item 2', 7.79, 'kg', 6, 3, '2024-10-10 03:27:23', '2024-10-12 03:27:23'),
(8, 2, 0, 'Product 2 Item 3', 43.68, 'kg', 6, 2, '2024-09-29 03:27:23', '2024-10-12 03:27:23'),
(9, 2, 0, 'Product 2 Item 4', 59.93, 'kg', 3, 1, '2024-09-15 03:27:23', '2024-10-12 03:27:23'),
(10, 2, 0, 'Product 2 Item 5', 45.56, 'kg', 6, 5, '2024-10-05 03:27:23', '2024-10-12 03:27:23'),
(11, 3, 0, 'Product 3 Item 1', 26.25, 'kg', 8, 3, '2024-09-26 03:27:23', '2024-10-12 03:27:23'),
(12, 3, 0, 'Product 3 Item 2', 88.67, 'kg', 3, 2, '2024-09-13 03:27:23', '2024-10-12 03:27:23'),
(13, 3, 0, 'Product 3 Item 3', 48.59, 'kg', 8, 5, '2024-10-07 03:27:23', '2024-10-12 03:27:23'),
(14, 3, 0, 'Product 3 Item 4', 25.09, 'kg', 1, 1, '2024-10-11 03:27:23', '2024-10-12 03:27:23'),
(15, 3, 0, 'Product 3 Item 5', 39.43, 'kg', 9, 7, '2024-09-22 03:27:23', '2024-10-12 03:27:23'),
(16, 4, 0, 'Product 4 Item 1', 23.43, 'kg', 6, 5, '2024-10-05 03:27:23', '2024-10-12 03:27:23'),
(17, 4, 0, 'Product 4 Item 2', 90.17, 'kg', 10, 8, '2024-10-04 03:27:23', '2024-10-12 03:27:23'),
(18, 4, 0, 'Product 4 Item 3', 2.45, 'kg', 3, 2, '2024-09-26 03:27:23', '2024-10-12 03:27:23'),
(19, 4, 0, 'Product 4 Item 4', 35.00, 'kg', 9, 7, '2024-09-14 03:27:23', '2024-10-12 03:27:23'),
(20, 4, 0, 'Product 4 Item 5', 42.88, 'kg', 5, 4, '2024-10-12 03:27:23', '2024-10-12 03:27:23'),
(21, 5, 0, 'Product 5 Item 1', 99.76, 'kg', 7, 2, '2024-10-02 03:27:23', '2024-10-12 03:27:23'),
(22, 5, 0, 'Product 5 Item 2', 9.44, 'kg', 7, 4, '2024-09-22 03:27:23', '2024-10-12 03:27:23'),
(23, 5, 0, 'Product 5 Item 3', 81.65, 'kg', 3, 2, '2024-10-04 03:27:23', '2024-10-12 03:27:23'),
(24, 5, 0, 'Product 5 Item 4', 66.27, 'kg', 7, 5, '2024-10-01 03:27:23', '2024-10-12 03:27:23'),
(25, 5, 0, 'Product 5 Item 5', 24.24, 'kg', 3, 1, '2024-10-08 03:27:23', '2024-10-12 03:27:23');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `import_price` decimal(15,2) NOT NULL,
  `selling_price` decimal(15,2) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `distributor_id` int(11) NOT NULL,
  `unit` varchar(255) NOT NULL,
  `stall_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `import_price`, `selling_price`, `category_id`, `distributor_id`, `unit`, `stall_id`, `quantity`, `created_at`, `updated_at`) VALUES
(1, 'Product One', 32.53, 111.90, 4, 3, 'kg', 2, 100, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(2, 'Product Two', 39.99, 120.21, 5, 4, 'pcs', 4, 200, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(3, 'Product Three', 79.22, 112.29, 2, 3, 'ltr', 5, 150, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(4, 'Product Four', 39.03, 69.47, 1, 2, 'kg', 2, 120, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(5, 'Product Five', 18.66, 32.84, 3, 1, 'pcs', 3, 250, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(6, 'Product Six', 35.65, 50.66, 4, 1, 'kg', 3, 80, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(7, 'Product Seven', 52.54, 144.53, 2, 2, 'pcs', 5, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(8, 'Product Eight', 35.29, 27.29, 5, 4, 'ltr', 5, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(9, 'Product Nine', 82.95, 26.11, 2, 2, 'kg', 4, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(10, 'Product Ten', 77.94, 80.00, 2, 1, 'pcs', 2, 110, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(11, 'Product Eleven', 0.92, 54.55, 4, 5, 'ltr', 5, 40, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(12, 'Product Twelve', 13.55, 126.28, 5, 3, 'kg', 1, 30, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(13, 'Product Thirteen', 68.74, 52.01, 4, 2, 'pcs', 3, 20, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(14, 'Product Fourteen', 92.39, 133.91, 4, 4, 'ltr', 5, 10, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(15, 'Product Fifteen', 79.32, 72.84, 1, 4, 'kg', 4, 5, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(16, 'Product Sixteen', 52.43, 44.35, 5, 4, 'pcs', 3, 300, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(17, 'Product Seventeen', 52.07, 20.56, 1, 2, 'kg', 4, 150, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(18, 'Product Eighteen', 64.85, 42.82, 3, 3, 'pcs', 2, 250, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(19, 'Product Nineteen', 95.30, 119.47, 1, 2, 'ltr', 4, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(20, 'Product Twenty', 13.35, 56.96, 3, 2, 'kg', 2, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(21, 'Product Twenty-One', 26.60, 80.56, 5, 5, 'pcs', 3, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(22, 'Product Twenty-Two', 85.05, 128.46, 4, 1, 'ltr', 2, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(23, 'Product Twenty-Three', 87.17, 102.87, 5, 1, 'kg', 4, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(24, 'Product Twenty-Four', 6.28, 68.10, 1, 1, 'pcs', 5, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(25, 'Product Twenty-Five', 78.90, 148.29, 3, 5, 'ltr', 5, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(26, 'Product Twenty-Six', 47.74, 128.17, 5, 4, 'kg', 4, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(27, 'Product Twenty-Seven', 41.30, 10.61, 1, 2, 'pcs', 3, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(28, 'Product Twenty-Eight', 20.57, 98.52, 4, 2, 'ltr', 5, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(29, 'Product Twenty-Nine', 1.70, 92.74, 1, 2, 'kg', 4, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(30, 'Product Thirty', 3.10, 46.74, 3, 2, 'pcs', 3, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(31, 'Product Thirty-One', 61.19, 58.46, 1, 2, 'ltr', 4, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(32, 'Product Thirty-Two', 1.99, 26.17, 5, 3, 'kg', 2, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(33, 'Product Thirty-Three', 68.22, 94.59, 1, 4, 'pcs', 5, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(34, 'Product Thirty-Four', 47.38, 110.05, 2, 1, 'ltr', 3, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(35, 'Product Thirty-Five', 3.74, 135.58, 3, 2, 'kg', 3, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(36, 'Product Thirty-Six', 2.81, 140.95, 4, 2, 'pcs', 3, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(37, 'Product Thirty-Seven', 32.16, 54.35, 5, 1, 'ltr', 1, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(38, 'Product Thirty-Eight', 53.21, 11.47, 4, 4, 'kg', 1, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(39, 'Product Thirty-Nine', 63.99, 112.95, 5, 5, 'pcs', 2, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(40, 'Product Forty', 60.95, 20.99, 5, 5, 'ltr', 1, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(41, 'Product Forty-One', 52.84, 65.96, 4, 4, 'kg', 5, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(42, 'Product Forty-Two', 26.01, 89.61, 2, 2, 'pcs', 3, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(43, 'Product Forty-Three', 20.79, 42.08, 4, 1, 'ltr', 5, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(44, 'Product Forty-Four', 47.91, 91.97, 4, 2, 'kg', 4, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(45, 'Product Forty-Five', 22.08, 34.15, 3, 4, 'pcs', 1, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(46, 'Product Forty-Six', 19.29, 119.12, 2, 3, 'ltr', 4, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(47, 'Product Forty-Seven', 83.49, 5.00, 4, 2, 'kg', 1, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(48, 'Product Forty-Eight', 67.99, 32.15, 1, 3, 'pcs', 3, 60, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(49, 'Product Forty-Nine', 90.24, 5.86, 3, 2, 'ltr', 1, 90, '2024-10-12 03:32:49', '2024-10-12 10:32:49'),
(50, 'Product Fifty', 80.50, 83.81, 2, 2, 'kg', 5, 70, '2024-10-12 03:32:49', '2024-10-12 10:32:49');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `NAME` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `NAME`, `code`, `created_at`, `updated_at`) VALUES
(1, 'Admin', 'admin', '2024-10-11 13:36:16', '2024-10-11 20:36:16'),
(2, 'Customer', 'customer', '2024-10-11 13:36:16', '2024-10-11 20:36:16'),
(3, 'Employee', 'employee', '2024-10-11 13:36:16', '2024-10-11 20:36:16');

-- --------------------------------------------------------

--
-- Table structure for table `stalls`
--

CREATE TABLE `stalls` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stalls`
--

INSERT INTO `stalls` (`id`, `name`, `created_at`, `updated_at`) VALUES
(1, 'Stall One', '2024-10-12 03:30:03', '2024-10-12 10:30:03'),
(2, 'Stall Two', '2024-10-12 03:30:03', '2024-10-12 10:30:03'),
(3, 'Stall Three', '2024-10-12 03:30:03', '2024-10-12 10:30:03'),
(4, 'Stall Four', '2024-10-12 03:30:03', '2024-10-12 10:30:03'),
(5, 'Stall Five', '2024-10-12 03:30:03', '2024-10-12 10:30:03');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `flag` tinyint(1) DEFAULT 0,
  `token` varchar(255) DEFAULT NULL,
  `role_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `flag`, `token`, `role_id`, `created_at`, `updated_at`) VALUES
(1, 'user1@example.com', 'password1', 1, 'token1', 3, '2024-09-19 03:27:23', '2024-10-11 03:27:23'),
(2, 'user2@example.com', 'password2', 1, 'token2', 3, '2024-10-05 03:27:23', '2024-09-26 03:27:23'),
(3, 'user3@example.com', 'password3', 1, 'token3', 2, '2024-09-27 03:27:23', '2024-10-14 03:27:23'),
(4, 'user4@example.com', 'password4', 1, 'token4', 2, '2024-09-26 03:27:23', '2024-10-07 03:27:23'),
(5, 'user5@example.com', 'password5', 1, 'token5', 2, '2024-10-03 03:27:23', '2024-09-29 03:27:23'),
(6, 'user6@example.com', 'password6', 1, 'token6', 2, '2024-10-05 03:27:23', '2024-09-19 03:27:23'),
(7, 'user7@example.com', 'password7', 1, 'token7', 3, '2024-09-26 03:27:23', '2024-09-25 03:27:23'),
(8, 'user8@example.com', 'password8', 1, 'token8', 2, '2024-09-26 03:27:23', '2024-10-07 03:27:23'),
(9, 'user9@example.com', 'password9', 1, 'token9', 3, '2024-09-22 03:27:23', '2024-10-04 03:27:23'),
(10, 'user10@example.com', 'password10', 1, 'token10', 3, '2024-09-23 03:27:23', '2024-10-13 03:27:23');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `identity_number` (`identity_number`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `manager` (`manager`);

--
-- Indexes for table `distributors`
--
ALTER TABLE `distributors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `department_id` (`department_id`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `employee_id` (`employee_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `invoice_details`
--
ALTER TABLE `invoice_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `invoice_id` (`invoice_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `distributor_id` (`distributor_id`),
  ADD KEY `employee_id` (`employee_id`);

--
-- Indexes for table `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `distributor_id` (`distributor_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `stall_id` (`stall_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stalls`
--
ALTER TABLE `stalls`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `role_id` (`role_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `distributors`
--
ALTER TABLE `distributors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `invoice_details`
--
ALTER TABLE `invoice_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `order_details`
--
ALTER TABLE `order_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `stalls`
--
ALTER TABLE `stalls`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `departments`
--
ALTER TABLE `departments`
  ADD CONSTRAINT `departments_ibfk_1` FOREIGN KEY (`manager`) REFERENCES `employees` (`id`);

--
-- Constraints for table `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `employees_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`),
  ADD CONSTRAINT `invoices_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`);

--
-- Constraints for table `invoice_details`
--
ALTER TABLE `invoice_details`
  ADD CONSTRAINT `invoice_details_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  ADD CONSTRAINT `invoice_details_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`distributor_id`) REFERENCES `distributors` (`id`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`);

--
-- Constraints for table `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`distributor_id`) REFERENCES `distributors` (`id`),
  ADD CONSTRAINT `products_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  ADD CONSTRAINT `products_ibfk_3` FOREIGN KEY (`stall_id`) REFERENCES `stalls` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
