/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

-- напишите здесь свое решение

INSERT		[Sales].[Customers]
(
	[CustomerName]
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
)
SELECT		TOP(5)
			'NEW_' + [CustomerName]
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
FROM		[Sales].[Customers]

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

-- напишите здесь свое решение

DELETE		TOP(1)
FROM		[Sales].[Customers]
WHERE		[CustomerName] LIKE 'NEW_%'

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

-- напишите здесь свое решение

UPDATE		[Sales].[Customers]
SET			[CustomerName] += '_UPDATED'
WHERE		[CustomerID] = (SELECT MAX([CustomerID]) FROM [Sales].[Customers] WHERE [CustomerName] LIKE 'NEW_%')

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

-- напишите здесь свое решение

;WITH [SourceCTE]
(
	[CustomerName]
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
)
AS
(
	SELECT		TOP(1)
				[CustomerName]
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
	FROM		[Sales].[Customers]
	WHERE		[CustomerName] LIKE 'NEW_%'
	UNION ALL
	SELECT		TOP(1)
				'NEW2_' + [CustomerName]
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
	FROM		[Sales].[Customers]
)
MERGE		[Sales].[Customers] AS TARGET
USING		(
				SELECT		[CustomerName]
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
				FROM		[SourceCTE]
			) AS SOURCE
				ON SOURCE.[CustomerName] = TARGET.[CustomerName]
WHEN		MATCHED
			AND TARGET.[ValidFrom] != getdate()
	THEN		UPDATE
				SET			[CustomerName] += '_UPDATE_BY_MERGE'
WHEN		NOT MATCHED
	THEN		INSERT
				(
					[CustomerName]
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
				)
				VALUES
				(
					SOURCE.[CustomerName]
					,SOURCE.[BillToCustomerID]
					,SOURCE.[CustomerCategoryID]
					,SOURCE.[BuyingGroupID]
					,SOURCE.[PrimaryContactPersonID]
					,SOURCE.[AlternateContactPersonID]
					,SOURCE.[DeliveryMethodID]
					,SOURCE.[DeliveryCityID]
					,SOURCE.[PostalCityID]
					,SOURCE.[CreditLimit]
					,SOURCE.[AccountOpenedDate]
					,SOURCE.[StandardDiscountPercentage]
					,SOURCE.[IsStatementSent]
					,SOURCE.[IsOnCreditHold]
					,SOURCE.[PaymentDays]
					,SOURCE.[PhoneNumber]
					,SOURCE.[FaxNumber]
					,SOURCE.[DeliveryRun]
					,SOURCE.[RunPosition]
					,SOURCE.[WebsiteURL]
					,SOURCE.[DeliveryAddressLine1]
					,SOURCE.[DeliveryAddressLine2]
					,SOURCE.[DeliveryPostalCode]
					,SOURCE.[DeliveryLocation]
					,SOURCE.[PostalAddressLine1]
					,SOURCE.[PostalAddressLine2]
					,SOURCE.[PostalPostalCode]
					,SOURCE.[LastEditedBy]
				)
OUTPUT		deleted.[CustomerID]
			,$action
			,deleted.[CustomerName] AS [OLD_CustomerName]
			,inserted.[CustomerName] AS [NEW_CustomerName];

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

-- напишите здесь свое решение

-- экспорт через bcp

DECLARE		@table_name		nvarchar(100) =		QUOTENAME('WideWorldImporters') + '.' + QUOTENAME('Sales') + '.' + QUOTENAME('Customers')
			,@table_new		nvarchar(100)
			,@file_path		nvarchar(200) =		'D:\'
			,@file_name		nvarchar(100) =		'Customers_' + CONVERT(nvarchar(8), getdate(), 112) + REPLACE(CONVERT(nvarchar(12), getdate(), 114), ':', '') + '.csv'
			,@delimiter		nvarchar(10) =		'||'
			,@query			nvarchar(1000)

SET			@query =		'bcp "' + @table_name + '" out "' + @file_path + @file_name + '" -T -w -t"' + @delimiter + '" -S ' + @@SERVERNAME
EXEC master..xp_cmdshell @query

-- импорт через BULK INSERT

SET			@table_new =	QUOTENAME('WideWorldImporters') + '.' + QUOTENAME('Sales') + '.' + QUOTENAME(SUBSTRING(@file_name, 1, CHARINDEX('.', @file_name) - 1))
SET			@query =		'DROP TABLE IF EXISTS ' + @table_new + '
							SELECT		TOP(0) *
							INTO		' + @table_new + '
							FROM		' + @table_name + '

							BULK INSERT	' + @table_new + '
							FROM		"' + @file_path + @file_name + '"
										WITH
										(
											DATAFILETYPE = ''widechar''
											,FIRSTROW = 1
											,FIELDTERMINATOR = ''' + @delimiter + '''
											,ROWTERMINATOR = ''\n''
											,KEEPNULLS
											,TABLOCK
										)'
EXEC (@query)

-- выборка для проверки импорта и удаление таблицы

SET			@query =		'SELECT * FROM ' + @table_new + '
							DROP TABLE IF EXISTS ' + @table_new
EXEC (@query)

-- удаление файла

SET			@query =		'xp_cmdshell ''del "' + @file_path + @file_name + '"'''
EXEC (@query)