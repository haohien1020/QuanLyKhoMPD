ALTER TABLE swp391_generator_management.users
ADD COLUMN `ResetToken` VARCHAR(255) NULL,
ADD COLUMN `ResetTokenExpiry` DATETIME NULL;