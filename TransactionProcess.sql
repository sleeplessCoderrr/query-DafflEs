USE DafflEsHotel

--1
SELECT 
REPLACE(CustomerID, 'CU', CONCAT(SUBSTRING(CustomerName, 1, 1), SUBSTRING(CustomerName, CHARINDEX(' ', CustomerName) + 1, 1))) AS [ID],
CustomerName AS [Name], CustomerAddress AS [Address]
FROM MsCustomer
WHERE CustomerGender LIKE 'Male'

--2
SELECT HotelID, HotelAddress, HotelEmail
FROM MsHotel
WHERE HotelAddress LIKE '%de%'

--3
BEGIN TRAN
UPDATE MsService
SET ServicePrice = ServicePrice + (ServicePrice * 0.15)
WHERE ServicePrice <  50000

SELECT *
FROM MsService
WHERE ServicePrice < 50000

ROLLBACK

--4
SELECT
mc.CustomerID AS [Customer ID], 
LEFT(mc.CustomerName, CHARINDEX(' ', CustomerName) - 1) AS [First Name], 
SUBSTRING(mc.CustomerName, LEN(mc.CustomerName) - CHARINDEX(' ', REVERSE(mc.CustomerName)) + 2, LEN(mc.CustomerName)) AS [Last Name],
FORMAT(SUM((rd.RoomPrice * DATEDIFF(DAY, th.CheckInDate, th.CheckOutDate))), 'C0', 'id-ID') AS [Total in Rupiah],
FORMAT(SUM((rd.RoomPrice * DATEDIFF(DAY, th.CheckInDate, th.CheckOutDate)))/15000, 'C0', 'en-US') AS [Total in Dollar]
FROM MsCustomer mc
JOIN TransactionHeader th ON mc.CustomerID = th.CustomerID
JOIN MsRoom mr ON mr.RoomNumber = th.RoomNumber
JOIN RoomDetail rd ON rd.RoomID = mr.RoomID
GROUP BY 
mc.CustomerID, LEFT(mc.CustomerName, CHARINDEX(' ', CustomerName) - 1), 
SUBSTRING(mc.CustomerName, LEN(mc.CustomerName) - CHARINDEX(' ', REVERSE(mc.CustomerName)) + 2, LEN(mc.CustomerName))

--5
GO
CREATE VIEW [BestStaffin2023]
AS 
SELECT 
ms.StaffID AS [Staff ID], StaffName AS [Staff Name],
COUNT(th.StaffID) AS [Total Served] 
FROM MsStaff ms
JOIN TransactionHeader th ON th.StaffID = ms.StaffID
WHERE YEAR(CheckInDate) LIKE '2023'
GROUP BY ms.StaffID, StaffName

GO
SELECT *
FROM BestStaffin2023

--6
SELECT
REPLACE(PaymentID, 'M', UPPER(RIGHT(PaymentMethod, 1))) AS [Payment Method ID],
PaymentMethod AS [Payment Method Name]
FROM MsPayment
ORDER BY PaymentMethod ASC

--7
SELECT 
LEFT(MC.CustomerName, CHARINDEX(' ', MC.CustomerName)) AS [Name],
CONVERT(VARCHAR, TH.CheckInDate, 107) AS [Check In Date],
CONVERT(VARCHAR, TH.CheckOutDate, 107) AS [Check Out Date],
CONCAT(DATEPART(HOUR, LateCheckOutHours), ' hours') AS [Late Check Out Hours],
FORMAT((DATEPART(HOUR, LateCheckOutHours) * 150000), 'C0', 'id-ID') AS [Late Check Out Fee]
FROM MsCustomer MC
JOIN TransactionHeader TH ON TH.CustomerID = MC.CustomerID

--8
SELECT
REPLACE(ms.ServiceID, 'SE', 'Service') AS [Service ID],
LOWER(ServiceName) AS [Service Name],
MIN(td.ServiceQuantity) AS [Minimum Quantity/Service],
MAX(td.ServiceQuantity) AS [Maximum Quantity/Service]
FROM MsService ms
JOIN TransactionDetail td ON ms.ServiceID = td.ServiceID
GROUP BY ms.ServiceID, ServiceName

