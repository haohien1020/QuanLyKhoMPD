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
  `action` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `table_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `record_id` int DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
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
  `category_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
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
  `type_code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
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
  `customer_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'ABC Factory','0922000001','customer@gmail.com','Dong Nai','ACTIVE','2026-05-31 21:40:00','2026-05-31 21:40:00');
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
  `generator_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `serial_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `brand` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `power_value` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fuel_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin_type` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'SUPPLIER',
  `import_date` datetime(6) DEFAULT NULL,
  `purchase_price` decimal(15,2) DEFAULT NULL,
  `location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'IN_STOCK',
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `category_id` int DEFAULT NULL,
  PRIMARY KEY (`generator_id`),
  UNIQUE KEY `uq_generators_serial_number` (`serial_number`),
  KEY `fk_generators_supplier_id` (`supplier_id`),
  KEY `fk_generators_warehouse_id` (`warehouse_id`),
  KEY `idx_generators_category_id` (`category_id`),
  CONSTRAINT `fk_generators_categories` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`),
  CONSTRAINT `fk_generators_supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`),
  CONSTRAINT `fk_generators_warehouse_id` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generators`
--

LOCK TABLES `generators` WRITE;
/*!40000 ALTER TABLE `generators` DISABLE KEYS */;
INSERT INTO `generators` VALUES (1,1,1,'Cummins Generator 100KVA','GEN-CUM-001','Cummins','100KVA','Diesel','SUPPLIER','2026-05-01 09:00:00.000000',180000000.00,'A1-01','IN_STOCK','Imported from Cummins Vietnam','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL),(2,1,2,'Mitsubishi Generator 150KVA','GEN-MIT-001','Mitsubishi','150KVA','Diesel','SUPPLIER','2026-05-03 10:00:00.000000',250000000.00,'A1-02','IN_STOCK','Imported from Mitsubishi Power Supplier','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL),(3,2,NULL,'Denyo Generator 80KVA','GEN-DEN-001','Denyo','80KVA','Diesel','TRANSFER','2026-05-06 14:00:00.000000',120000000.00,'B1-01','IN_STOCK','Transferred from Main Warehouse','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL),(4,3,NULL,'Honda Generator 30KVA','GEN-HON-001','Honda','30KVA','Gasoline','TRANSFER','2026-05-08 15:30:00.000000',45000000.00,'C1-01','MAINTENANCE','Transferred from Main Warehouse','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL),(5,1,1,'Cummins Generator 200KVA','GEN-CUM-002','Cummins','200KVA','Gasoline','SUPPLIER','2026-05-10 00:00:00.000000',320000000.00,'A2-01','UNDER_REPAIR','Imported from Cummins Vietnam','2026-05-21 20:34:09.700000','2026-05-25 21:11:43.480000',NULL);
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
  `transaction_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `generator_id` int DEFAULT NULL,
  `part_id` int DEFAULT NULL,
  `quantity` int DEFAULT '1',
  `transaction_date` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `note` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'COMPLETED',
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transactions`
--

