/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

-- TODO: напишите здесь свое решение

-- 1) через вложенный запрос
SELECT		[PersonID]
			,[FullName]
FROM		[Application].[People]
WHERE		[IsSalesperson] = 1
			AND [PersonID] NOT IN (SELECT [SalespersonPersonID] FROM [Sales].[Invoices] WHERE [InvoiceDate] = '20150704')

-- 2) через WITH
;WITH [InvoicesCTE] ([SalespersonPersonID])
AS
(
	SELECT		[SalespersonPersonID]
	FROM		[Sales].[Invoices]
	WHERE		[InvoiceDate] = '20150704'
)
SELECT		p.[PersonID]
			,p.[FullName]
FROM		[Application].[People] AS p
			LEFT JOIN [InvoicesCTE] AS i
				ON i.[SalespersonPersonID] = p.[PersonID]
WHERE		p.[IsSalesperson] = 1
			AND i.[SalespersonPersonID] IS NULL

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

-- TODO: напишите здесь свое решение

-- 1) через вложенный запрос
SELECT		[StockItemID]
			,[StockItemName]
			,[UnitPrice]
FROM		[Warehouse].[StockItems]
WHERE		[UnitPrice] = (SELECT MIN([UnitPrice]) FROM [Warehouse].[StockItems])

-- 1.1) через вложенный запрос
SELECT		i.[StockItemID]
			,i.[StockItemName]
			,i.[UnitPrice]
FROM		[Warehouse].[StockItems] AS i
			RIGHT JOIN (
				SELECT		MIN([UnitPrice]) AS [MinUnitPrice]
				FROM		[Warehouse].[StockItems]
			) AS p
				ON p.[MinUnitPrice] = i.[UnitPrice]

-- 2) через WITH
;WITH [MinUnitPriceCTE] ([UnitPrice])
AS
(
	SELECT		MIN([UnitPrice]) AS [MinUnitPrice]
	FROM		[Warehouse].[StockItems]
)
SELECT		i.[StockItemID]
			,i.[StockItemName]
			,i.[UnitPrice]
FROM		[Warehouse].[StockItems] AS i
			RIGHT JOIN [MinUnitPriceCTE] AS p
				ON p.[UnitPrice] = i.[UnitPrice]

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

-- TODO: напишите здесь свое решение

-- 1) через вложенный запрос (без платежей)
SELECT		[CustomerID]
			,[CustomerName]
			,[BillToCustomerID]
			,[CustomerCategoryID]
			,[BuyingGroupID]
			,[PrimaryContactPersonID]
			,[AlternateContactPersonID]
			,[DeliveryMethodID]
			,[DeliveryCityID]
			,[PostalCityID]
			,[CreditLimit]
			,[AccountOpenedDate]
			,[StandardDiscountPercentage]
			,[IsStatementSent]
			,[IsOnCreditHold]
			,[PaymentDays]
			,[PhoneNumber]
			,[FaxNumber]
			,[DeliveryRun]
			,[RunPosition]
			,[WebsiteURL]
			,[DeliveryAddressLine1]
			,[DeliveryAddressLine2]
			,[DeliveryPostalCode]
			,[DeliveryLocation]
			,[PostalAddressLine1]
			,[PostalAddressLine2]
			,[PostalPostalCode]
			,[LastEditedBy]
			,[ValidFrom]
			,[ValidTo]
FROM		[Sales].[Customers]
WHERE		[CustomerID] IN (
				SELECT		TOP 5
							[CustomerID]
				FROM		[Sales].[CustomerTransactions]
				WHERE		[TransactionTypeID] = 3
				ORDER BY	[TransactionAmount]
			)

