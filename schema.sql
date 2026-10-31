CREATE DATABASE IF NOT EXISTS blood_network;
USE blood_network;

DROP VIEW IF EXISTS eligible_donors;
DROP PROCEDURE IF EXISTS find_donors_for_request;
DROP TABLE IF EXISTS donations, requests, donors, blood_banks, blood_compatibility;

-- ---------- TABLES ----------
CREATE TABLE blood_banks (
    bank_id   INT AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(100) NOT NULL,
    city      VARCHAR(50)  NOT NULL,
    phone     VARCHAR(15),
    address   VARCHAR(200)
);

CREATE TABLE donors (
    donor_id           INT AUTO_INCREMENT PRIMARY KEY,
    name               VARCHAR(100) NOT NULL,
    blood_group        ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    gender             ENUM('M','F','O') NOT NULL,
    dob                DATE NOT NULL,
    phone              VARCHAR(15) NOT NULL UNIQUE,
    email              VARCHAR(100),
    city               VARCHAR(50) NOT NULL,
    last_donation_date DATE NULL,          -- maintained automatically by trigger
    registered_on      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE requests (
    request_id    INT AUTO_INCREMENT PRIMARY KEY,
    patient_name  VARCHAR(100) NOT NULL,
    blood_group   ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
    units_needed  INT NOT NULL CHECK (units_needed BETWEEN 1 AND 10),
    hospital      VARCHAR(100) NOT NULL,
    city          VARCHAR(50)  NOT NULL,
    urgency       ENUM('Low','Medium','High','Critical') DEFAULT 'Medium',
    contact_phone VARCHAR(15) NOT NULL,
    status        ENUM('Open','Fulfilled','Cancelled') DEFAULT 'Open',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE donations (
    donation_id   INT AUTO_INCREMENT PRIMARY KEY,
    donor_id      INT NOT NULL,
    bank_id       INT NOT NULL,
    request_id    INT NULL,
    donation_date DATE NOT NULL,
    units         INT NOT NULL DEFAULT 1 CHECK (units BETWEEN 1 AND 2),
    FOREIGN KEY (donor_id)   REFERENCES donors(donor_id)     ON DELETE CASCADE,
    FOREIGN KEY (bank_id)    REFERENCES blood_banks(bank_id),
    FOREIGN KEY (request_id) REFERENCES requests(request_id) ON DELETE SET NULL
);

-- Which donor groups can give to which recipient groups
CREATE TABLE blood_compatibility (
    recipient_group ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-'),
    donor_group     ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-'),
    PRIMARY KEY (recipient_group, donor_group)
);

INSERT INTO blood_compatibility VALUES
('O-','O-'),
('O+','O-'),('O+','O+'),
('A-','O-'),('A-','A-'),
('A+','O-'),('A+','O+'),('A+','A-'),('A+','A+'),
('B-','O-'),('B-','B-'),
('B+','O-'),('B+','O+'),('B+','B-'),('B+','B+'),
('AB-','O-'),('AB-','A-'),('AB-','B-'),('AB-','AB-'),
('AB+','O-'),('AB+','O+'),('AB+','A-'),('AB+','A+'),
('AB+','B-'),('AB+','B+'),('AB+','AB-'),('AB+','AB+');

-- ---------- VIEW ----------
CREATE VIEW eligible_donors AS
SELECT donor_id, name, blood_group, city, phone, last_donation_date,
       TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age
FROM donors
WHERE TIMESTAMPDIFF(YEAR, dob, CURDATE()) BETWEEN 18 AND 65
  AND (last_donation_date IS NULL
       OR DATEDIFF(CURDATE(), last_donation_date) >= 90);

DELIMITER //

-- ---------- TRIGGER 1: donor must be 18-65 ----------
CREATE TRIGGER trg_check_donor_age
BEFORE INSERT ON donors
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.dob, CURDATE()) NOT BETWEEN 18 AND 65 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Donor must be between 18 and 65 years old.';
    END IF;
END //

-- ---------- TRIGGER 2: enforce 90-day gap ----------
CREATE TRIGGER trg_check_eligibility
BEFORE INSERT ON donations
FOR EACH ROW
BEGIN
    DECLARE last_date DATE;
    SELECT last_donation_date INTO last_date
    FROM donors WHERE donor_id = NEW.donor_id;

    IF last_date IS NOT NULL
       AND ABS(DATEDIFF(NEW.donation_date, last_date)) < 90 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Donor is not eligible: 90 days must pass between donations.';
    END IF;
END //

-- ---------- TRIGGER 3: update donor + auto-fulfil request ----------
CREATE TRIGGER trg_after_donation
AFTER INSERT ON donations
FOR EACH ROW
BEGIN
    UPDATE donors
    SET last_donation_date = NEW.donation_date
    WHERE donor_id = NEW.donor_id
      AND (last_donation_date IS NULL OR last_donation_date < NEW.donation_date);

    IF NEW.request_id IS NOT NULL THEN
        UPDATE requests
        SET status = 'Fulfilled'
        WHERE request_id = NEW.request_id
          AND (SELECT SUM(units) FROM donations
               WHERE request_id = NEW.request_id) >= units_needed;
    END IF;
END //

-- ---------- STORED PROCEDURE: match donors to a request ----------
CREATE PROCEDURE find_donors_for_request(IN p_request_id INT)
BEGIN
    SELECT e.donor_id, e.name, e.blood_group, e.city, e.phone,
           e.last_donation_date, e.age,
           (e.blood_group = r.blood_group) AS exact_match
    FROM requests r
    JOIN blood_compatibility c ON c.recipient_group = r.blood_group
    JOIN eligible_donors e     ON e.blood_group = c.donor_group
                              AND e.city = r.city
    WHERE r.request_id = p_request_id
    ORDER BY exact_match DESC,
             e.last_donation_date IS NOT NULL,
             e.last_donation_date;
END //

DELIMITER ;