LOCK TABLES `inventory_transactions` WRITE;
/*!40000 ALTER TABLE `inventory_transactions` DISABLE KEYS */;
INSERT INTO `inventory_transactions` VALUES (1,1,1,2,'IMPORT','GENERATOR',1,NULL,1,'2026-05-21 20:34:09.703333','Import Cummins generator from supplier','COMPLETED'),(2,1,2,2,'IMPORT','GENERATOR',2,NULL,1,'2026-05-21 20:34:09.703333','Import Mitsubishi generator from supplier','COMPLETED'),(3,1,3,3,'IMPORT','PART',NULL,1,20,'2026-05-21 20:34:09.703333','Import oil filters','COMPLETED'),(4,1,NULL,4,'EXPORT','PART',NULL,2,3,'2026-05-21 20:34:09.703333','Used fuel filters for maintenance','COMPLETED');
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
  `issue_description` text COLLATE utf8mb4_unicode_ci,
  `repair_status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `completed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`repair_id`),
  KEY `fk_maintenance_repairs_assigned_to` (`assigned_to`),
  KEY `fk_maintenance_repairs_generator_id` (`generator_id`),
  KEY `fk_maintenance_repairs_reported_by` (`reported_by`),
  CONSTRAINT `fk_maintenance_repairs_assigned_to` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_maintenance_repairs_generator_id` FOREIGN KEY (`generator_id`) REFERENCES `generators` (`generator_id`),
  CONSTRAINT `fk_maintenance_repairs_reported_by` FOREIGN KEY (`reported_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_repairs`
--

LOCK TABLES `maintenance_repairs` WRITE;
/*!40000 ALTER TABLE `maintenance_repairs` DISABLE KEYS */;
INSERT INTO `maintenance_repairs` VALUES (1,5,4,4,'Generator has abnormal engine noise','IN_PROGRESS','2026-05-21 20:34:09.703333',NULL),(2,4,5,5,'Scheduled maintenance for Honda generator','PENDING','2026-05-21 20:34:09.703333',NULL);
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
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `reason` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
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
  `part_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `part_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` int DEFAULT '0',
  `min_quantity` int DEFAULT '0',
  `unit` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
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
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `permission_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permission_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `module_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`permission_id`),
  UNIQUE KEY `uq_permissions_permission_key` (`permission_key`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'MANAGE_USERS','Quản lý người dùng','Quản trị hệ thống','Cho phép tạo, sửa, khóa/mở khóa tài khoản người dùng.'),(2,'MANAGE_ROLES','Quản lý vai trò','Quản trị hệ thống','Cho phép tạo, sửa, kích hoạt/vô hiệu hóa các vai trò.'),(3,'MANAGE_PERMISSIONS','Phân quyền truy cập','Quản trị hệ thống','Cho phép phân quyền các tính năng cho từng vai trò.'),(4,'VIEW_ACTIVITY_LOGS','Xem nhật ký hoạt động','Quản trị hệ thống','Cho phép xem lịch sử thao tác của các thành viên.'),(5,'MANAGE_SETTINGS','Cài đặt hệ thống','Quản trị hệ thống','Cho phép cấu hình các cài đặt chung của hệ thống.'),(6,'MANAGE_WAREHOUSES','Quản lý kho','Quản lý kho','Cho phép thêm mới, cập nhật thông tin kho vật lý.'),(7,'MANAGE_SUPPLIERS','Quản lý nhà cung cấp','Quản lý kho','Cho phép thêm mới, cập nhật thông tin nhà cung cấp.'),(8,'MANAGE_GENERATORS','Quản lý máy phát điện','Quản lý kho','Cho phép thêm mới, cập nhật máy phát điện.'),(9,'MANAGE_PARTS','Quản lý phụ tùng','Quản lý kho','Cho phép thêm mới, cập nhật phụ tùng.'),(10,'VIEW_INVENTORY','Theo dõi tồn kho','Quản lý kho','Cho phép xem mức tồn kho hiện tại của máy và phụ tùng.'),(11,'INVENTORY_TRANSACTION','Nhập kho / Xuất kho','Quản lý kho','Cho phép thực hiện các thao tác nhập và xuất kho vật lý.'),(12,'CREATE_PART_REQUEST','Tạo yêu cầu phụ tùng','Yêu cầu & Mua hàng','Cho phép tạo yêu cầu linh kiện/phụ tùng để bảo trì.'),(13,'APPROVE_PART_REQUEST','Phê duyệt yêu cầu phụ tùng','Yêu cầu & Mua hàng','Cho phép xem xét và duyệt yêu cầu phụ tùng.'),(14,'CREATE_PURCHASE_REQUEST','Tạo yêu cầu mua hàng','Yêu cầu & Mua hàng','Cho phép tạo yêu cầu mua sắm máy phát/phụ tùng mới.'),(15,'APPROVE_PURCHASE_REQUEST','Phê duyệt yêu cầu mua hàng','Yêu cầu & Mua hàng','Cho phép duyệt yêu cầu mua sắm.'),(16,'MANAGE_PURCHASE_ORDERS','Quản lý đơn đặt hàng','Yêu cầu & Mua hàng','Cho phép tạo và theo dõi đơn đặt hàng (PO) gửi nhà cung cấp.'),(17,'CREATE_STOCK_TRANSFER','Tạo yêu cầu điều chuyển kho','Yêu cầu & Mua hàng','Cho phép tạo phiếu chuyển đổi hàng giữa các kho.'),(18,'APPROVE_STOCK_TRANSFER','Phê duyệt điều chuyển kho','Yêu cầu & Mua hàng','Cho phép xem xét và duyệt phiếu chuyển kho.'),(19,'CREATE_REPAIR_REQUEST','Tạo yêu cầu sửa chữa','Sửa chữa & Bảo trì','Cho phép báo cáo sự cố máy phát điện cần sửa chữa.'),(20,'ASSIGN_REPAIR_TASK','Phân công sửa chữa','Sửa chữa & Bảo trì','Cho phép phân công kỹ thuật viên phụ trách sửa chữa.'),(21,'UPDATE_REPAIR_PROGRESS','Cập nhật tiến độ sửa chữa','Sửa chữa & Bảo trì','Cho phép ghi nhận tiến độ, báo cáo hoàn thành sửa chữa.'),(22,'VIEW_REPORTS','Xem báo cáo hệ thống','Báo cáo','Cho phép xem báo cáo tồn kho, mua sắm và sửa chữa.');
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
  `item_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `order_date` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `note` text COLLATE utf8mb4_unicode_ci,
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
  `item_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `reason` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
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
-- Table structure for table `report_exports`
--

