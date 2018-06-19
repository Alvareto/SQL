-- ako u instanci SQL Servera veæ postoji baza labprof2, obrišite ju prije izvršavanja
-- sljedeæih naredbi ili koristite neko drugo ime baze
-- USE master;
-- GO
-- DROP DATABASE IF EXISTS labprof2;

CREATE DATABASE labprof2;
GO

USE labprof2;
GO


DROP TABLE IF EXISTS salesOrder2Item;
CREATE TABLE salesOrder2Item (
         salesOrder2ID INTEGER NOT NULL
       , salesOrder2ItemID INTEGER NOT NULL
       , orderQty INTEGER NOT NULL
       , productID INTEGER NOT NULL
       , specialOfferID INTEGER NOT NULL
       , unitPrice DECIMAL(10,2) NOT NULL
       , unitPriceDiscount DECIMAL(10,2) NOT NULL
);


DROP TABLE IF EXISTS salesOrder2;
CREATE TABLE salesOrder2 (
         salesOrder2ID    INTEGER NOT NULL
       , revisionNumber  INTEGER NOT NULL
       , orderDate       DATETIME NOT NULL
       , dueDate         DATETIME NOT NULL
       , shipDate        DATETIME
       , status          INTEGER NOT NULL
       , customerID      INTEGER NOT NULL
       , salesPersonID   INTEGER
       , territoryID     INTEGER
       , comment         CHAR(128)
);



-- prije izvršavanja podesiti put do datoteka
BULK INSERT salesOrder2 FROM 'C:\temp\salesOrder2.csv' WITH (FIELDTERMINATOR = ';', KEEPNULLS);
BULK INSERT salesOrder2Item FROM 'C:\temp\salesOrder2Item.csv' WITH (FIELDTERMINATOR = ';', KEEPNULLS);

USE [labprof2]

GO

DROP TABLE IF EXISTS salesOrder2;
CREATE TABLE salesOrder2 (
         salesOrderID    INTEGER NOT NULL
       , revisionNumber  INTEGER NOT NULL
       , orderDate       DATETIME NOT NULL
       , dueDate         DATETIME NOT NULL
       , shipDate        DATETIME
       , status          INTEGER NOT NULL
       , customerID      INTEGER NOT NULL
       , salesPersonID   INTEGER
       , territoryID     INTEGER
       , comment         CHAR(128)
);

-- 2 zadatak - utjecaj indexa na INSERT & DELETE

SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '1_INSERT';
INSERT INTO salesOrder2
SELECT * FROM salesOrder;
GO
--
SET STATISTICS TIME OFF;

SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '1_DELETE';
DELETE FROM salesOrder2;
GO
--
SET STATISTICS TIME OFF;

CREATE INDEX [CIndex-FIRSTONE] ON [dbo].[salesOrder2]
(
	[orderDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

CREATE INDEX [CIndex-SECONDONE] ON [dbo].[salesOrder2]
(
	[dueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '2_INSERT';
INSERT INTO salesOrder2
SELECT * FROM salesOrder;
GO
--
SET STATISTICS TIME OFF;

SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '2_DELETE';
DELETE FROM salesOrder2;
GO
--
SET STATISTICS TIME OFF;

CREATE INDEX [CCIndex-THIRDONE] ON [dbo].[salesOrder2]
(
	[shipDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

CREATE INDEX [CCIndex-FOURTHONE] ON [dbo].[salesOrder2]
(
	[customerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)


SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '3_INSERT';
INSERT INTO salesOrder2
SELECT * FROM salesOrder;
GO
--
SET STATISTICS TIME OFF;

SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '3_DELETE';
DELETE FROM salesOrder2;
GO
--
SET STATISTICS TIME OFF;

DROP INDEX IF EXISTS [CIndex-FIRSTONE] on [dbo].[salesOrder2]
DROP INDEX IF EXISTS [CIndex-SECONDONE] on [dbo].[salesOrder2]
DROP INDEX IF EXISTS [CCIndex-THIRDONE] on [dbo].[salesOrder2]
DROP INDEX IF EXISTS [CCIndex-FOURTHONE] on [dbo].[salesOrder2]
GO

 3 zadatak- update time with and without index & update time with and without reverse index


relacija [salesOrder]([customerID], [territoryID]), za atribut [customerID] je kreiran indeks
SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '4_UPDATE_0';
UPDATE salesOrder SET [territoryID]=1 WHERE [customerID]=11105
GO
--
SET STATISTICS TIME OFF;

CREATE INDEX [CCIndex-UPDATEONE] ON [dbo].[salesOrder]
(
	[customerID] ASC
	--, [territoryID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);

SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '4_UPDATE_1';
UPDATE salesOrder SET [territoryID]=1 WHERE [customerID]=11105
GO
--
SET STATISTICS TIME OFF;
-- nema troška održavanja indeksa, dobar odabir

-- reset data
DROP INDEX IF EXISTS [CCIndex-UPDATEONE] on [dbo].[salesOrder];
DELETE FROM salesOrder;
BULK INSERT salesOrder FROM 'C:\temp\salesOrder.csv' WITH (FIELDTERMINATOR = ';', KEEPNULLS);
GO

SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '5_UPDATE_0';
UPDATE salesOrder SET [customerID]=11105 WHERE [territoryID]=1
GO
--
SET STATISTICS TIME OFF;

CREATE INDEX [CCIndex-UPDATETWO] ON [dbo].[salesOrder]
(
	[customerID] ASC
	--, [territoryID] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);

SET STATISTICS TIME ON;
-- SQL naredba čije se CPU vrijeme mjeri; -- ispisat će se vrijeme izvršavanja ove naredbe
PRINT '5_UPDATE_1';
UPDATE salesOrder SET [customerID]=11105 WHERE [territoryID]=1
GO
--
SET STATISTICS TIME OFF;
-- indeks ne donosi dobitak, postoji samo trošak održavanja indeksa, loš odabir

-- reset data
DROP INDEX IF EXISTS [CCIndex-UPDATETWO] on [dbo].[salesOrder];
DELETE FROM salesOrder;
BULK INSERT salesOrder FROM 'C:\temp\salesOrder.csv' WITH (FIELDTERMINATOR = ';', KEEPNULLS);
GO


DROP TABLE IF EXISTS salesOrderItem2;
CREATE TABLE salesOrderItem2 (
         salesOrderID INTEGER NOT NULL
       , salesOrderItemID INTEGER NOT NULL
       , orderQty INTEGER NOT NULL
       , productID INTEGER NOT NULL
       , specialOfferID INTEGER NOT NULL
       , unitPrice DECIMAL(10,2) NOT NULL
       , unitPriceDiscount DECIMAL(10,2) NOT NULL
);

INSERT INTO salesOrderItem2
SELECT TOP(100000) * FROM salesOrderItem;
GO

CREATE INDEX [CCIndex-FOURTHONE] ON [dbo].salesOrderItem2
(
	[productID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100)
GO
SET STATISTICS TIME ON;
PRINT '4_INSERT_a';
INSERT INTO salesOrderItem2
SELECT TOP(100000) * FROM salesOrderItem;
GO
--
SET STATISTICS TIME OFF;

DROP INDEX IF EXISTS [CCIndex-FOURTHONE] on [dbo].salesOrderItem2;
