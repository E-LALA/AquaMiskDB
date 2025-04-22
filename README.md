# Maintenance and Inventory Management System for Aquamisk Water Filter Systems

This project provides a robust Maintenance and Inventory Management System implemented using SQL Server. It supports effective tracking of inventory, maintenance schedules, and customer relationships specifically tailored for Aquamisk Water Filter Systems. This README outlines the purpose, structure, features, and usage of the project.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Database Structure](#database-structure)
3. [Features](#features)
4. [Setup Instructions](#setup-instructions)
5. [Usage](#usage)
6. [Business Queries](#business-queries)
7. [Business Approach](#business-approach)
8. [Additional Enhancements](#additional-enhancements)

---

## Introduction

The system is designed to manage:

- Inventory of parts, including stock levels and pricing.
- Customer details and maintenance schedules.
- Employee assignments for maintenance activities.

This solution is tailored to the needs of Aquamisk Water Filter Systems, enabling streamlined processes to manage parts inventory and regular maintenance for their water filtration systems.

---

## Database Structure

The database includes the following tables:

1. **PartsInventory**:
   - Stores details about parts, including stock quantity and pricing.
2. **Customers**:
   - Manages customer information, such as address and installation dates.
3. **MobileNumbers**:
   - Records customer contact numbers.
4. **Employees**:
   - Stores employee contact details.
5. **Maintenance**:
   - Tracks maintenance schedules and associated employees.
6. **MaintenanceParts**:
   - Links maintenance activities with used parts and costs.

---

## Features

### Core Features

- **Inventory Management**: Track parts stock and alert on low inventory.
- **Customer Management**: Maintain customer information and contact numbers.
- **Maintenance Scheduling**: Plan and manage upcoming and recent maintenance activities.

### Advanced Features

- **Stored Procedures**:
  - Add new maintenance records with automated input validation.
- **Functions**:
  - Calculate average maintenance cost per customer.
  - Retrieve all customers with maintenance scheduled in the current month.
- **Triggers**:
  - Automatically update stock levels after part usage.
  - Alert on critically low stock levels.
- **Indexes**:
  - Optimized queries for faster performance.
- **Data Validation**:
  - Enforce business rules using constraints.

---

## Setup Instructions

1. **Prerequisites**:

   - SQL Server installed on your machine.
   - A database management tool such as SQL Server Management Studio (SSMS).

2. **Steps**:

   - Open the provided SQL script file in SSMS.
   - Execute the script to create the database, tables, stored procedures, triggers, and sample data.

---

## Usage

### Adding Maintenance Records

Use the `AddMaintenance` stored procedure to add new maintenance records:

```sql
EXEC AddMaintenance @CustomerCode=1, @RecentDate='2025-04-15', @UpcomingDate='2025-10-15', @Comment='Routine check-up', @EmployeeMobile='555-1234';
```

### Querying Data

- **Low Stock Parts**:
  ```sql
  SELECT PartID, PartName, StockQuantity FROM PartsInventory WHERE StockQuantity < 10;
  ```
- **Inventory Value**:
  ```sql
  SELECT SUM(StockQuantity * UnitPrice) AS TotalInventoryValue FROM PartsInventory;
  ```

### Maintenance Cost Analysis

Calculate the average maintenance cost per customer:

```sql
SELECT dbo.AverageMaintenanceCost(1) AS AverageCost;
```

### Customers with Maintenance This Month

Retrieve a list of all customers who have maintenance scheduled for the current month:

```sql
SELECT * FROM dbo.GetCustomersWithMaintenanceThisMonth();
```

---

## Business Queries

The system includes predefined queries to support business needs, such as:

- Identifying low stock parts.
- Tracking part usage trends.
- Scheduling and managing upcoming maintenance.
- Calculating inventory value and part costs.
- Retrieving customers with maintenance scheduled in the current month.

---

## Business Approach

This project addresses key business needs for Aquamisk Water Filter Systems by ensuring:

- **Operational Efficiency**:
  - Automates inventory tracking and alerts for low stock.
  - Schedules maintenance efficiently, reducing downtime for customers.

- **Cost Management**:
  - Tracks inventory costs and maintenance expenses to optimize resource allocation.
  - Provides detailed analytics on part usage and customer-specific maintenance costs.

- **Customer Satisfaction**:
  - Ensures timely maintenance for Aquamisk water filtration systems, fostering trust and long-term relationships.
  - Centralizes customer data, making it easier to provide personalized services.

- **Scalability**:
  - Designed to handle increasing data volume and support growing business operations.
  - Flexible structure to accommodate additional features or integrations.

---

## Additional Enhancements

### Recommendations

- **User Interface**: Integrate with a web or desktop application for better user experience.
- **Reporting**: Generate reports for inventory and maintenance statistics.
- **Security**: Implement role-based access to restrict certain database operations.
- **Backups**: Schedule automatic database backups to ensure data integrity.

---

## Conclusion

This project provides a comprehensive solution for maintenance and inventory management, supporting scalability and ease of use. For any questions or contributions, please feel free to contact the repository owner.

---

**Happy Maintaining!**

