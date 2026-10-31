USE blood_network;

INSERT INTO blood_banks (name, city, phone, address) VALUES
('Sanjeevani Blood Bank', 'Jaipur', '9800000101', 'MI Road, Jaipur'),
('Jeevan Blood Centre',   'Jaipur', '9800000102', 'Malviya Nagar, Jaipur'),
('Arogya Blood Bank',     'Delhi',  '9800000103', 'Karol Bagh, Delhi'),
('LifeLine Blood Centre', 'Mumbai', '9800000104', 'Andheri East, Mumbai');

INSERT INTO donors (name, blood_group, gender, dob, phone, email, city) VALUES
('Aarav Sharma',     'O-',  'M', '1998-04-12', '9810000001', 'aarav@example.com',  'Jaipur'),
('Priya Meena',      'A+',  'F', '2001-09-23', '9810000002', NULL,                 'Jaipur'),
('Rohan Gupta',      'B+',  'M', '1995-01-30', '9810000003', 'rohan@example.com',  'Jaipur'),
('Sneha Rathore',    'O-',  'F', '2000-07-15', '9810000004', NULL,                 'Jaipur'),
('Kabir Singh',      'AB+', 'M', '1992-11-05', '9810000005', NULL,                 'Delhi'),
('Ananya Verma',     'O+',  'F', '1999-03-18', '9810000006', 'ananya@example.com', 'Delhi'),
('Vikram Choudhary', 'O-',  'M', '1990-06-22', '9810000007', NULL,                 'Delhi'),
('Isha Patel',       'A-',  'F', '2002-02-10', '9810000008', NULL,                 'Mumbai'),
('Arjun Nair',       'B-',  'M', '1997-12-01', '9810000009', NULL,                 'Mumbai'),
('Meera Joshi',      'AB-', 'F', '1994-08-27', '9810000010', NULL,                 'Mumbai'),
('Dev Saini',        'O+',  'M', '2003-05-09', '9810000011', NULL,                 'Jaipur'),
('Kavya Agarwal',    'B+',  'F', '1996-10-14', '9810000012', NULL,                 'Jaipur');

INSERT INTO requests (patient_name, blood_group, units_needed, hospital, city, urgency, contact_phone) VALUES
('Ramesh Kumar', 'O-',  2, 'Pink City Hospital',       'Jaipur', 'Critical', '9820000001'),
('Sunita Devi',  'A+',  1, 'City Care Hospital',       'Jaipur', 'High',     '9820000002'),
('Mohit Arora',  'B+',  3, 'Metro Heart Institute',    'Delhi',  'Medium',   '9820000003'),
('Farah Khan',   'AB-', 1, 'Seaside General Hospital', 'Mumbai', 'High',     '9820000004'),
('Gopal Yadav',  'O+',  1, 'Pink City Hospital',       'Jaipur', 'Low',      '9820000005');

-- Dates are relative to today so the demo always looks fresh
INSERT INTO donations (donor_id, bank_id, request_id, donation_date, units) VALUES
(1, 1, NULL, DATE_SUB(CURDATE(), INTERVAL 30 DAY),  1),
(3, 1, NULL, DATE_SUB(CURDATE(), INTERVAL 120 DAY), 1),
(6, 3, NULL, DATE_SUB(CURDATE(), INTERVAL 45 DAY),  1),
(9, 4, NULL, DATE_SUB(CURDATE(), INTERVAL 200 DAY), 1),
(2, 2, NULL, DATE_SUB(CURDATE(), INTERVAL 5 DAY),   1);
