/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

--TODO: напишите здесь свое решение
SELECT		[StockItemID]
			,[StockItemName]
FROM		[Warehouse].[StockItems]
WHERE		[StockItemName] LIKE '%urgent%'
			OR [StockItemName] LIKE 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

--TODO: напишите здесь свое решение
SELECT		s.[SupplierID]
			,s.[SupplierName]
FROM		[Purchasing].[Suppliers] AS s
			LEFT JOIN [Purchasing].[PurchaseOrders] AS o ON o.[SupplierID] = s.[SupplierID]
WHERE		o.[SupplierID] IS NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

--TODO: напишите здесь свое решение
DECLARE		@pagesize		int = 100
			,@pagenum		int = 11

SELECT		o.[OrderID]
			,CONVERT(nvarchar(10), o.[OrderDate], 104) AS [OrderDate]
			,DATENAME(MONTH, o.[OrderDate]) AS [MonthName]
			,DATEPART(QUARTER, o.[OrderDate]) AS [QuarterNumber]
			,CEILING(CAST(MONTH(o.[OrderDate]) AS float) * 3 / 12) AS [ThirdNumber]
			,c.[CustomerName]
FROM		[Sales].[Orders] AS o
			LEFT JOIN [Sales].[Customers] AS c ON c.[CustomerID] = o.[CustomerID]
WHERE		o.[OrderID] IN (SELECT DISTINCT [OrderID] FROM [Sales].[OrderLines] WHERE [PickingCompletedWhen] IS NOT NULL AND ([UnitPrice] > 100 OR [Quantity] > 20))
ORDER BY	DATEPART(QUARTER, o.[OrderDate]), CEILING(CAST(MONTH(o.[OrderDate]) AS float) * 3 / 12), o.[OrderDate]
			OFFSET (@pagenum - 1) * @pagesize ROWS FETCH FIRST @pagesize ROWS ONLY

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

--TODO: напишите здесь свое решение
SELECT		m.[DeliveryMethodName]
			,o.[ExpectedDeliveryDate]
			,s.[SupplierName]
			,p.[FullName]
FROM		[Purchasing].[PurchaseOrders] AS o
			LEFT JOIN [Purchasing].[Suppliers] AS s ON s.[SupplierID] = o.[SupplierID]
			LEFT JOIN [Application].[DeliveryMethods] AS m ON m.[DeliveryMethodID] = o.[DeliveryMethodID]
			LEFT JOIN [Application].[People] AS p ON p.[PersonID] = o.[ContactPersonID]
WHERE		YEAR(o.[ExpectedDeliveryDate]) = 2013
			AND MONTH(o.[ExpectedDeliveryDate]) = 1
			AND m.[DeliveryMethodName] IN ('Air Freight', 'Refrigerated Air Freight')
			AND o.[IsOrderFinalized] = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

--TODO: напишите здесь свое решение
SELECT		TOP(10)
			i.[InvoiceID]
			,c.[CustomerName]
			,p.[FullName]
FROM		[Sales].[Invoices] AS i
			LEFT JOIN [Sales].[Customers] AS c ON c.[CustomerID] = i.[CustomerID]
			LEFT JOIN [Application].[People] AS p ON p.[PersonID] = i.[SalespersonPersonID]
ORDER BY	i.[InvoiceDate] DESC

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

--TODO: напишите здесь свое решение
SELECT		DISTINCT
			c.[CustomerID]
			,c.[CustomerName]
			,c.[PhoneNumber]
FROM		[Sales].[Customers] AS c
			LEFT JOIN [Sales].[Invoices] AS i ON i.[CustomerID] = c.[CustomerID]
			LEFT JOIN [Sales].[InvoiceLines] AS l ON l.[InvoiceID] = i.[InvoiceID]
			LEFT JOIN [Warehouse].[StockItems] AS s ON s.[StockItemID] = l.[StockItemID]
WHERE		s.[StockItemName] = 'Chocolate frogs 250g'

/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

--TODO: напишите здесь свое решение
SELECT		YEAR(i.[InvoiceDate]) AS [InvoiceYear]
			,MONTH(i.[InvoiceDate]) AS [InvoiceMonth]
			,AVG(l.[UnitPrice]) AS [AvgPrice]
			,SUM(l.[UnitPrice] * l.[Quantity]) AS [SumInvoice]
FROM		[Sales].[Invoices] AS i
			LEFT JOIN [Sales].[InvoiceLines] AS l ON l.[InvoiceID] = i.[InvoiceID]
GROUP BY	YEAR(i.[InvoiceDate]), MONTH(i.[InvoiceDate])

/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

--TODO: напишите здесь свое решение
SELECT		YEAR(i.[InvoiceDate]) AS [InvoiceYear]
			,MONTH(i.[InvoiceDate]) AS [InvoiceMonth]
			,ISNULL(SUM(l.[UnitPrice] * l.[Quantity]), 0) AS [SumInvoice]
FROM		[Sales].[Invoices] AS i
			LEFT JOIN [Sales].[InvoiceLines] AS l ON l.[InvoiceID] = i.[InvoiceID]