--9 (Flag)
SELECT DISTINCT(
CONCAT(LEFT(mh.HotelID, 1), RIGHT(mh.HotelID, 1))) AS [Hotel ID],
HotelAddress AS [Hotel Address]
FROM MsHotel mh
JOIN TransactionHeader th ON mh.HotelID = th.HotelID
WHERE DATENAME(QUARTER, th.CheckInDate) IN (1, 2) 

--10
SELECT
CONCAT('Mr/Mrs. ', UPPER(CustomerName)) AS [Customer Name],
CustomerEmail AS [Customer Email],
CustomerPhoneNumber AS [Customer Phone Number]
FROM MsCustomer
WHERE CONVERT(INT, RIGHT(CustomerPhoneNumber, 1)) % 2 <> 0

--11
SELECT
REPLACE(TransactionID, 'TR', 'Transaktion') AS [Transaktion ID],
CustomerName AS [Kundenname],
mr.RoomNumber AS [Zimmernummer],
FORMAT(CONVERT(DATE, CheckInDate), 'dddd, d. MMMM yyyy', 'de-DE') AS [Check In Datum],
FORMAT(CONVERT(DATE, CheckOutDate), 'dddd, d. MMMM yyyy', 'de-DE') AS [Check Out Datum],
ms.StaffName AS [Mitarbeitername],
CASE 
    WHEN PaymentMethod = 'Cash' THEN 'Bargeld'
    WHEN PaymentMethod = 'Credit Card' THEN 'Kreditkarte'
    WHEN PaymentMethod = 'Debit Card' THEN 'Bank�berweisung'
	END AS [Zahlungsmethode Name]
FROM TransactionHeader th
JOIN MsCustomer mc ON mc.CustomerID = th.CustomerID
JOIN MsRoom mr ON mr.RoomNumber = th.RoomNumber
JOIN MsStaff ms On ms.StaffID = th.StaffID
JOIN MsPayment mp ON mp.PaymentID = th.PaymentID

--12
BEGIN TRAN
ALTER TABLE MsCustomer
ALTER COLUMN CustomerPhoneNumber VARCHAR(15)

ROLLBACK

--13
SELECT 
CONCAT(UPPER(LEFT(RoomTypename, 2)), mr.RoomNumber) AS [ID],
mr.RoomNumber AS [Room Number],
rd.RoomTypeName AS [Room Type Name],
COUNT(mr.RoomID) AS [Total Transactions]
FROM RoomDetail rd
JOIN MsRoom mr ON mr.RoomID = rd.RoomID
GROUP BY CONCAT(UPPER(LEFT(RoomTypename, 2)), mr.RoomNumber), mr.RoomNumber, rd.RoomTypeName
ORDER BY [Total Transactions] DESC

--14
BEGIN TRAN
DELETE FROM TransactionDetail
WHERE TransactionID IN (
    SELECT TransactionID
    FROM TransactionHeader
    WHERE PaymentID IN (
		SELECT PaymentID FROM MsPayment WHERE PaymentMethod LIKE 'Cash'
	)
);

DELETE FROM TransactionHeader
WHERE PaymentID IN (
	SELECT PaymentID FROM MsPayment WHERE PaymentMethod LIKE 'Cash'
);

SELECT *
FROM TransactionHeader th
JOIN MsPayment mp ON mp.PaymentID = th.PaymentID
WHERE mp.PaymentMethod LIKE 'Cash'

ROLLBACK 

--15
GO
CREATE VIEW [Top5BranchDafflEsHotel]
AS
SELECT TOP 5 
CONCAT('Branch', CAST(
        CASE 
            WHEN mh.HotelID LIKE '%0%' THEN SUBSTRING(mh.HotelID, 3, LEN(mh.HotelID)) 
            ELSE SUBSTRING(mh.HotelID, 3, LEN(mh.HotelID)) 
        END AS INT)
    ) AS [HotelID],
mh.HotelAddress AS [Hotel Address],
COUNT(th.HotelID) AS [Total Transaction]
FROM MsHotel mh
JOIN TransactionHeader th ON mh.HotelID = th.HotelID
GROUP BY CONCAT('Branch', CAST(
        CASE 
            WHEN mh.HotelID LIKE '%0%' THEN SUBSTRING(mh.HotelID, 3, LEN(mh.HotelID)) 
            ELSE SUBSTRING(mh.HotelID, 3, LEN(mh.HotelID)) 
        END AS INT)
    ), mh.HotelAddress
ORDER BY [Total Transaction] DESC


GO
SELECT *
FROM Top5BranchDafflEsHotel

