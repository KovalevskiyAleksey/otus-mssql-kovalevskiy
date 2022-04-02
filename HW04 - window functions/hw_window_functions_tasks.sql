/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

-- напишите здесь свое решение

SET STATISTICS IO, TIME ON

SELECT		i.[InvoiceID]
			,c.[CustomerName]
			,i.[InvoiceDate]
			,SUM(il.[Quantity] * il.[UnitPrice]) AS [InvoiceSum]
			,(
				SELECT		SUM(sub_il.[Quantity] * sub_il.[UnitPrice])
				FROM		[Sales].[Invoices] AS sub_i
							INNER JOIN [Sales].[InvoiceLines] AS sub_il
								ON sub_il.[InvoiceID] = sub_i.[InvoiceID]
				WHERE		sub_i.[InvoiceDate] >= '20150101'
							AND MONTH(sub_i.[InvoiceDate]) <= MONTH(i.[InvoiceDate])
			) AS [RunningTotalByMonth]
FROM		[Sales].[Invoices] AS i
			INNER JOIN [Sales].[InvoiceLines] AS il
				ON il.[InvoiceID] = i.[InvoiceID]
			INNER JOIN [Sales].[Customers] AS c
				ON c.[CustomerID] = i.[CustomerID]
WHERE		i.[InvoiceDate] >= '20150101'
GROUP BY	i.[InvoiceID], c.[CustomerName], i.[InvoiceDate]

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

-- напишите здесь свое решение

SELECT		DISTINCT
			i.[InvoiceID]
			,c.[CustomerName]
			,i.[InvoiceDate]
			,SUM(il.[Quantity] * il.[UnitPrice]) OVER (PARTITION BY i.[InvoiceID], c.[CustomerName], i.[InvoiceDate] ORDER BY i.[InvoiceID]) AS [InvoiceSum]
			,SUM(il.[Quantity] * il.[UnitPrice]) OVER (ORDER BY MONTH(i.[InvoiceDate])) AS [RunningTotalByMonth]
FROM		[Sales].[Invoices] AS i
			INNER JOIN [Sales].[InvoiceLines] AS il
				ON il.[InvoiceID] = i.[InvoiceID]
			INNER JOIN [Sales].[Customers] AS c
				ON c.[CustomerID] = i.[CustomerID]
WHERE		i.[InvoiceDate] >= '20150101'

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

-- напишите здесь свое решение

SELECT		i.[MonthNum]
			,s.[StockItemName]
			,i.[QuantitySum]
FROM		(
				SELECT		MONTH(i.[InvoiceDate]) AS [MonthNum]
							,il.[StockItemID]
							,SUM(il.[Quantity]) AS [QuantitySum]
							,RANK() OVER (PARTITION BY MONTH(i.[InvoiceDate]) ORDER BY SUM(il.[Quantity]) DESC) AS [Rnk]
				FROM		[Sales].[InvoiceLines] AS il
							INNER JOIN [Sales].[Invoices] AS i
								ON i.[InvoiceID] = il.[InvoiceID]
				WHERE		i.[InvoiceDate] >= '20160101' AND i.[InvoiceDate] < '20170101'
				GROUP BY	il.[StockItemID], MONTH(i.[InvoiceDate])
			) AS i
			INNER JOIN [Warehouse].[StockItems] AS s
				ON s.[StockItemID] = i.[StockItemID]
WHERE		i.[Rnk] <= 2
ORDER BY	i.[MonthNum]

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

-- напишите здесь свое решение

SELECT		[StockItemID]
			,[StockItemName]
			,[Brand]
			,[UnitPrice]
			,ROW_NUMBER() OVER (PARTITION BY LEFT([StockItemName], 1) ORDER BY [StockItemName]) AS [RowNumberByAlhpabet]
			,COUNT([StockItemID]) OVER () AS [ItemCountTotal]
			,COUNT([StockItemID]) OVER (PARTITION BY LEFT([StockItemName], 1)) AS [ItemCountByAlhpabet]
			,LEAD([StockItemID]) OVER (ORDER BY [StockItemName]) AS [NextID]
			,LAG([StockItemID]) OVER (ORDER BY [StockItemName]) AS [PreviousID]
			,LAG([StockItemName], 2, 'No items') OVER (ORDER BY [StockItemName]) AS [PreviousItemLag2]
			,NTILE(30) OVER (ORDER BY [TypicalWeightPerUnit]) AS [GroupByWeight]
FROM		[Warehouse].[StockItems]

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

-- напишите здесь свое решение

SELECT		TOP(1) WITH TIES
			p.[PersonID]
			,RIGHT(RTRIM(p.[FullName]), CHARINDEX(' ', REVERSE(RTRIM(p.[FullName])) + ' ') - 1) AS [LastName]
			,c.[CustomerID]
			,c.[CustomerName]
			,i.[InvoiceDate]
			,SUM(il.[Quantity] * il.[UnitPrice]) AS [InvoiceSum]
FROM		[Application].[People] AS p
			LEFT JOIN [Sales].[Invoices] AS i
				ON i.[SalespersonPersonID] = p.[PersonID]
			LEFT JOIN [Sales].[InvoiceLines] AS il
				ON il.[InvoiceID] = i.[InvoiceID]
			LEFT JOIN [Sales].[Customers] AS c
				ON c.[CustomerID] = i.[CustomerID]
GROUP BY	p.[PersonID], RIGHT(RTRIM(p.[FullName]), CHARINDEX(' ', REVERSE(RTRIM(p.[FullName])) + ' ') - 1), c.[CustomerID], c.[CustomerName], i.[InvoiceDate]
ORDER BY	ROW_NUMBER() OVER (PARTITION BY p.[PersonID] ORDER BY i.[InvoiceDate] DESC)

-- Примечание: для отображения только тех сотрудников, которые что-то продавали, заменить LEFT JOIN на INNER JOIN, но по условию задачи требуется вывести данные по каждому сотруднику, поэтому LEFT JOIN

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

-- напишите здесь свое решение

SELECT		[CustomerID]
			,[CustomerName]
			,[StockItemID]
			,[UnitPrice]
			,[InvoiceDate]
FROM		(
				SELECT		DISTINCT
							c.[CustomerID]
							,c.[CustomerName]
							,il.[StockItemID]
							,il.[UnitPrice]
							,i.[InvoiceDate]
							,DENSE_RANK() OVER (PARTITION BY c.[CustomerID] ORDER BY il.[UnitPrice] DESC, il.[StockItemID]) AS [Rnk]
				FROM		[Sales].[Customers] AS c
							LEFT JOIN [Sales].[Invoices] AS i
								ON i.[CustomerID] = c.[CustomerID]
							LEFT JOIN [Sales].[InvoiceLines] AS il
								ON il.[InvoiceID] = i.[InvoiceID]
			) AS u
WHERE		[Rnk] <= 2

-- Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 