GROUP BY	YEAR(i.[InvoiceDate]), MONTH(i.[InvoiceDate])
HAVING		SUM(l.[UnitPrice] * l.[Quantity]) > 10000

/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

--TODO: напишите здесь свое решение
SELECT		YEAR(i.[InvoiceDate]) AS [InvoiceYear]
			,MONTH(i.[InvoiceDate]) AS [InvoiceMonth]
			,s.[StockItemName]
			,SUM(l.[UnitPrice] * l.[Quantity]) AS [SumInvoice]
			,MIN(i.[InvoiceDate]) AS [FirstInvoiceDate]
			,SUM(l.[Quantity]) AS [QuantityUnit]
FROM		[Sales].[Invoices] AS i
			LEFT JOIN [Sales].[InvoiceLines] AS l ON l.[InvoiceID] = i.[InvoiceID]
			LEFT JOIN [Warehouse].[StockItems] AS s ON s.[StockItemID] = l.[StockItemID]
GROUP BY	YEAR(i.[InvoiceDate]), MONTH(i.[InvoiceDate]), s.[StockItemName]
HAVING		SUM(l.[Quantity]) < 50

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

--Опционально 8
DECLARE		@date_start		date
			,@date_end		date

SELECT		@date_start = MIN([InvoiceDate])
			,@date_end = MAX([InvoiceDate])
FROM		[Sales].[Invoices];

WITH [Calendar] AS (
	SELECT		@date_start AS [dt]
	UNION ALL
	SELECT		DATEADD(MONTH, 1, [dt])
	FROM		[Calendar]
	WHERE		[dt] <= @date_end
)
SELECT		YEAR(d.[dt]) AS [InvoiceYear]
			,MONTH(d.[dt]) AS [InvoiceMonth]
			,ISNULL(i.[SumInvoice], 0) AS [SumInvoice]
FROM		[Calendar] AS d
			LEFT JOIN (
				SELECT		YEAR(i.[InvoiceDate]) AS [InvoiceYear]
							,MONTH(i.[InvoiceDate]) AS [InvoiceMonth]
							,SUM(l.[UnitPrice] * l.[Quantity]) AS [SumInvoice]
				FROM		[Sales].[Invoices] AS i
							LEFT JOIN [Sales].[InvoiceLines] AS l ON l.[InvoiceID] = i.[InvoiceID]
				GROUP BY	YEAR(i.[InvoiceDate]), MONTH(i.[InvoiceDate])
				HAVING		SUM(l.[UnitPrice] * l.[Quantity]) > 10000
			) AS i ON i.[InvoiceYear] = YEAR(d.[dt]) AND i.[InvoiceMonth] = MONTH(d.[dt])

--Опционально 9
DECLARE		@date_start		date
			,@date_end		date

SELECT		@date_start = MIN([InvoiceDate])
			,@date_end = MAX([InvoiceDate])
FROM		[Sales].[Invoices];

WITH [Calendar] AS (
	SELECT		@date_start AS [dt]
	UNION ALL
	SELECT		DATEADD(MONTH, 1, [dt])
	FROM		[Calendar]
	WHERE		[dt] <= @date_end
)
SELECT		d.[InvoiceYear]
			,d.[InvoiceMonth]
			,d.[StockItemName]
			,ISNULL(i.[SumInvoice], 0) AS [SumInvoice]
			,i.[FirstInvoiceDate]
			,ISNULL(i.[QuantityUnit], 0) AS [QuantityUnit]
FROM		(
				SELECT		YEAR(d.[dt]) AS [InvoiceYear]
							,MONTH(d.[dt]) AS [InvoiceMonth]
							,u.[StockItemName]
				FROM		[Calendar] AS d, (SELECT [StockItemName] FROM [Warehouse].[StockItems]) AS u
			) AS d
			LEFT JOIN (
				SELECT		YEAR(i.[InvoiceDate]) AS [InvoiceYear]
							,MONTH(i.[InvoiceDate]) AS [InvoiceMonth]
							,s.[StockItemName]
							,SUM(l.[UnitPrice] * l.[Quantity]) AS [SumInvoice]
							,MIN(i.[InvoiceDate]) AS [FirstInvoiceDate]
							,SUM(l.[Quantity]) AS [QuantityUnit]
				FROM		[Sales].[Invoices] AS i
							LEFT JOIN [Sales].[InvoiceLines] AS l ON l.[InvoiceID] = i.[InvoiceID]
							LEFT JOIN [Warehouse].[StockItems] AS s ON s.[StockItemID] = l.[StockItemID]
				GROUP BY	YEAR(i.[InvoiceDate]), MONTH(i.[InvoiceDate]), s.[StockItemName]
				HAVING		SUM(l.[Quantity]) < 50
			) AS i ON i.[InvoiceYear] = d.[InvoiceYear] AND i.[InvoiceMonth] = d.[InvoiceMonth] AND i.[StockItemName] = d.[StockItemName]