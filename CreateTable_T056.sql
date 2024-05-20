CREATE DATABASE DafflEsHotel
USE DafflEsHotel

CREATE TABLE MsService(
    ServiceID CHAR(5) PRIMARY KEY,
    ServiceName VARCHAR(255) NOT NULL,
    ServicePrice INTEGER CHECK(ServicePrice >= 35000 AND ServicePrice <= 1000000)
);

CREATE TABLE MsStaff(
    StaffID CHAR(5) PRIMARY KEY,
    StaffName VARCHAR(255) NOT NULL,
    StaffGender VARCHAR(255) CHECK(StaffGender IN ('Male', 'Female'))
);

CREATE TABLE MsCustomer(
    CustomerID CHAR(5) PRIMARY KEY,
    CustomerName VARCHAR(255) CHECK(CustomerName LIKE '% %'),
    CustomerAddress VARCHAR(255) NOT NULL,
    CustomerPhoneNumber VARCHAR(255) NOT NULL,
    CustomerEmail VARCHAR(255) NOT NULL,
    CustomerGender VARCHAR(255) CHECK(CustomerGender IN ('Male','Female'))
);

CREATE TABLE MsHotel(
    HotelID CHAR(5) PRIMARY KEY,
    HotelName VARCHAR(255) NOT NULL,
    HotelAddress VARCHAR(255) NOT NULL,
    HotelPhoneNumber VARCHAR(255) CHECK(HotelPhoneNumber LIKE '(021)%')
);

CREATE TABLE MsPayment(
    PaymentID CHAR(5) PRIMARY KEY,
    PaymentMethod VARCHAR(255) CHECK(PaymentMethod IN ('Cash', 'Debit Card', 'Credit Card' ))
);

CREATE TABLE RoomDetail(
    RoomID CHAR(5) PRIMARY KEY,
    RoomTypeName VARCHAR(255) NOT NULL,
    RoomPrice INTEGER CHECK(RoomPrice >=  1000000 AND RoomPrice <= 5000000)
);

CREATE TABLE MsRoom(
    RoomNumber INTEGER PRIMARY KEY,
    RoomID CHAR(5) REFERENCES RoomDetail(RoomID),
);

CREATE TABLE TransactionHeader(
    TransactionID CHAR(5) PRIMARY KEY,
    CustomerID CHAR(5) REFERENCES MsCustomer(CustomerID),
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    ServiceDiscount DECIMAL(5,2) NOT NULL,
    LateCheckOutHours TIME NOT NULL,
    PaymentID CHAR(5) REFERENCES MsPayment(PaymentID),
    StaffID CHAR(5) REFERENCES MsStaff(StaffID),
    HotelID CHAR(5) REFERENCES MsHotel(HotelID)
);

CREATE TABLE TransactionDetail(
    TransactionID CHAR(5) REFERENCES TransactionHeader(TransactionID),
    ServiceID CHAR(5) REFERENCES MsService(ServiceID),
    ServiceDate DATE NOT NULL,
    ServiceQuantity INTEGER NOT NULL,
    PRIMARY KEY (TransactionID, ServiceID)
);

