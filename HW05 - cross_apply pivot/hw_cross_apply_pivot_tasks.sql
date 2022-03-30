/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

-- напишите здесь свое решение

SELECT		CONVERT(nvarchar(10), [MonthDate], 104) AS [InvoiceMonth]
			,[Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Sylvanite, MT], [Jessie, ND]
FROM		(
				SELECT		DATEADD(d, 1 - DAY(i.[InvoiceDate]), i.[InvoiceDate]) AS [MonthDate]
							,SUBSTRING(c.[CustomerName], CHARINDEX('(', c.[CustomerName]) + 1, CHARINDEX(')', c.[CustomerName]) - CHARINDEX('(', c.[CustomerName]) - 1) AS [CustomerName]
							,i.[InvoiceID]
				FROM		[Sales].[Invoices] AS i
							INNER JOIN [Sales].[Customers] AS c
								ON c.[CustomerID] = i.[CustomerID]
				WHERE		i.[CustomerID] BETWEEN 2 AND 6
			) AS i
PIVOT
(
	COUNT([InvoiceID])
	FOR [CustomerName] IN ([Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Sylvanite, MT], [Jessie, ND])
) AS p
ORDER BY	[MonthDate]

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

-- напишите здесь свое решение

SELECT		[CustomerName], [AddressLine]
FROM		(
				SELECT		[CustomerName], [DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2]
				FROM		[Sales].[Customers]
				WHERE		[CustomerName] LIKE '%Tailspin Toys%'
			) AS c
UNPIVOT
(
	[AddressLine]
	FOR [AddressType] IN ([DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2])
) AS p

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

-- напишите здесь свое решение

SELECT		[CountryID], [CountryName], [Code]
FROM		(
				SELECT		[CountryID], [CountryName], [IsoAlpha3Code], CAST([IsoNumericCode] AS nvarchar(3)) AS [IsoNumericCode]
				FROM		[Application].[Countries]
			) AS c
UNPIVOT
(
	[Code]
	FOR [CodeType] IN ([IsoAlpha3Code], [IsoNumericCode])
) AS p

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

-- напишите здесь свое решение

-- две рандомных даты покупки 2-х товаров (возможны дубли) с наибольшей стоимостью

SELECT		c.[CustomerID], c.[CustomerName], u.[StockItemID], u.[UnitPrice], u.[InvoiceDate]
FROM		[Sales].[Customers] AS c
			CROSS APPLY (
				SELECT		TOP 2
							il.[StockItemID], il.[UnitPrice], i.[InvoiceDate]
				FROM		[Sales].[InvoiceLines] AS il
							INNER JOIN [Sales].[Invoices] AS i
								ON i.[InvoiceID] = il.[InvoiceID]
				WHERE		i.[CustomerID] = c.[CustomerID]
				ORDER BY	il.[UnitPrice] DESC
			) AS u

-- все даты покупки каждым клиентом 2-х самых дорогих для него товаров

SELECT		c.[CustomerID], c.[CustomerName], u.[StockItemID], u.[UnitPrice], i.[InvoiceDate]
FROM		[Sales].[Customers] AS c
			CROSS APPLY (
				SELECT		DISTINCT
							il.[StockItemID], il.[UnitPrice]
				FROM		[Sales].[InvoiceLines] AS il
							INNER JOIN [Sales].[Invoices] AS i
								ON i.[InvoiceID] = il.[InvoiceID]
				WHERE		i.[CustomerID] = c.[CustomerID]
				ORDER BY	il.[UnitPrice] DESC
							OFFSET 0 ROWS FETCH FIRST 2 ROWS ONLY
			) AS u
			INNER JOIN [Sales].[Invoices] AS i
				ON i.[CustomerID] = c.[CustomerID]
			INNER JOIN [Sales].[InvoiceLines] AS il
				ON il.[InvoiceID] = i.[InvoiceID]
				AND il.[StockItemID] = u.[StockItemID]
				AND il.[UnitPrice] = u.[UnitPrice]
ORDER BY	c.[CustomerID], u.[StockItemID]