-- 1.1) через вложенный запрос (с платежами)
SELECT		t.[TransactionAmount]
			,t.[CustomerID]
			,[CustomerName]
			,[BillToCustomerID]
			,[CustomerCategoryID]
			,[BuyingGroupID]
			,[PrimaryContactPersonID]
			,[AlternateContactPersonID]
			,[DeliveryMethodID]
			,[DeliveryCityID]
			,[PostalCityID]
			,[CreditLimit]
			,[AccountOpenedDate]
			,[StandardDiscountPercentage]
			,[IsStatementSent]
			,[IsOnCreditHold]
			,[PaymentDays]
			,[PhoneNumber]
			,[FaxNumber]
			,[DeliveryRun]
			,[RunPosition]
			,[WebsiteURL]
			,[DeliveryAddressLine1]
			,[DeliveryAddressLine2]
			,[DeliveryPostalCode]
			,[DeliveryLocation]
			,[PostalAddressLine1]
			,[PostalAddressLine2]
			,[PostalPostalCode]
			,[LastEditedBy]
			,[ValidFrom]
			,[ValidTo]
FROM		(
				SELECT		TOP 5
							[CustomerID], [TransactionAmount]
				FROM		[Sales].[CustomerTransactions]
				WHERE		[TransactionTypeID] = 3
				ORDER BY	[TransactionAmount]
			) AS t
			LEFT JOIN [Sales].[Customers] AS c
				ON c.[CustomerID] = t.[CustomerID]

-- 1.2) через вложенный запрос (с платежами)
SELECT		t.[TransactionAmount]
			,c.[CustomerID]
			,[CustomerName]
			,[BillToCustomerID]
			,[CustomerCategoryID]
			,[BuyingGroupID]
			,[PrimaryContactPersonID]
			,[AlternateContactPersonID]
			,[DeliveryMethodID]
			,[DeliveryCityID]
			,[PostalCityID]
			,[CreditLimit]
			,[AccountOpenedDate]
			,[StandardDiscountPercentage]
			,[IsStatementSent]
			,[IsOnCreditHold]
			,[PaymentDays]
			,[PhoneNumber]
			,[FaxNumber]
			,[DeliveryRun]
			,[RunPosition]
			,[WebsiteURL]
			,[DeliveryAddressLine1]
			,[DeliveryAddressLine2]
			,[DeliveryPostalCode]
			,[DeliveryLocation]
			,[PostalAddressLine1]
			,[PostalAddressLine2]
			,[PostalPostalCode]
			,c.[LastEditedBy]
			,[ValidFrom]
			,[ValidTo]
FROM		[Sales].[Customers] AS c
			RIGHT JOIN [Sales].[CustomerTransactions] AS t
				ON t.[CustomerID] = c.[CustomerID]
				AND t.[TransactionTypeID] = 3
WHERE		t.[TransactionAmount] < (
				SELECT		[TransactionAmount]
				FROM		[Sales].[CustomerTransactions]
				WHERE		[TransactionTypeID] = 3
				ORDER BY	[TransactionAmount]
							OFFSET 5 ROWS FETCH FIRST 1 ROWS ONLY
			)

-- 2) через WITH (без платежей)
;WITH [TopCustomerCTE] ([CustomerID])
AS
(
	SELECT		TOP 5
				[CustomerID]
	FROM		[Sales].[CustomerTransactions]
	WHERE		[TransactionTypeID] = 3
	ORDER BY	[TransactionAmount]
)
SELECT		t.[CustomerID]
			,[CustomerName]
			,[BillToCustomerID]
			,[CustomerCategoryID]
			,[BuyingGroupID]
			,[PrimaryContactPersonID]
			,[AlternateContactPersonID]
			,[DeliveryMethodID]
			,[DeliveryCityID]
			,[PostalCityID]
			,[CreditLimit]
			,[AccountOpenedDate]
			,[StandardDiscountPercentage]
			,[IsStatementSent]
			,[IsOnCreditHold]
			,[PaymentDays]
			,[PhoneNumber]
			,[FaxNumber]
			,[DeliveryRun]
			,[RunPosition]
			,[WebsiteURL]
			,[DeliveryAddressLine1]
			,[DeliveryAddressLine2]
			,[DeliveryPostalCode]
			,[DeliveryLocation]
			,[PostalAddressLine1]
			,[PostalAddressLine2]
			,[PostalPostalCode]
			,[LastEditedBy]
			,[ValidFrom]
			,[ValidTo]