DROP TABLE IF EXISTS `report_exports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_exports` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `created_by` int NOT NULL,
  `report_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
INSERT INTO `role_permissions` VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(3,6),(1,7),(3,7),(1,8),(3,8),(1,9),(3,9),(1,10),(2,10),(3,10),(4,10),(1,11),(3,11),(1,12),(4,12),(1,13),(2,13),(1,14),(3,14),(1,15),(2,15),(1,16),(2,16),(1,17),(3,17),(1,18),(2,18),(1,19),(4,19),(1,20),(2,20),(1,21),(4,21),(1,22),(2,22),(3,22);
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
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uq_roles_role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'ADMIN','System administrator','ACTIVE'),(2,'MANAGER','Manage all warehouses and approval flow','ACTIVE'),(3,'WAREHOUSE_MANAGER','Manage assigned warehouse','ACTIVE'),(4,'STAFF','Warehouse staff','ACTIVE'),(5,'SUPPLIER','','ACTIVE'),(6,'CUSTOMER','Customer rental portal account','ACTIVE');
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
  `item_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `status` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
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
  `supplier_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
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
  `unit_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
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
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  `ResetToken` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ResetTokenExpiry` datetime DEFAULT NULL,
  `user_type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'INTERNAL',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uq_users_username` (`username`),
  KEY `fk_users_role_id` (`role_id`),
  CONSTRAINT `fk_users_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,1,'System Admin','systemadmin@gmail.com','admin','123','0906923234','FPT University',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-05-24 20:54:13.180000',NULL,NULL,'INTERNAL'),(2,2,'Nguyen Van Manager1','manager@gmail.com','manager','1','0900000002','Ha Noi',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-05-24 21:11:46.083333',NULL,NULL,'INTERNAL'),(3,3,'Tran Thi Warehouse','warehouse.manager@gmail.com','warehousemanager','1','0900000003','Ha Noi',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL,'INTERNAL'),(4,4,'Le Van Staff','levana@gmail.com','staff','1','0900000004','Ha Noi',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL,'INTERNAL'),(5,4,'Pham Minh Staff','staff2@gmail.com','staff2','1','0900000005','Da Nang',NULL,'ACTIVE','2026-05-21 20:34:09.700000','2026-05-21 20:34:09.700000',NULL,NULL,'INTERNAL'),(6,6,'ABC Factory Customer','customer@gmail.com','customer','1','0922000001','Dong Nai',NULL,'ACTIVE','2026-05-31 21:40:00.000000','2026-05-31 21:40:00.000000',NULL,NULL,'CUSTOMER');
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
  `warehouse_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manager_id` int DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'ACTIVE',
  `created_at` datetime(6) DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`warehouse_id`),
  KEY `fk_warehouses_manager_id` (`manager_id`),
  CONSTRAINT `fk_warehouses_manager_id` FOREIGN KEY (`manager_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `warehouses`
--

LOCK TABLES `warehouses` WRITE;
/*!40000 ALTER TABLE `warehouses` DISABLE KEYS */;
INSERT INTO `warehouses` VALUES (1,'Main Warehouse','Ha Noi',3,'ACTIVE','2026-05-21 20:34:09.700000'),(2,'Da Nang Branch Warehouse','Da Nang',3,'ACTIVE','2026-05-21 20:34:09.700000'),(3,'Ho Chi Minh Branch Warehouse','Ho Chi Minh City',3,'ACTIVE','2026-05-21 20:34:09.700000');
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

-- Dump completed on 2026-05-31 21:28:37
