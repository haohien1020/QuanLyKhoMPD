CREATE DATABASE  IF NOT EXISTS `swp391_generator_management` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `swp391_generator_management`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: swp391_generator_management
-- ------------------------------------------------------
-- Server version	9.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `table_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `record_id` int DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`log_id`),
  KEY `fk_activity_logs_user_id` (`user_id`),
  CONSTRAINT `fk_activity_logs_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_logs`
--

LOCK TABLES `activity_logs` WRITE;
/*!40000 ALTER TABLE `activity_logs` DISABLE KEYS */;
INSERT INTO `activity_logs` VALUES (1,1,'CREATE_USER','users',4,'Admin created staff account','2026-05-21 20:34:09.706666'),(2,2,'APPROVE_PART_REQUEST','part_requests',2,'Manager approved part request','2026-05-21 20:34:09.706666'),(3,3,'CREATE_STOCK_TRANSFER','stock_transfers',1,'Warehouse manager created stock transfer','2026-05-21 20:34:09.706666'),(4,4,'CREATE_REPAIR_REQUEST','maintenance_repairs',1,'Staff reported generator issue','2026-05-21 20:34:09.706666');
/*!40000 ALTER TABLE `activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_type_id` int NOT NULL,
  `category_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  KEY `idx_categories_category_type_id` (`category_type_id`),
  CONSTRAINT `fk_categories_category_types` FOREIGN KEY (`category_type_id`) REFERENCES `category_types` (`category_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_types`
--

DROP TABLE IF EXISTS `category_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category_types` (
  `category_type_id` int NOT NULL AUTO_INCREMENT,
  `type_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_type_id`),
  UNIQUE KEY `type_code` (`type_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_types`
--

LOCK TABLES `category_types` WRITE;
/*!40000 ALTER TABLE `category_types` DISABLE KEYS */;
INSERT INTO `category_types` VALUES (1,'GENERATOR','Loai hang hoa MPD',NULL,'ACTIVE','2026-05-31 13:51:50','2026-05-31 13:51:50'),(2,'PART','Muc vat tu',NULL,'ACTIVE','2026-05-31 13:51:50','2026-05-31 13:51:50');
/*!40000 ALTER TABLE `category_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `customer_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Chị Thảo','0987623234','thao123@gmail.com','12 Phủ Lý','ACTIVE','2026-06-21 15:07:53','2026-06-21 18:56:08');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generators`
--

DROP TABLE IF EXISTS `generators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `generators` (
  `generator_id` int NOT NULL AUTO_INCREMENT,
  `warehouse_id` int NOT NULL,
  `supplier_id` int DEFAULT NULL,
  `generator_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `serial_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `brand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `power_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fuel_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'SUPPLIER',
  `import_date` datetime(6) DEFAULT NULL,
  `purchase_price` decimal(15,2) DEFAULT NULL,
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'IN_STOCK',
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `category_id` int DEFAULT NULL,
  `barcode` text COLLATE utf8mb4_unicode_ci,
  `rental_price` decimal(15,2) DEFAULT '0.00',
  PRIMARY KEY (`generator_id`),
  UNIQUE KEY `uq_generators_serial_number` (`serial_number`),
  KEY `fk_generators_supplier_id` (`supplier_id`),
  KEY `fk_generators_warehouse_id` (`warehouse_id`),
  KEY `idx_generators_category_id` (`category_id`),
  CONSTRAINT `fk_generators_categories` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`),
  CONSTRAINT `fk_generators_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`),
  CONSTRAINT `fk_generators_warehouse_id` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generators`
--

LOCK TABLES `generators` WRITE;
/*!40000 ALTER TABLE `generators` DISABLE KEYS */;
INSERT INTO `generators` VALUES (1,1,1,'Cummins Generator 100KVA','GEN-CUM-001','Cummins','100 kW','Diesel','SUPPLIER','2026-05-01 00:00:00.000000',180000000.00,'A1-01','UNDER_REPAIR','Imported from Cummins Vietnam','2026-05-21 20:34:09.700000','2026-06-21 16:18:08.000000',NULL,'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',100000.00),(2,1,2,'Mitsubishi Generator 150KVA','GEN-MIT-001','Mitsubishi','150 kW','Diesel','SUPPLIER','2026-05-03 00:00:00.000000',250000000.00,'A1-02','IN_STOCK','Imported from Mitsubishi Power Supplier','2026-05-21 20:34:09.700000','2026-06-21 16:18:03.000000',NULL,'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',200000.00),(3,2,NULL,'Denyo Generator 80KVA','GEN-DEN-001','Denyo','80KVA','Diesel','TRANSFER','2026-05-06 14:00:00.000000',120000000.00,'B1-01','IN_STOCK','Transferred from Main Warehouse','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL,0.00),(4,3,NULL,'Honda Generator 30KVA','GEN-HON-001','Honda','30KVA','Gasoline','TRANSFER','2026-05-08 15:30:00.000000',45000000.00,'C1-01','MAINTENANCE','Transferred from Main Warehouse','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL,0.00),(5,1,1,'Cummins Generator 200KVA','GEN-CUM-002','Cummins','200 kW','Gasoline','SUPPLIER','2026-05-10 00:00:00.000000',320000000.00,'A2-01','UNDER_REPAIR','Imported from Cummins Vietnam','2026-05-21 20:34:09.700000','2026-06-21 16:17:56.000000',NULL,'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',200000.00),(6,1,1,'EV232','233','Honda','D','Diesel','SUPPLIER','2026-06-11 00:00:00.000000',123232.00,'A1','UNDER_REPAIR','Q','2026-06-21 01:07:59.838110','2026-06-21 01:07:59.838110',NULL,'',0.00),(7,1,3,'HD_023','HJD_23','Honda','2 kW','Diesel','SUPPLIER','2026-06-21 00:00:00.000000',3000000.00,'A02','IN_STOCK','ok','2026-06-21 11:15:13.837625','2026-06-21 16:17:35.000000',NULL,'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',300000.00);
/*!40000 ALTER TABLE `generators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transactions`
--

DROP TABLE IF EXISTS `inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transactions` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `warehouse_id` int NOT NULL,
  `supplier_id` int DEFAULT NULL,
  `created_by` int NOT NULL,
  `transaction_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `generator_id` int DEFAULT NULL,
  `part_id` int DEFAULT NULL,
  `quantity` int DEFAULT '1',
  `transaction_date` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'COMPLETED',
  PRIMARY KEY (`transaction_id`),
  KEY `fk_inventory_transactions_created_by` (`created_by`),
  KEY `fk_inventory_transactions_generator_id` (`generator_id`),
  KEY `fk_inventory_transactions_part_id` (`part_id`),
  KEY `fk_inventory_transactions_supplier_id` (`supplier_id`),
  KEY `fk_inventory_transactions_warehouse_id` (`warehouse_id`),
  CONSTRAINT `fk_inventory_transactions_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_inventory_transactions_generator_id` FOREIGN KEY (`generator_id`) REFERENCES `generators` (`generator_id`),
  CONSTRAINT `fk_inventory_transactions_part_id` FOREIGN KEY (`part_id`) REFERENCES `parts` (`part_id`),
  CONSTRAINT `fk_inventory_transactions_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`),
  CONSTRAINT `fk_inventory_transactions_warehouse_id` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transactions`
--

LOCK TABLES `inventory_transactions` WRITE;
/*!40000 ALTER TABLE `inventory_transactions` DISABLE KEYS */;
INSERT INTO `inventory_transactions` VALUES (1,1,1,2,'IMPORT','GENERATOR',1,NULL,1,'2026-05-21 20:34:09.703333','Import Cummins generator from supplier','COMPLETED'),(2,1,2,2,'IMPORT','GENERATOR',2,NULL,1,'2026-05-21 20:34:09.703333','Import Mitsubishi generator from supplier','COMPLETED'),(3,1,3,3,'IMPORT','PART',NULL,1,20,'2026-05-21 20:34:09.703333','Import oil filters','COMPLETED'),(4,1,NULL,4,'EXPORT','PART',NULL,2,3,'2026-05-21 20:34:09.703333','Used fuel filters for maintenance','COMPLETED'),(5,1,1,3,'IMPORT','GENERATOR',6,NULL,1,'2026-06-21 01:07:59.843345','Nhap kho may phat - Serial: 233. Ghi chu: Q','COMPLETED'),(6,1,3,3,'IMPORT','GENERATOR',7,NULL,1,'2026-06-21 11:15:13.840966','Nhap kho may phat - Serial: HJD_23','COMPLETED');
/*!40000 ALTER TABLE `inventory_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_repairs`
--

DROP TABLE IF EXISTS `maintenance_repairs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_repairs` (
  `repair_id` int NOT NULL AUTO_INCREMENT,
  `generator_id` int NOT NULL,
  `reported_by` int NOT NULL,
  `assigned_to` int DEFAULT NULL,
  `issue_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `repair_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `completed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`repair_id`),
  KEY `fk_maintenance_repairs_assigned_to` (`assigned_to`),
  KEY `fk_maintenance_repairs_generator_id` (`generator_id`),
  KEY `fk_maintenance_repairs_reported_by` (`reported_by`),
  CONSTRAINT `fk_maintenance_repairs_assigned_to` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_maintenance_repairs_generator_id` FOREIGN KEY (`generator_id`) REFERENCES `generators` (`generator_id`),
  CONSTRAINT `fk_maintenance_repairs_reported_by` FOREIGN KEY (`reported_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_repairs`
--

LOCK TABLES `maintenance_repairs` WRITE;
/*!40000 ALTER TABLE `maintenance_repairs` DISABLE KEYS */;
INSERT INTO `maintenance_repairs` VALUES (1,5,4,4,'Generator has abnormal engine noise','IN_PROGRESS','2026-05-21 20:34:09.703333',NULL),(2,4,5,5,'Scheduled maintenance for Honda generator','PENDING','2026-05-21 20:34:09.703333',NULL),(3,6,3,4,'Kiểm tra hệ thống dầu nhớt, nhiên liệu, đo điện áp và dòng tải ổn định trước khi đóng gói bàn giao cho khách thuê.','IN_PROGRESS','2026-06-21 16:24:05.938000',NULL),(4,1,3,5,'Kiểm tra hệ thống dầu nhớt, nhiên liệu, đo điện áp và dòng tải ổn định trước khi đóng gói bàn giao cho khách thuê.','IN_PROGRESS','2026-06-21 18:29:57.862924',NULL);
/*!40000 ALTER TABLE `maintenance_repairs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`notification_id`),
  KEY `fk_notifications_user_id` (`user_id`),
  CONSTRAINT `fk_notifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,2,'New Part Request Pending','Staff requested Spark Plug for Da Nang warehouse.','PART_REQUEST',0,'2026-05-21 20:34:09.706666'),(2,2,'New Purchase Request Pending','A purchase request is waiting for approval.','PURCHASE_REQUEST',0,'2026-05-21 20:34:09.706666'),(3,2,'Stock Transfer Pending','A stock transfer from Main Warehouse to Da Nang is waiting for approval.','STOCK_TRANSFER',0,'2026-05-21 20:34:09.706666'),(4,3,'Repair Task Assigned','Generator GEN-CUM-002 is under repair.','REPAIR',0,'2026-05-21 20:34:09.706666'),(5,4,'Part Request Created','Your part request has been created successfully.','PART_REQUEST',1,'2026-05-21 20:34:09.706666');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `part_requests`
--

DROP TABLE IF EXISTS `part_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `part_requests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `warehouse_id` int NOT NULL,
  `part_id` int NOT NULL,
  `requested_by` int NOT NULL,
  `approved_by` int DEFAULT NULL,
  `quantity` int NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `approved_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_part_requests_approved_by` (`approved_by`),
  KEY `fk_part_requests_part_id` (`part_id`),
  KEY `fk_part_requests_requested_by` (`requested_by`),
  KEY `fk_part_requests_warehouse_id` (`warehouse_id`),
  CONSTRAINT `fk_part_requests_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_part_requests_part_id` FOREIGN KEY (`part_id`) REFERENCES `parts` (`part_id`),
  CONSTRAINT `fk_part_requests_requested_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_part_requests_warehouse_id` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `part_requests`
--

LOCK TABLES `part_requests` WRITE;
/*!40000 ALTER TABLE `part_requests` DISABLE KEYS */;
INSERT INTO `part_requests` VALUES (1,2,4,4,NULL,10,'Spark Plug quantity is lower than minimum stock','PENDING','2026-05-21 20:34:09.703333',NULL),(2,3,5,5,2,5,'Need engine oil for maintenance','APPROVED','2026-05-21 20:34:09.703333','2026-05-21 20:34:09.703333');
/*!40000 ALTER TABLE `part_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parts`
--

DROP TABLE IF EXISTS `parts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parts` (
  `part_id` int NOT NULL AUTO_INCREMENT,
  `warehouse_id` int NOT NULL,
  `part_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `part_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT '0',
  `min_quantity` int DEFAULT '0',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `category_id` int DEFAULT NULL,
  `unit_id` int DEFAULT NULL,
  PRIMARY KEY (`part_id`),
  UNIQUE KEY `uq_parts_part_code` (`part_code`),
  KEY `fk_parts_warehouse_id` (`warehouse_id`),
  KEY `idx_parts_category_id` (`category_id`),
  KEY `idx_parts_unit_id` (`unit_id`),
  CONSTRAINT `fk_parts_categories` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`),
  CONSTRAINT `fk_parts_units` FOREIGN KEY (`unit_id`) REFERENCES `units` (`unit_id`),
  CONSTRAINT `fk_parts_warehouse_id` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parts`
--

LOCK TABLES `parts` WRITE;
/*!40000 ALTER TABLE `parts` DISABLE KEYS */;
INSERT INTO `parts` VALUES (1,1,'Oil Filter','PART-OF-001',20,5,'pcs','ACTIVE','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL),(2,1,'Fuel Filter','PART-FF-001',15,5,'pcs','ACTIVE','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL),(3,1,'Battery 12V','PART-BT-001',6,3,'pcs','ACTIVE','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL),(4,2,'Spark Plug','PART-SP-001',4,5,'pcs','ACTIVE','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL),(5,3,'Engine Oil 5L','PART-EO-001',10,4,'bottle','ACTIVE','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL);
/*!40000 ALTER TABLE `parts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `token_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expired_at` datetime(6) NOT NULL,
  `is_used` tinyint(1) DEFAULT '0',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`token_id`),
  KEY `fk_password_reset_tokens_user_id` (`user_id`),
  CONSTRAINT `fk_password_reset_tokens_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
INSERT INTO `password_reset_tokens` VALUES (1,1,'d9f377d4-1244-4d4b-8426-15888013fb41','2026-05-24 21:46:16.744000',0,'2026-05-24 20:46:16.770000'),(2,4,'99a39833-ce00-487b-a7f8-81549acef96c','2026-05-27 22:03:08.616000',0,'2026-05-27 21:03:08.626816');
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `permission_id` int NOT NULL AUTO_INCREMENT,
  `permission_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `permission_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `module_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`permission_id`),
  UNIQUE KEY `uq_permissions_permission_key` (`permission_key`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'MANAGE_USERS','Quản lý người dùng','Quản trị hệ thống','Cho phép tạo, sửa, khóa/mở khóa tài khoản người dùng.'),(2,'MANAGE_ROLES','Quản lý vai trò','Quản trị hệ thống','Cho phép tạo, sửa, kích hoạt/vô hiệu hóa các vai trò.'),(3,'MANAGE_PERMISSIONS','Phân quyền truy cập','Quản trị hệ thống','Cho phép phân quyền các tính năng cho từng vai trò.'),(4,'VIEW_ACTIVITY_LOGS','Xem nhật ký hoạt động','Quản trị hệ thống','Cho phép xem lịch sử thao tác của các thành viên.'),(5,'MANAGE_SETTINGS','Cài đặt hệ thống','Quản trị hệ thống','Cho phép cấu hình các cài đặt chung của hệ thống.'),(6,'MANAGE_WAREHOUSES','Quản lý kho','Quản lý kho','Cho phép thêm mới, cập nhật thông tin kho vật lý.'),(7,'MANAGE_SUPPLIERS','Quản lý nhà cung cấp','Quản lý kho','Cho phép thêm mới, cập nhật thông tin nhà cung cấp.'),(8,'MANAGE_GENERATORS','Quản lý máy phát điện','Quản lý kho','Cho phép thêm mới, cập nhật máy phát điện.'),(9,'MANAGE_PARTS','Quản lý phụ tùng','Quản lý kho','Cho phép thêm mới, cập nhật phụ tùng.'),(10,'VIEW_INVENTORY','Theo dõi tồn kho','Quản lý kho','Cho phép xem mức tồn kho hiện tại của máy và phụ tùng.'),(11,'INVENTORY_TRANSACTION','Nhập kho / Xuất kho','Quản lý kho','Cho phép thực hiện các thao tác nhập và xuất kho vật lý.'),(12,'CREATE_PART_REQUEST','Tạo yêu cầu phụ tùng','Yêu cầu & Mua hàng','Cho phép tạo yêu cầu linh kiện/phụ tùng để bảo trì.'),(13,'APPROVE_PART_REQUEST','Phê duyệt yêu cầu phụ tùng','Yêu cầu & Mua hàng','Cho phép xem xét và duyệt yêu cầu phụ tùng.'),(14,'CREATE_PURCHASE_REQUEST','Tạo yêu cầu mua hàng','Yêu cầu & Mua hàng','Cho phép tạo yêu cầu mua sắm máy phát/phụ tùng mới.'),(15,'APPROVE_PURCHASE_REQUEST','Phê duyệt yêu cầu mua hàng','Yêu cầu & Mua hàng','Cho phép duyệt yêu cầu mua sắm.'),(16,'MANAGE_PURCHASE_ORDERS','Quản lý đơn đặt hàng','Yêu cầu & Mua hàng','Cho phép tạo và theo dõi đơn đặt hàng (PO) gửi nhà cung cấp.'),(17,'CREATE_STOCK_TRANSFER','Tạo yêu cầu điều chuyển kho','Yêu cầu & Mua hàng','Cho phép tạo phiếu chuyển đổi hàng giữa các kho.'),(18,'APPROVE_STOCK_TRANSFER','Phê duyệt điều chuyển kho','Yêu cầu & Mua hàng','Cho phép xem xét và duyệt phiếu chuyển kho.'),(19,'CREATE_REPAIR_REQUEST','Tạo yêu cầu sửa chữa','Sửa chữa & Bảo trì','Cho phép báo cáo sự cố máy phát điện cần sửa chữa.'),(20,'ASSIGN_REPAIR_TASK','Phân công sửa chữa','Sửa chữa & Bảo trì','Cho phép phân công kỹ thuật viên phụ trách sửa chữa.'),(21,'UPDATE_REPAIR_PROGRESS','Cập nhật tiến độ sửa chữa','Sửa chữa & Bảo trì','Cho phép ghi nhận tiến độ, báo cáo hoàn thành sửa chữa.'),(22,'VIEW_REPORTS','Xem báo cáo hệ thống','Báo cáo','Cho phép xem báo cáo tồn kho, mua sắm và sửa chữa.'),(23,'VIEW_SUPPLIER_ORDERS','Xem đơn hàng của mình','Mua hàng & Cung cấp','Cho phép nhà cung cấp xem các đơn đặt hàng được giao.'),(24,'CONFIRM_SUPPLIER_ORDERS','Xác nhận đơn đặt hàng','Mua hàng & Cung cấp','Cho phép nhà cung cấp xác nhận tiếp nhận đơn đặt hàng.'),(25,'UPDATE_DELIVERY_STATUS','Cập nhật tiến độ giao hàng','Mua hàng & Cung cấp','Cho phép nhà cung cấp cập nhật trạng thái vận chuyển và giao hàng.');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_order_details`
--

DROP TABLE IF EXISTS `purchase_order_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_order_details` (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `purchase_order_id` int NOT NULL,
  `part_id` int DEFAULT NULL,
  `item_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`detail_id`),
  KEY `fk_purchase_order_details_part_id` (`part_id`),
  KEY `fk_purchase_order_details_purchase_order_id` (`purchase_order_id`),
  CONSTRAINT `fk_purchase_order_details_part_id` FOREIGN KEY (`part_id`) REFERENCES `parts` (`part_id`),
  CONSTRAINT `fk_purchase_order_details_purchase_order_id` FOREIGN KEY (`purchase_order_id`) REFERENCES `purchase_orders` (`purchase_order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_order_details`
--

LOCK TABLES `purchase_order_details` WRITE;
/*!40000 ALTER TABLE `purchase_order_details` DISABLE KEYS */;
INSERT INTO `purchase_order_details` VALUES (1,1,3,'Battery 12V',10,850000.00),(2,2,NULL,'Mitsubishi Generator 150KVA',1,250000000.00);
/*!40000 ALTER TABLE `purchase_order_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_orders` (
  `purchase_order_id` int NOT NULL AUTO_INCREMENT,
  `supplier_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `created_by` int NOT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `order_date` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`purchase_order_id`),
  KEY `fk_purchase_orders_created_by` (`created_by`),
  KEY `fk_purchase_orders_supplier_id` (`supplier_id`),
  KEY `fk_purchase_orders_warehouse_id` (`warehouse_id`),
  CONSTRAINT `fk_purchase_orders_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_purchase_orders_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`),
  CONSTRAINT `fk_purchase_orders_warehouse_id` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

LOCK TABLES `purchase_orders` WRITE;
/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
INSERT INTO `purchase_orders` VALUES (1,3,1,2,'PENDING','2026-05-21 20:34:09.703333','Order parts for main warehouse'),(2,2,1,2,'COMPLETED','2026-05-21 20:34:09.703333','Order generator from Mitsubishi supplier');
/*!40000 ALTER TABLE `purchase_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_request_details`
--

DROP TABLE IF EXISTS `purchase_request_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_request_details` (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `purchase_request_id` int NOT NULL,
  `part_id` int DEFAULT NULL,
  `item_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`detail_id`),
  KEY `fk_purchase_request_details_part_id` (`part_id`),
  KEY `fk_purchase_request_details_purchase_request_id` (`purchase_request_id`),
  CONSTRAINT `fk_purchase_request_details_part_id` FOREIGN KEY (`part_id`) REFERENCES `parts` (`part_id`),
  CONSTRAINT `fk_purchase_request_details_purchase_request_id` FOREIGN KEY (`purchase_request_id`) REFERENCES `purchase_requests` (`purchase_request_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_request_details`
--

LOCK TABLES `purchase_request_details` WRITE;
/*!40000 ALTER TABLE `purchase_request_details` DISABLE KEYS */;
INSERT INTO `purchase_request_details` VALUES (1,1,4,'Spark Plug',20),(2,2,3,'Battery 12V',10);
/*!40000 ALTER TABLE `purchase_request_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_requests`
--

DROP TABLE IF EXISTS `purchase_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_requests` (
  `purchase_request_id` int NOT NULL AUTO_INCREMENT,
  `warehouse_id` int NOT NULL,
  `requested_by` int NOT NULL,
  `approved_by` int DEFAULT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `approved_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`purchase_request_id`),
  KEY `fk_purchase_requests_approved_by` (`approved_by`),
  KEY `fk_purchase_requests_requested_by` (`requested_by`),
  KEY `fk_purchase_requests_warehouse_id` (`warehouse_id`),
  CONSTRAINT `fk_purchase_requests_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_purchase_requests_requested_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_purchase_requests_warehouse_id` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_requests`
--

LOCK TABLES `purchase_requests` WRITE;
/*!40000 ALTER TABLE `purchase_requests` DISABLE KEYS */;
INSERT INTO `purchase_requests` VALUES (1,2,4,NULL,'Need to buy more spark plugs for Da Nang warehouse','PENDING','2026-05-21 20:34:09.703333',NULL),(2,1,3,2,'Buy more batteries for main warehouse','APPROVED','2026-05-21 20:34:09.703333','2026-05-21 20:34:09.703333');
/*!40000 ALTER TABLE `purchase_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental_contract_details`
--

DROP TABLE IF EXISTS `rental_contract_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rental_contract_details` (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `rental_contract_id` int NOT NULL,
  `generator_id` int NOT NULL,
  `rental_price` decimal(15,2) DEFAULT '0.00',
  `note` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`detail_id`),
  KEY `rental_contract_id` (`rental_contract_id`),
  KEY `generator_id` (`generator_id`),
  CONSTRAINT `rental_contract_details_ibfk_1` FOREIGN KEY (`rental_contract_id`) REFERENCES `rental_contracts` (`rental_contract_id`),
  CONSTRAINT `rental_contract_details_ibfk_2` FOREIGN KEY (`generator_id`) REFERENCES `generators` (`generator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental_contract_details`
--

LOCK TABLES `rental_contract_details` WRITE;
/*!40000 ALTER TABLE `rental_contract_details` DISABLE KEYS */;
INSERT INTO `rental_contract_details` VALUES (1,1,6,3000000.00,'Seller rental request'),(2,2,1,100000.00,'Seller rental request');
/*!40000 ALTER TABLE `rental_contract_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rental_contracts`
--

DROP TABLE IF EXISTS `rental_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rental_contracts` (
  `rental_contract_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `created_by` int NOT NULL,
  `approved_by` int DEFAULT NULL,
  `contract_code` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` datetime NOT NULL,
  `expected_return_date` datetime NOT NULL,
  `actual_return_date` datetime DEFAULT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `deposit_amount` decimal(15,2) DEFAULT '0.00',
  `total_amount` decimal(15,2) DEFAULT '0.00',
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rental_contract_id`),
  UNIQUE KEY `contract_code` (`contract_code`),
  KEY `customer_id` (`customer_id`),
  KEY `warehouse_id` (`warehouse_id`),
  KEY `created_by` (`created_by`),
  KEY `approved_by` (`approved_by`),
  CONSTRAINT `rental_contracts_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `rental_contracts_ibfk_2` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`),
  CONSTRAINT `rental_contracts_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `rental_contracts_ibfk_4` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rental_contracts`
--

LOCK TABLES `rental_contracts` WRITE;
/*!40000 ALTER TABLE `rental_contracts` DISABLE KEYS */;
INSERT INTO `rental_contracts` VALUES (1,1,1,11,3,'CTR-SEL-1782032498096','2026-06-21 00:00:00','2026-06-27 00:00:00',NULL,'APPROVED',0.00,18000000.00,'Chị thảo HD thuê','2026-06-21 16:01:38','2026-06-21 16:34:29'),(2,1,1,11,3,'CTR-SEL-1782041351611','2026-06-22 00:00:00','2026-07-04 00:00:00',NULL,'APPROVED',0.00,1200000.00,'ok','2026-06-21 18:29:11','2026-06-21 18:30:15');
/*!40000 ALTER TABLE `rental_contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_exports`
--

DROP TABLE IF EXISTS `report_exports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_exports` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `created_by` int NOT NULL,
  `report_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`report_id`),
  KEY `fk_report_exports_created_by` (`created_by`),
  CONSTRAINT `fk_report_exports_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_exports`
--

LOCK TABLES `report_exports` WRITE;
/*!40000 ALTER TABLE `report_exports` DISABLE KEYS */;
INSERT INTO `report_exports` VALUES (1,2,'Inventory Report May 2026','INVENTORY','EXCEL','/reports/inventory_may_2026.xlsx','2026-05-21 20:34:09.706666'),(2,2,'Repair Report May 2026','REPAIR','PDF','/reports/repair_may_2026.pdf','2026-05-21 20:34:09.706666'),(3,1,'User List Report','USER','EXCEL','/reports/user_list.xlsx','2026-05-21 20:34:09.706666');
/*!40000 ALTER TABLE `report_exports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `fk_role_permissions_permission_id` (`permission_id`),
  CONSTRAINT `fk_role_permissions_permission_id` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`permission_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_permissions_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(3,6),(1,7),(3,7),(1,8),(3,8),(1,9),(3,9),(1,10),(2,10),(3,10),(4,10),(1,11),(3,11),(1,12),(4,12),(1,13),(2,13),(1,14),(3,14),(1,15),(2,15),(1,16),(2,16),(1,17),(3,17),(1,18),(2,18),(1,19),(4,19),(1,20),(2,20),(1,21),(4,21),(1,22),(2,22),(3,22),(1,23),(5,23),(1,24),(5,24),(1,25),(5,25);
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uq_roles_role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'ADMIN','System administrator','ACTIVE'),(2,'MANAGER','Manage all warehouses and approval flow','ACTIVE'),(3,'WAREHOUSE_MANAGER','Manage assigned warehouse','ACTIVE'),(4,'STAFF','Warehouse staff','ACTIVE'),(5,'SUPPLIER','','INACTIVE'),(7,'SELLER','Sales and Customer Relations Role','ACTIVE');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_transfer_details`
--

DROP TABLE IF EXISTS `stock_transfer_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_transfer_details` (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `transfer_id` int NOT NULL,
  `item_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `generator_id` int DEFAULT NULL,
  `part_id` int DEFAULT NULL,
  `quantity` int DEFAULT '1',
  PRIMARY KEY (`detail_id`),
  KEY `fk_stock_transfer_details_generator_id` (`generator_id`),
  KEY `fk_stock_transfer_details_part_id` (`part_id`),
  KEY `fk_stock_transfer_details_transfer_id` (`transfer_id`),
  CONSTRAINT `fk_stock_transfer_details_generator_id` FOREIGN KEY (`generator_id`) REFERENCES `generators` (`generator_id`),
  CONSTRAINT `fk_stock_transfer_details_part_id` FOREIGN KEY (`part_id`) REFERENCES `parts` (`part_id`),
  CONSTRAINT `fk_stock_transfer_details_transfer_id` FOREIGN KEY (`transfer_id`) REFERENCES `stock_transfers` (`transfer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_transfer_details`
--

LOCK TABLES `stock_transfer_details` WRITE;
/*!40000 ALTER TABLE `stock_transfer_details` DISABLE KEYS */;
INSERT INTO `stock_transfer_details` VALUES (1,1,'PART',NULL,1,5),(2,2,'GENERATOR',2,NULL,1);
/*!40000 ALTER TABLE `stock_transfer_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_transfers`
--

DROP TABLE IF EXISTS `stock_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_transfers` (
  `transfer_id` int NOT NULL AUTO_INCREMENT,
  `from_warehouse_id` int NOT NULL,
  `to_warehouse_id` int NOT NULL,
  `created_by` int NOT NULL,
  `approved_by` int DEFAULT NULL,
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `approved_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`transfer_id`),
  KEY `fk_stock_transfers_approved_by` (`approved_by`),
  KEY `fk_stock_transfers_created_by` (`created_by`),
  KEY `fk_stock_transfers_from_warehouse_id` (`from_warehouse_id`),
  KEY `fk_stock_transfers_to_warehouse_id` (`to_warehouse_id`),
  CONSTRAINT `fk_stock_transfers_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_stock_transfers_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_stock_transfers_from_warehouse_id` FOREIGN KEY (`from_warehouse_id`) REFERENCES `warehouses` (`warehouse_id`),
  CONSTRAINT `fk_stock_transfers_to_warehouse_id` FOREIGN KEY (`to_warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_transfers`
--

LOCK TABLES `stock_transfers` WRITE;
/*!40000 ALTER TABLE `stock_transfers` DISABLE KEYS */;
INSERT INTO `stock_transfers` VALUES (1,1,2,3,NULL,'PENDING','2026-05-21 20:34:09.703333',NULL),(2,1,3,2,2,'APPROVED','2026-05-21 20:34:09.703333','2026-05-21 20:34:09.703333');
/*!40000 ALTER TABLE `stock_transfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `supplier_id` int NOT NULL AUTO_INCREMENT,
  `supplier_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'Cummins Vietnam','0281111222','sales@cummins.vn','Ho Chi Minh City','ACTIVE','2026-05-21 20:34:09.700000'),(2,'Mitsubishi Power Supplier','0243333444','contact@mitsubishi.vn','Ha Noi','ACTIVE','2026-05-21 20:34:09.700000'),(3,'Generator Parts Co','0236555666','parts@generator.vn','Da Nang','ACTIVE','2026-05-21 20:34:09.700000');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `units` (
  `unit_id` int NOT NULL AUTO_INCREMENT,
  `unit_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`unit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `units`
--

LOCK TABLES `units` WRITE;
/*!40000 ALTER TABLE `units` DISABLE KEYS */;
INSERT INTO `units` VALUES (1,'Cai',NULL,'ACTIVE','2026-05-31 13:51:50','2026-05-31 13:51:50'),(2,'Day dien',NULL,'ACTIVE','2026-05-31 13:51:50','2026-05-31 13:51:50'),(3,'Cong suat',NULL,'ACTIVE','2026-05-31 13:51:50','2026-05-31 13:51:50'),(4,'Met',NULL,'ACTIVE','2026-05-31 13:51:50','2026-05-31 13:51:50'),(5,'Cuon',NULL,'ACTIVE','2026-05-31 13:51:50','2026-05-31 13:51:50'),(6,'Bo',NULL,'ACTIVE','2026-05-31 13:51:50','2026-05-31 13:51:50');
/*!40000 ALTER TABLE `units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `role_id` int NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `ResetToken` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ResetTokenExpiry` datetime DEFAULT NULL,
  `user_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'INTERNAL',
  `warehouse_id` int DEFAULT NULL,
  `can_import_generator` tinyint DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uq_users_username` (`username`),
  KEY `fk_users_role_id` (`role_id`),
  KEY `fk_users_warehouse_id` (`warehouse_id`),
  CONSTRAINT `fk_users_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`),
  CONSTRAINT `fk_users_warehouse_id` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,1,'System Admin','systemadmin@gmail.com','admin','123','0906923234','FPT University',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-05-24 20:54:13.180000',NULL,NULL,'INTERNAL',NULL,0),(2,2,'Nguyen Van Manager1','manager@gmail.com','manager','1','0900000002','Ha Noi',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-05-24 21:11:46.083333',NULL,NULL,'INTERNAL',NULL,0),(3,3,'Tran Thi Warehouse','warehouse.manager@gmail.com','warehousemanager','1','0900000003','Ha Noi',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL,'INTERNAL',NULL,0),(4,4,'Le Van Staff','levana@gmail.com','staff','1','0900000004','Ha Noi',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-06-21 00:54:25.000000',NULL,NULL,'INTERNAL',1,1),(5,4,'Pham Minh Staff','staff2@gmail.com','staff2','1','0900000005','Da Nang',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-06-21 18:20:48.000000',NULL,NULL,'INTERNAL',1,1),(7,3,'Quản Lý Hà Nội','hoalac@gmail.com','quanlyhoalac','Hung123456*','',NULL,NULL,'ACTIVE','2026-06-03 12:57:43.966764','2026-06-03 12:57:43.966764',NULL,NULL,'INTERNAL',NULL,0),(11,7,'SELLER 1','sale01@gmail.com','sale1','1','',NULL,NULL,'ACTIVE','2026-06-13 12:09:45.673634','2026-06-13 12:09:45.673634',NULL,NULL,'INTERNAL',1,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `warehouses`
--

DROP TABLE IF EXISTS `warehouses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouses` (
  `warehouse_id` int NOT NULL AUTO_INCREMENT,
  `warehouse_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manager_id` int DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `warehouse_manager_id` int DEFAULT NULL,
  PRIMARY KEY (`warehouse_id`),
  KEY `fk_warehouses_manager_id` (`manager_id`),
  KEY `fk_warehouses_warehouse_manager_id` (`warehouse_manager_id`),
  CONSTRAINT `fk_warehouses_manager_id` FOREIGN KEY (`manager_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_warehouses_warehouse_manager_id` FOREIGN KEY (`warehouse_manager_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `warehouses`
--

LOCK TABLES `warehouses` WRITE;
/*!40000 ALTER TABLE `warehouses` DISABLE KEYS */;
INSERT INTO `warehouses` VALUES (1,'Main Warehouse','Ha Noi',2,'ACTIVE','2026-05-21 20:34:09.700000',3),(2,'Da Nang Branch Warehouse','Da Nang',2,'ACTIVE','2026-05-21 20:34:09.700000',NULL),(3,'Ho Chi Minh Branch Warehouse','Ho Chi Minh City',2,'ACTIVE','2026-05-21 20:34:09.700000',NULL),(4,'Kho Chi Nhánh Hòa Lạc','Đường Nội Bộ 1',2,'ACTIVE','2026-06-03 12:58:18.840894',7);
/*!40000 ALTER TABLE `warehouses` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-21 21:07:17