FROM		(SELECT DISTINCT [CustomerID] FROM [TopCustomerCTE]) AS t
			LEFT JOIN [Sales].[Customers] AS c
				ON c.[CustomerID] = t.[CustomerID]

-- 2.1) через WITH (с платежами)
;WITH [TopCustomerCTE] ([CustomerID], [TransactionAmount])
AS
(
	SELECT		TOP 5
				[CustomerID], [TransactionAmount]
	FROM		[Sales].[CustomerTransactions]
	WHERE		[TransactionTypeID] = 3
	ORDER BY	[TransactionAmount]
)
SELECT		t.[TransactionAmount]
			,t.[CustomerID]
			,[CustomerName]
			,[BillToCustomerID]
			,[CustomerCategoryID]
			,[BuyingGroupID]
			,[PrimaryContactPersonID]
			,[AlternateContactPersonID]
			,[DeliveryMethodID]
			,[DeliveryCityID]
			,[PostalCityID]
			,[CreditLimit]
			,[AccountOpenedDate]
			,[StandardDiscountPercentage]
			,[IsStatementSent]
			,[IsOnCreditHold]
			,[PaymentDays]
			,[PhoneNumber]
			,[FaxNumber]
			,[DeliveryRun]
			,[RunPosition]
			,[WebsiteURL]
			,[DeliveryAddressLine1]
			,[DeliveryAddressLine2]
			,[DeliveryPostalCode]
			,[DeliveryLocation]
			,[PostalAddressLine1]
			,[PostalAddressLine2]
			,[PostalPostalCode]
			,[LastEditedBy]
			,[ValidFrom]
			,[ValidTo]
FROM		[TopCustomerCTE] AS t
			LEFT JOIN [Sales].[Customers] AS c
				ON c.[CustomerID] = t.[CustomerID]

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

-- TODO: напишите здесь свое решение

-- 1) через вложенный запрос
SELECT		DISTINCT
			c.[DeliveryCityID]
			,d.[CityName]
			,p.[FullName]
FROM		[Sales].[Invoices] AS i
			INNER JOIN [Sales].[InvoiceLines] AS l
				ON l.[InvoiceID] = i.[InvoiceID]
			INNER JOIN [Sales].[Customers] AS c
				ON c.[CustomerID] = i.[CustomerID]
			INNER JOIN [Application].[Cities] AS d
				ON d.[CityID] = c.[DeliveryCityID]
			INNER JOIN [Application].[People] AS p
				ON p.[PersonID] = i.[PackedByPersonID]
WHERE		i.[ConfirmedDeliveryTime] IS NOT NULL
			AND l.[StockItemID] IN (
				SELECT		TOP 3
							[StockItemID]
				FROM		[Warehouse].[StockItems]
				ORDER BY	[UnitPrice] DESC
			)

-- 2) через WITH
;WITH [InvoiceByUnitCTE] ([InvoiceID])
AS
(
	SELECT		[InvoiceID]
	FROM		[Sales].[InvoiceLines]
	WHERE		[StockItemID] IN (
					SELECT		TOP 3
								[StockItemID]
					FROM		[Warehouse].[StockItems]
					ORDER BY	[UnitPrice] DESC
				)
)
,[InvoiceCTE] ([DeliveryCityID], [PackedByPersonID])
AS
(
	SELECT		c.[DeliveryCityID]
				,i.[PackedByPersonID]
	FROM		[Sales].[Invoices] AS i
				LEFT JOIN [Sales].[Customers] AS c
					ON c.[CustomerID] = i.[CustomerID]
	WHERE		i.[InvoiceID] IN (SELECT [InvoiceID] FROM [InvoiceByUnitCTE])
				AND i.[ConfirmedDeliveryTime] IS NOT NULL
)
SELECT		i.[DeliveryCityID]
			,c.[CityName]
			,p.[FullName]
