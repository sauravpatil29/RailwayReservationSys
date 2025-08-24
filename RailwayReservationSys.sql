CREATE DATABASE railway_reservation;
USE railway_reservation;

-- Train Table
CREATE TABLE Train (
    train_id INT PRIMARY KEY AUTO_INCREMENT,
    train_name VARCHAR(100) NOT NULL,
    source VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    total_seats INT NOT NULL,
    class_type ENUM('Sleeper', 'AC', 'General') NOT NULL,
    fare DECIMAL(10,2) NOT NULL
);

-- Passenger Table
CREATE TABLE Passenger (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender ENUM('Male','Female','Other') NOT NULL
);

-- Booking Table
CREATE TABLE Booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT,
    train_id INT,
    seat_no INT,
    booking_date DATE NOT NULL,
    status ENUM('Booked','Cancelled') DEFAULT 'Booked',
    FOREIGN KEY (passenger_id) REFERENCES Passenger(passenger_id),
    FOREIGN KEY (train_id) REFERENCES Train(train_id),
    UNIQUE (train_id, seat_no)  -- seat cannot be double-booked
);

-- Trains
INSERT INTO Train (train_name, source, destination, total_seats, class_type, fare)
VALUES
('Express 101', 'Mumbai', 'Delhi', 5, 'AC', 1500),
('Express 202', 'Pune', 'Nagpur', 4, 'Sleeper', 800);

-- Passengers
INSERT INTO Passenger (name, age, gender) VALUES
('Saurav Patil', 22, 'Male'),
('Aarti Sharma', 28, 'Female'),
('Rohan Singh', 35, 'Male');

-- View booking details with passenger and train info
SELECT b.booking_id, p.name, t.train_name, t.source, t.destination, b.seat_no, b.status
FROM Booking b
JOIN Passenger p ON b.passenger_id = p.passenger_id
JOIN Train t ON b.train_id = t.train_id;

-- Calculate revenue per train
SELECT t.train_name, SUM(t.fare) AS total_revenue
FROM Booking b
JOIN Train t ON b.train_id = t.train_id
WHERE b.status = 'Booked'
GROUP BY t.train_id;

-- Count passengers by class type


-- Booking Procedure
DELIMITER //
CREATE PROCEDURE BookTicket(IN p_passenger_id INT, IN p_train_id INT)
BEGIN
    DECLARE seat INT;
    DECLARE booked_count INT;

    -- Count already booked seats
    SELECT COUNT(*) INTO booked_count
    FROM Booking
    WHERE train_id = p_train_id AND status='Booked';

    -- Check seat availability
    IF booked_count < (SELECT total_seats FROM Train WHERE train_id = p_train_id) THEN
        SET seat = booked_count + 1;
        INSERT INTO Booking(passenger_id, train_id, seat_no, booking_date, status)
        VALUES(p_passenger_id, p_train_id, seat, CURDATE(), 'Booked');
    ELSE
        SELECT 'No seats available' AS message;
    END IF;
END //
DELIMITER ;

-- Cancellation Procedure
DELIMITER //
CREATE PROCEDURE CancelTicket(IN p_booking_id INT)
BEGIN
    UPDATE Booking
    SET status = 'Cancelled'
    WHERE booking_id = p_booking_id;
END //
DELIMITER ;


-- Book tickets
CALL BookTicket(1, 1);
CALL BookTicket(2, 1);
CALL BookTicket(3, 2);

-- Cancel a ticket
CALL CancelTicket(2);

-- Check all bookings
SELECT * FROM Booking;


