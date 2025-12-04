CREATE DATABASE CabBookingDB;
use CabBookingDB;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Gender VARCHAR(10),
    Contact VARCHAR(15),
    Email VARCHAR(100)
);
CREATE TABLE Drivers (
    DriverID INT PRIMARY KEY,
    Name VARCHAR(100),
    JoinDate DATE,
    Rating DECIMAL(3,1),
    City VARCHAR(50)
);
CREATE TABLE Cabs (
    CabID INT PRIMARY KEY,
    DriverID INT,
    VehicleType VARCHAR(20),
    LicensePlate VARCHAR(20),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY,
    CustomerID INT,
    CabID INT,
    BookingDate DATETIME,
    PickupLocation VARCHAR(100),
    DropoffLocation VARCHAR(100),
    Status VARCHAR(20),      -- Completed / Cancelled / Ongoing
    Fare DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (CabID) REFERENCES Cabs(CabID));
    
    CREATE TABLE TripDetails (
    TripID INT PRIMARY KEY,
    BookingID INT,
    StartTime DATETIME,
    EndTime DATETIME,
    Distance DECIMAL(6,2),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY,
    BookingID INT,
    Rating DECIMAL(3,1),
    Comments TEXT,
    CancellationReason VARCHAR(255),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

INSERT INTO Customers VALUES
(1, 'Ravi', 'Male', '9876543210', 'ravi@gmail.com'),
(2, 'Priya', 'Female', '9823456789', 'priya@gmail.com'),
(3, 'Kiran', 'Male', '9765432189', 'kiran@gmail.com');


INSERT INTO Drivers VALUES
(1, 'Suresh', '2024-01-01', 4.2, 'Hyderabad'),
(2, 'Ramesh', '2023-05-10', 3.8, 'Hyderabad'),
(3, 'Mahesh', '2022-03-20', 2.8, 'Hyderabad');


INSERT INTO Cabs VALUES
(1, 1, 'Sedan', 'TS09AB1234'),
(2, 2, 'SUV', 'TS10CD5678'),
(3, 3, 'Sedan', 'TS11EF9012');

INSERT INTO Bookings VALUES
(101, 1, 1, '2025-10-01 09:30:00', 'Madhapur', 'Kondapur', 'Completed', 320.00),
(102, 2, 2, '2025-10-02 11:00:00', 'Gachibowli', 'Airport', 'Cancelled', 0.00),
(103, 3, 3, '2025-10-03 08:30:00', 'Ameerpet', 'Madhapur', 'Completed', 250.00),
(104, 1, 1, '2025-09-10 18:00:00', 'Kondapur', 'Banjara Hills', 'Completed', 450.00),
(105, 2, 2, '2025-08-05 07:30:00', 'Airport', 'Madhapur', 'Completed', 600.00),
(106, 3, 3, '2025-08-06 10:00:00', 'Gachibowli', 'Ameerpet', 'Cancelled', 0.00);

INSERT INTO TripDetails VALUES
(201, 101, '2025-10-01 09:45:00', '2025-10-01 10:15:00', 8.5),
(202, 103, '2025-10-03 08:45:00', '2025-10-03 09:20:00', 9.0),
(203, 104, '2025-09-10 18:15:00', '2025-09-10 19:00:00', 12.5),
(204, 105, '2025-08-05 07:45:00', '2025-08-05 08:45:00', 18.0);

INSERT INTO Feedback VALUES
(301, 101, 4.5, 'Smooth ride', NULL),
(302, 102, NULL, NULL, 'Driver cancelled'),
(303, 103, 3.0, 'Average experience', NULL),
(304, 104, 4.8, 'Great service', NULL),
(305, 105, 4.2, 'Good trip', NULL),
(306, 106, NULL, NULL, 'Customer cancelled');

##1.dentify customers who have completed the most bookings. What insights can you draw about their behavior? 
SELECT CustomerID, COUNT(*) AS TotalCompleted
FROM Bookings
WHERE Status = 'Completed'
GROUP BY CustomerID
ORDER BY TotalCompleted DESC
LIMIT 5;

-- Find customers who have canceled more than 30% of their total bookings. What could be the reason for frequent cancellations? 
SELECT CustomerID,SUM(CASE WHEN Status='Cancelled' THEN 1 ELSE 0 END)*100.0/COUNT(*) AS CancelPercent
FROM Bookings
GROUP BY CustomerID
HAVING CancelPercent > 30;

 -- Determine the busiest day of the week for bookings. How can the company optimize cab availability on peak days? 
 SELECT DAYNAME(BookingDate) AS DayOfWeek, COUNT(*) AS TotalBookings
FROM Bookings
GROUP BY DayOfWeek
ORDER BY TotalBookings DESC;

 -- Driver Performance & Efficiency  
 -- Identify drivers who have received an average rating below 3.0 in the past three months. What strategies can be implemented to improve their performance? 
 SELECT d.DriverID, d.Name, AVG(f.Rating) AS AvgRating
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
JOIN Feedback f ON b.BookingID = f.BookingID
WHERE f.Rating IS NOT NULL
  AND b.BookingDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY d.DriverID, d.Name
HAVING AvgRating < 3.0;

-- Find the top 5 drivers who have completed the longest trips in terms of distance. What does this say about their working patterns? 
SELECT d.DriverID, d.Name, SUM(t.Distance) AS TotalDistance
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
JOIN TripDetails t ON b.BookingID = t.BookingID
WHERE b.Status = 'Completed'
GROUP BY d.DriverID, d.Name
ORDER BY TotalDistance DESC
LIMIT 5;

 -- Identify drivers with a high percentage of canceled trips. Could this indicate driver unreliability? 
 SELECT d.DriverID, d.Name,SUM(CASE WHEN b.Status='Cancelled' THEN 1 ELSE 0 END)*100.0/COUNT(*) AS CancelRate
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
GROUP BY d.DriverID, d.Name
HAVING CancelRate > 25;

-- Revenue & Business Metrics 
-- Calculate the total revenue generated by completed bookings in the last 6 months. How has the revenue trend changed over time? 
SELECT SUM(Fare) AS TotalRevenue
FROM Bookings
WHERE Status = 'Completed'
AND BookingDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- Identify the top 3 most frequently traveled routes based on PickupLocation and DropoffLocation. Should the company allocate more cabs to these routes? 
SELECT PickupLocation, DropoffLocation, COUNT(*) AS RouteCount
FROM Bookings
WHERE Status = 'Completed'
GROUP BY PickupLocation, DropoffLocation
ORDER BY RouteCount DESC
LIMIT 3;

-- Determine if higher-rated drivers tend to complete more trips and earn higher fares. Is there a direct correlation between driver ratings and earnings? 
SELECT d.DriverID, AVG(f.Rating) AS AvgRating, SUM(b.Fare) AS TotalEarnings, COUNT(b.BookingID) AS Trips
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
JOIN Feedback f ON b.BookingID = f.BookingID
WHERE b.Status = 'Completed'
GROUP BY d.DriverID;

-- Operational Efficiency & Optimization 
-- Analyze the average waiting time (difference between booking time and trip start time) for different pickup locations. How can this be optimized to reduce delays? 
SELECT b.PickupLocation,AVG(TIMESTAMPDIFF(MINUTE, b.BookingDate, t.StartTime)) AS AvgWaitTime
FROM Bookings b
JOIN TripDetails t ON b.BookingID = t.BookingID
WHERE b.Status = 'Completed'
GROUP BY b.PickupLocation
ORDER BY AvgWaitTime DESC;

-- Identify the most common reasons for trip cancellations from customer feedback. What actions can be taken to reduce cancellations? 
SELECT CancellationReason, COUNT(*) AS TotalCancellations
FROM Feedback
WHERE CancellationReason IS NOT NULL
GROUP BY CancellationReason
ORDER BY TotalCancellations DESC;

-- Find out whether shorter trips (low-distance) contribute significantly to revenue. Should the company encourage more short-distance rides? 
SELECT CASE WHEN t.Distance < 5 THEN 'Short Trip' ELSE 'Long Trip' END AS TripType,
SUM(b.Fare) AS TotalRevenue
FROM Bookings b
JOIN TripDetails t ON b.BookingID = t.BookingID
WHERE b.Status = 'Completed'
GROUP BY TripType;

###Comparative & Predictive Analysis 
-- Compare the revenue generated from 'Sedan' and 'SUV' cabs. Should the company invest more in a particular vehicle type? 
SELECT c.VehicleType, SUM(b.Fare) AS TotalRevenue
FROM Bookings b
JOIN Cabs c ON b.CabID = c.CabID
WHERE b.Status = 'Completed'
GROUP BY c.VehicleType;

-- Predict which customers are likely to stop using the service based on their last booking date and frequency of rides. How can customer retention be improved? 
SELECT CustomerID,MAX(BookingDate) AS LastBooking,
COUNT(*) AS TotalBookings
FROM Bookings
GROUP BY CustomerID
HAVING DATEDIFF(CURDATE(), LastBooking) > 90;

-- Analyze whether weekend bookings differ significantly from weekday bookings. Should the company introduce dynamic pricing based on demand? 
SELECT 
CASE WHEN DAYOFWEEK(BookingDate) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END AS DayType,    
COUNT(*) AS TotalBookings,
SUM(Fare) AS TotalRevenue
FROM Bookings
GROUP BY DayType;