FROM		[InvoiceCTE] AS i
			LEFT JOIN [Application].[Cities] AS c
				ON c.[CityID] = i.[DeliveryCityID]
			LEFT JOIN [Application].[People] AS p
				ON p.[PersonID] = i.[PackedByPersonID]


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

-- TODO: напишите здесь свое решение

/*
Запрос возвращает суммы фактических продаж с соответствующими им суммами завершённых заказов для сумм продаж более 27 000.
*/

-- 1) через вложенный запрос
SELECT		i.[InvoiceID]
			,i.[InvoiceDate]
			,p.[FullName] AS [SalesPersonName]
			,il.[TotalSummByInvoice]
			,o.[TotalSummForPickedItems]
FROM		(
				SELECT		[InvoiceID]
							,SUM([Quantity] * [UnitPrice]) AS [TotalSummByInvoice]
				FROM		[Sales].[InvoiceLines]
				GROUP BY	[InvoiceID]
				HAVING		SUM([Quantity] * [UnitPrice]) > 27000
			) AS il
			INNER JOIN [Sales].[Invoices] AS i
				ON i.[InvoiceID] = il.[InvoiceID]
			LEFT JOIN (
				SELECT		o.[OrderID]
							,SUM(ol.[PickedQuantity] * ol.[UnitPrice]) AS [TotalSummForPickedItems]
				FROM		[Sales].[Orders] AS o
							INNER JOIN [Sales].[OrderLines] AS ol
								ON ol.[OrderID] = o.[OrderID]
				WHERE		o.[PickingCompletedWhen] IS NOT NULL
				GROUP BY	o.[OrderID]
			) AS o
				ON o.[OrderID] = i.[OrderID]
			INNER JOIN [Application].[People] AS p
				ON p.[PersonID] = i.[SalespersonPersonID]
ORDER BY	il.[TotalSummByInvoice] DESC

-- 2) через WITH
;WITH [InvoiceCTE] ([InvoiceID], [OrderID], [InvoiceDate], [SalespersonPersonID], [TotalSummByInvoice])
AS
(
	SELECT		i.[InvoiceID]
				,i.[OrderID]
				,i.[InvoiceDate]
				,i.[SalespersonPersonID]
				,SUM(il.[Quantity] * il.[UnitPrice]) AS [TotalSummByInvoice]
	FROM		[Sales].[Invoices] AS i
				INNER JOIN [Sales].[InvoiceLines] AS il
					ON il.[InvoiceID] = i.[InvoiceID]
	GROUP BY	i.[InvoiceID], i.[OrderID], i.[InvoiceDate], i.[SalespersonPersonID]
	HAVING		SUM(il.[Quantity] * il.[UnitPrice]) > 27000
)
SELECT		i.[InvoiceID]
			,i.[InvoiceDate]
			,p.[FullName] AS [SalesPersonName]
			,i.[TotalSummByInvoice]
			,SUM(ol.[PickedQuantity] * ol.[UnitPrice]) AS [TotalSummForPickedItems]
FROM		[InvoiceCTE] AS i
			LEFT JOIN [Sales].[Orders] AS o
				ON o.[OrderID] = i.[OrderID] AND o.[PickingCompletedWhen] IS NOT NULL
			LEFT JOIN [Sales].[OrderLines] AS ol
				ON ol.[OrderID] = o.[OrderID]
			INNER JOIN [Application].[People] AS p
				ON p.[PersonID] = i.[SalespersonPersonID]
GROUP BY	i.[InvoiceID], i.[InvoiceDate], p.[FullName], i.[TotalSummByInvoice]
ORDER BY	i.[TotalSummByInvoice] DESC

/*
Сокращение количества чтений за счёт размещения всех подзапросов в джойнах.
Дополнительным средством оптимизации могли бы послужить индексы с INCLUDE.
*/