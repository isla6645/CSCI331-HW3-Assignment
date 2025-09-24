-- 1: Total number of invoices per customer
-- Counts invoices for each customer
SELECT i.CustomerID, c.CustomerName, COUNT(i.InvoiceID) AS InvoiceCount
FROM Sales.Invoices i
JOIN Sales.Customers c
  ON i.CustomerID = c.CustomerID
GROUP BY i.CustomerID, c.CustomerName
ORDER BY InvoiceCount DESC;

-- 2: Highest quantity sold per product
-- Maximum quantity sold in one invoice line for each product
SELECT il.StockItemID, si.StockItemName, MAX(il.Quantity) AS MaxQuantity
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si
  ON il.StockItemID = si.StockItemID
GROUP BY il.StockItemID, si.StockItemName
ORDER BY MaxQuantity DESC;

-- 3: Supplier transactions linked to purchase orders
-- Transaction amounts for purchase orders with supplier info
SELECT st.SupplierTransactionID, st.TransactionDate, st.TransactionAmount, po.PurchaseOrderID, s.SupplierName
FROM Purchasing.SupplierTransactions st
JOIN Purchasing.PurchaseOrders po
  ON st.PurchaseOrderID = po.PurchaseOrderID
JOIN Purchasing.Suppliers s
  ON st.SupplierID = s.SupplierID
ORDER BY st.TransactionDate;

-- 4: Customers with multiple orders
-- Customers with more than one order
SELECT o.CustomerID, c.CustomerName, COUNT(o.OrderID) AS NumOrders
FROM Sales.Orders o
JOIN Sales.Customers c
  ON o.CustomerID = c.CustomerID
GROUP BY o.CustomerID, c.CustomerName
HAVING COUNT(o.OrderID) > 1
ORDER BY NumOrders DESC;

-- 5: Top 3 most frequently ordered products
-- Products appearing most across all orders
SELECT ol.StockItemID, si.StockItemName, COUNT(*) AS TimesOrdered
FROM Sales.OrderLines ol
JOIN Warehouse.StockItems si
  ON ol.StockItemID = si.StockItemID
GROUP BY ol.StockItemID, si.StockItemName
ORDER BY TimesOrdered DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

-- 6: Customers without invoices
-- Customers with orders but no invoices
SELECT DISTINCT o.CustomerID, c.CustomerName
FROM Sales.Orders o
JOIN Sales.Customers c
  ON o.CustomerID = c.CustomerID
LEFT JOIN Sales.Invoices i
  ON o.OrderID = i.OrderID
WHERE i.InvoiceID IS NULL;

-- 7: Total stock value per supplier
-- Total stock value grouped by supplier
SELECT si.SupplierID, s.SupplierName, SUM(sih.QuantityOnHand * si.UnitPrice) AS TotalStockValue
FROM Warehouse.StockItems si
JOIN Warehouse.StockItemHoldings sih
  ON si.StockItemID = sih.StockItemID
JOIN Purchasing.Suppliers s
  ON si.SupplierID = s.SupplierID
GROUP BY si.SupplierID, s.SupplierName
ORDER BY TotalStockValue DESC;

-- 8: Average order quantity per customer
-- Average quantity per order for each customer
SELECT o.CustomerID, c.CustomerName, AVG(ol.Quantity) AS AvgQuantity
FROM Sales.Orders o
JOIN Sales.OrderLines ol
  ON o.OrderID = ol.OrderID
JOIN Sales.Customers c
  ON o.CustomerID = c.CustomerID
GROUP BY o.CustomerID, c.CustomerName
ORDER BY AvgQuantity DESC;

-- 9: Customers with invoices over a threshold
-- Customers with invoice totals over $10,000
SELECT i.CustomerID, c.CustomerName, SUM(il.Quantity * ISNULL(il.UnitPrice,0)) AS InvoiceTotal
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il
  ON i.InvoiceID = il.InvoiceID
JOIN Sales.Customers c
  ON i.CustomerID = c.CustomerID
GROUP BY i.CustomerID, c.CustomerName
HAVING SUM(il.Quantity * ISNULL(il.UnitPrice,0)) > 10000
ORDER BY InvoiceTotal DESC;

-- 10: Supplier orders by delivery method
-- Number of purchase orders per supplier per delivery method
SELECT po.SupplierID, s.SupplierName, po.DeliveryMethodID, COUNT(po.PurchaseOrderID) AS NumOrders
FROM Purchasing.PurchaseOrders po
JOIN Purchasing.Suppliers s
  ON po.SupplierID = s.SupplierID
GROUP BY po.SupplierID, s.SupplierName, po.DeliveryMethodID
ORDER BY NumOrders DESC;
