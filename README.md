# walmart_sales_1
Walmart Data Analysis: End-to-End SQL + Python Project P-9
🧩 Project Overview

This project is an end-to-end data analysis solution designed to extract meaningful business insights from Walmart sales data.
Using Google Colab for Python analysis and MySQL for SQL querying, it demonstrates a complete workflow — from data cleaning and feature engineering to database integration and business problem-solving through SQL.

The project is ideal for aspiring data analysts who want hands-on experience with:

Data manipulation and preprocessing in Python

Writing analytical SQL queries

Building end-to-end data pipelines

⚙️ Project Steps
1. Load Walmart Sales Data in Google Colab

You can upload your dataset manually into Colab and load it into a Pandas DataFrame.

import pandas as pd
from google.colab import files

uploaded = files.upload()  # Upload your Walmart CSV file
data = pd.read_csv('Walmart.csv')
data.head()

2. Install and Import Required Libraries
!pip install pandas numpy sqlalchemy mysql-connector-python psycopg2

import pandas as pd
import numpy as np
from sqlalchemy import create_engine

3. Data Exploration

Explore and understand the dataset before cleaning.

data.info()
data.describe()
data.head()

4. Data Cleaning

Remove duplicates, fix data types, handle missing values, and format currency columns.

data.drop_duplicates(inplace=True)
data['Date'] = pd.to_datetime(data['Date'])
data['Unit price'] = data['Unit price'].replace('[\$,]', '', regex=True).astype(float)
data.isnull().sum()

5. Feature Engineering

Add a Total Amount column for better revenue analysis.

data['Total Amount'] = data['Unit price'] * data['Quantity']

6. Load Data into MySQL

Establish a connection between Google Colab and MySQL, and load the cleaned dataset.

from sqlalchemy import create_engine

engine = create_engine("mysql+mysqlconnector://username:password@host:port/database_name")

data.to_sql('walmart_sales', con=engine, if_exists='replace', index=False)


Verify upload:

pd.read_sql("SELECT COUNT(*) FROM walmart_sales", engine)

7. SQL Analysis — Business Insights

After loading the dataset into MySQL, execute the following SQL queries to extract insights.

🏪 1. Total Transactions per Branch
SELECT 
    branch,
    COUNT(invoice_id) AS total_transactions
FROM walmart_sales
GROUP BY branch
ORDER BY total_transactions DESC;

💰 2. Total Sales and Quantity by Payment Method
SELECT 
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_quantity_sold,
    SUM(total_amount) AS total_sales
FROM walmart_sales
GROUP BY payment_method
ORDER BY total_sales DESC;

⭐ 3. Highest-Rated Product Category in Each Branch
SELECT 
    branch,
    category,
    ROUND(AVG(rating), 2) AS avg_rating,
    RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank_within_branch
FROM walmart_sales
GROUP BY branch, category
ORDER BY branch, avg_rating DESC;

📅 4. Busiest Day (Highest Number of Transactions) per Branch
SELECT 
    branch,
    DATE(date) AS day,
    COUNT(invoice_id) AS total_transactions,
    RANK() OVER (PARTITION BY branch ORDER BY COUNT(invoice_id) DESC) AS rank_within_branch
FROM walmart_sales
GROUP BY branch, DATE(date)
ORDER BY branch, total_transactions DESC;

🏆 5. Top 3 Product Categories by Quantity Sold
WITH category_sales AS (
    SELECT 
        category,
        SUM(quantity) AS total_quantity,
        RANK() OVER (ORDER BY SUM(quantity) DESC) AS category_rank
    FROM walmart_sales
    GROUP BY category
)
SELECT * FROM category_sales
WHERE category_rank <= 3;

💹 6. Profit Margin by Branch and Category
SELECT 
    branch,
    category,
    SUM(total_amount - (unit_cost * quantity)) AS total_profit,
    ROUND(SUM(total_amount - (unit_cost * quantity)) / SUM(total_amount) * 100, 2) AS profit_margin_percent
FROM walmart_sales
GROUP BY branch, category
ORDER BY total_profit DESC;

8. Project Publishing and Documentation

All stages — from cleaning and transformation in Colab to SQL-based analysis — are documented.
You can export the Colab notebook as .ipynb or .html and include it in your GitHub repo along with this README.

🧰 Requirements

Python 3.8+

Google Colab

SQL Databases: MySQL, PostgreSQL

Python Libraries:

pandas, numpy, sqlalchemy, mysql-connector-python, psycopg2

🚀 Getting Started

Open Google Colab.

Upload your Walmart CSV file.

Run the data cleaning and feature engineering steps.

Connect Colab to MySQL using SQLAlchemy.

Execute SQL queries for business insights.

📂 Project Structure
|-- data/                     # Raw and cleaned data files
|-- sql_queries/              # SQL scripts for analysis
|-- notebooks/                # Google Colab notebooks
|-- README.md                 # Project documentation
|-- requirements.txt          # Required Python libraries

📊 Results and Insights

Sales Insights

Branches with the highest total sales

Most preferred payment method among customers

Profitability

Most profitable branches and product categories

Customer Behavior

Peak sales days and busiest shopping periods

Product categories with top customer ratings

🔮 Future Enhancements

Integrate MySQL data with Power BI or Tableau for dynamic dashboards

Automate data ingestion and analysis via Colab pipelines

Extend to real-time streaming analysis

📜 License

This project is licensed under the MIT License.

🙌 Acknowledgments

Data Source: Kaggle — Walmart Sales Dataset

Inspiration: Walmart’s data-driven decision-making and retail case studies