--16
SELECT 
CONCAT('SE', CAST(ASCII(LEFT(ServiceName, 1))+ ASCII(RIGHT(ServiceName, 1)) AS VARCHAR)) AS [Service ID],
ServiceName AS [Service Name],
FORMAT(ServicePrice, 'C0', 'en-US') AS [Service Price]
FROM MsService
ORDER BY ServicePrice ASC;

--17
SELECT 
CONCAT('BS', CAST(ASCII(LEFT(RoomTypeName, 1)) * 2  AS VARCHAR)) AS [Transaction ID],
mr.RoomNumber AS [Room Number],
rd.RoomTypeName AS [Room Type Name],
DATEDIFF(DAY, th.CheckInDate, th.CheckOutDate) AS [Length of Stay]
FROM RoomDetail rd
JOIN MsRoom mr ON mr.RoomID = rd.RoomID
JOIN TransactionHeader th ON mr.RoomNumber = th.RoomNumber
WHERE rd.RoomTypeName LIKE 'Business'
UNION
SELECT 
CONCAT('KG', CAST(ASCII(LEFT(RoomTypeName, 1)) * 2  AS VARCHAR)) AS [Transaction ID],
mr.RoomNumber AS [Room Number],
rd.RoomTypeName AS [Room Type Name],
DATEDIFF(DAY, th.CheckInDate, th.CheckOutDate) AS [Length of Stay]
FROM RoomDetail rd
JOIN MsRoom mr ON mr.RoomID = rd.RoomID
JOIN TransactionHeader th ON mr.RoomNumber = th.RoomNumber
WHERE rd.RoomTypeName LIKE 'King'


--18
SELECT
TransactionID AS [Transaction ID],
th.RoomNumber AS [Room Number],
CONCAT(LEFT(mc.CustomerName, CHARINDEX(' ', mc.CustomerName)), ' ', LEFT(SUBSTRING(mc.CustomerName, LEN(mc.CustomerName) - CHARINDEX(' ', REVERSE(mc.CustomerName)) + 2, LEN(mc.CustomerName)), 1)) AS [Name],
CheckInDate AS [Check In Date],
CheckOutDate AS [Check Out Date]
FROM TransactionHeader th
JOIN MsCustomer mc ON th.CustomerID = mc.CustomerID
WHERE DATEDIFF(MONTH, GETDATE(), CheckInDate)  > -9 AND DATEDIFF(MONTH, GETDATE(), CheckInDate) < 1

--19
SELECT 
REPLACE(StaffID, 'T', UPPER(SUBSTRING(LEFT(StaffName, CHARINDEX(' ', StaffName)), (LEN(LEFT(StaffName, CHARINDEX(' ', StaffName))) / 2) + 1, 1))) AS [StaffID],
StaffName AS [Staff Name],
StaffGender AS [Staff Gender]
FROM MsStaff
WHERE StaffGender LIKE 'Female' AND StaffName LIKE '%a%'

--20
SELECT 
th.TransactionID AS [Transaction ID],
mc.CustomerID AS [Customer ID],
CONCAT(DATEDIFF(DAY, th.CheckInDate, th.CheckOutDate), ' days') AS [Length of Stay],
FORMAT(SUM(mss.ServicePrice * td.ServiceQuantity), 'C0', 'id-ID') AS [Service Subtotal],
FORMAT(RoomPrice * DATEDIFF(DAY, th.CheckInDate, th.CheckOutDate), 'C0', 'id-ID') AS [Room Subtotal],
CONCAT(CONVERT(INT,ServiceDiscount * 100), '%') AS [Discount],
FORMAT(SUM(mss.ServicePrice * td.ServiceQuantity) + RoomPrice * DATEDIFF(DAY, th.CheckInDate, th.CheckOutDate), 'C0', 'id-ID') AS [Total Price]
FROM TransactionHeader th
JOIN MsCustomer mc ON th.CustomerID = mc.CustomerID
JOIN TransactionDetail td ON td.TransactionID = th.TransactionID
JOIN MsService mss ON mss.ServiceID = td.ServiceID
JOIN MsRoom mr ON mr.RoomNumber = th.RoomNumber
JOIN RoomDetail rd On rd.RoomID = mr.RoomID
GROUP BY th.TransactionID, mc.CustomerID, th.CheckInDate, th.CheckOutDate, RoomPrice, ServiceDiscount
