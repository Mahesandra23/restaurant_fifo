# Restaurant Ordering & Inventory Management

A restaurant food ordering application integrated with **FIFO-based order management** and a **SAW-based inventory restock recommendation system**.

This project was developed as a final thesis project to support restaurant operations by organizing kitchen order queues and providing data-driven recommendations for inventory replenishment.

## Features

### 🍽️ Food Ordering

* Browse available food and beverage menus.
* Create and manage food orders.
* Store order data in a structured database.
* Track the status of submitted orders.

### 🔄 FIFO Order Management

The kitchen order queue uses the **First In, First Out (FIFO)** principle to prioritize orders based on their arrival time.

* Orders are processed according to their creation time.
* Earlier orders are prioritized over newer orders.
* Kitchen staff can manage order statuses:

  * **Pending**
  * **Cooking**
  * **Completed**

### 📦 Inventory Management

The application provides inventory management features to help monitor restaurant ingredients and stock levels.

* Manage ingredient data and stock quantities.
* Monitor current stock levels.
* Configure **Reorder Point (ROP)** values.
* View ingredient classifications based on:

  * **ABC** — Consumption Value
  * **HML** — Price
  * **SDE** — Availability
  * **FSN** — Stock Movement

### 📊 SAW Restock Recommendation

The application implements the **Simple Additive Weighting (SAW)** method as a Decision Support System (DSS) for inventory restocking.

The system:

1. Collects ingredient and inventory data.
2. Evaluates ingredients based on predefined criteria.
3. Normalizes the criterion values.
4. Applies configurable criterion weights.
5. Calculates the final preference score.
6. Ranks ingredients based on their scores.
7. Provides restock priority recommendations.

### ⚙️ Priority Weight Settings

Users can configure the importance of each SAW criterion through the **Priority Weight Settings** feature.

This allows the restock recommendation to be adjusted according to the restaurant's inventory management priorities.

### 📍 Reorder Point (ROP)

The application also supports **Reorder Point (ROP)** management to identify when an ingredient's stock level reaches the point where replenishment should be considered.

ROP and safety stock values can be configured manually based on the restaurant's inventory requirements.

## User Roles

The application consists of two main user roles:

### 👤 Customer

Customers can:

* Browse the available menu.
* Select food and beverages.
* Place orders.
* View their order information.
* Track order status.

### 👨‍🍳 Kitchen / Admin

Kitchen or Admin users can:

* View incoming orders.
* Process orders according to the FIFO queue.
* Update order statuses.
* Manage ingredient and inventory data.
* Configure reorder point values.
* View SAW-based restock recommendations.
* Adjust criterion weights for the recommendation system.

## FIFO Implementation

FIFO is implemented to maintain the order in which kitchen orders are processed.

Orders are retrieved from the database based on their `created_at` value in ascending order. This ensures that older orders are positioned before newer orders in the kitchen queue.

The application also uses a **circular FIFO array** to manage the active kitchen queue efficiently.

## SAW Implementation

The **Simple Additive Weighting (SAW)** method is used to calculate the priority of ingredients that require restocking.

The general process consists of:

```text
Ingredient Data
      ↓
Criterion Evaluation
      ↓
Value Normalization
      ↓
Weight Assignment
      ↓
SAW Calculation
      ↓
Preference Score
      ↓
Restock Priority Ranking
```

The resulting ranking helps identify which ingredients should receive higher restocking priority.

## Technology Stack

| Category             | Technology         |
| -------------------- | ------------------ |
| Framework            | Flutter            |
| Programming Language | Dart               |
| Backend              | Supabase           |
| Database             | PostgreSQL         |
| Architecture         | MVVM               |
| State Management     | Provider           |
| SDK Management       | FVM                |
| UI Utilities         | Flutter ScreenUtil |
| Typography           | Google Fonts       |
| Version Control      | Git & GitHub       |

## Architecture

The application follows the **Model-View-ViewModel (MVVM)** architecture to separate the user interface, application logic, and data-related responsibilities.

```text
View
 │
 ▼
ViewModel
 │
 ▼
Model / Repository
 │
 ▼
Supabase
 │
 ▼
PostgreSQL Database
```

This structure helps maintain a more organized and scalable codebase.

## Project Objective

The main objectives of this project are to:

* Develop a restaurant food ordering application.
* Implement FIFO-based kitchen order management.
* Develop an inventory management system.
* Implement a Decision Support System using the SAW method.
* Provide restock priority recommendations based on multiple inventory criteria.
* Support restaurant staff in managing orders and inventory more systematically.

## Project Context

This application was developed as a **Bachelor's thesis project** in Informatics at **Universitas Multimedia Nusantara**.

The project combines mobile application development, database management, order queue management, inventory management, and multi-criteria decision-making into a single restaurant management solution.
