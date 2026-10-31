USE blood_network;

-- ---------- BLOOD BANKS ----------
INSERT INTO blood_banks (name, city, phone, address) VALUES
('Sanjeevani Blood Bank',     'Jaipur',    '9800000101', 'MI Road, Jaipur'),
('Jeevan Blood Centre',       'Jaipur',    '9800000102', 'Malviya Nagar, Jaipur'),
('Fortis Escorts Blood Bank', 'Jaipur',    '9800000110', 'Jawaharlal Nehru Marg, Jaipur'),
('Arogya Blood Bank',         'Delhi',     '9800000103', 'Karol Bagh, Delhi'),
('LifeLine Blood Centre',     'Mumbai',    '9800000104', 'Andheri East, Mumbai'),
('Red Cross Blood Center',    'Bengaluru', '9800000105', 'MG Road, Bengaluru'),
('Apollo Blood Bank',         'Chennai',   '9800000106', 'Greams Road, Chennai'),
('Care Blood Bank',           'Hyderabad', '9800000107', 'Banjara Hills, Hyderabad'),
('Sahyadri Blood Center',     'Pune',      '9800000108', 'Deccan Gymkhana, Pune'),
('Kolkata Central Blood Bank','Kolkata',   '9800000109', 'Park Street, Kolkata');

-- ---------- DONORS ----------
INSERT INTO donors (name, blood_group, gender, dob, phone, email, city) VALUES
('Aarav Sharma',       'O-',  'M', '1998-04-12', '9810000001', 'aarav@example.com',    'Jaipur'),
('Priya Meena',        'A+',  'F', '2001-09-23', '9810000002', NULL,                   'Jaipur'),
('Rohan Gupta',        'B+',  'M', '1995-01-30', '9810000003', 'rohan@example.com',    'Jaipur'),
('Sneha Rathore',      'O-',  'F', '2000-07-15', '9810000004', NULL,                   'Jaipur'),
('Kabir Singh',        'AB+', 'M', '1992-11-05', '9810000005', NULL,                   'Delhi'),
('Ananya Verma',       'O+',  'F', '1999-03-18', '9810000006', 'ananya@example.com',   'Delhi'),
('Vikram Choudhary',   'O-',  'M', '1990-06-22', '9810000007', NULL,                   'Delhi'),
('Isha Patel',         'A-',  'F', '2002-02-10', '9810000008', NULL,                   'Mumbai'),
('Arjun Nair',         'B-',  'M', '1997-12-01', '9810000009', NULL,                   'Mumbai'),
('Meera Joshi',        'AB-', 'F', '1994-08-27', '9810000010', NULL,                   'Mumbai'),
('Dev Saini',          'O+',  'M', '2003-05-09', '9810000011', NULL,                   'Jaipur'),
('Kavya Agarwal',      'B+',  'F', '1996-10-14', '9810000012', NULL,                   'Jaipur'),
('Rajesh Khanna',      'O+',  'M', '1988-05-14', '9810000013', 'rajesh.k@example.com', 'Bengaluru'),
('Deepika Padukone',   'A-',  'F', '1996-01-05', '9810000014', 'deepika.p@example.com', 'Bengaluru'),
('Karthik Raman',      'B+',  'M', '2001-11-20', '9810000015', NULL,                   'Bengaluru'),
('Siddharth Rao',      'O-',  'M', '1993-07-19', '9810000016', 'sid.rao@example.com',  'Bengaluru'),
('Lakshmi Narayanan',  'AB+', 'F', '1985-03-25', '9810000017', NULL,                   'Chennai'),
('Venkatesh Iyer',     'A+',  'M', '1999-08-12', '9810000018', 'venky@example.com',    'Chennai'),
('Swathi Reddy',       'O-',  'F', '2002-12-04', '9810000019', NULL,                   'Hyderabad'),
('Pranav Teja',        'B-',  'M', '1997-04-18', '9810000020', 'pranav.t@example.com', 'Hyderabad'),
('Pooja Kulkarni',     'A+',  'F', '1994-09-30', '9810000021', 'pooja.k@example.com',  'Pune'),
('Nikhil Deshmukh',    'O+',  'M', '2000-02-14', '9810000022', NULL,                   'Pune'),
('Sourav Ganguly',     'B+',  'M', '1991-06-08', '9810000023', 'sourav.g@example.com', 'Kolkata'),
('Riya Sen',           'AB-', 'F', '2003-10-27', '9810000024', NULL,                   'Kolkata'),
('Tanmay Joshi',       'O-',  'M', '1998-12-15', '9810000025', 'tanmay.j@example.com', 'Jaipur'),
('Nisha Singhal',      'B+',  'F', '2002-05-22', '9810000026', 'nisha.s@example.com',  'Jaipur'),
('Manish Tiwari',      'A+',  'M', '1990-11-11', '9810000027', NULL,                   'Delhi'),
('Kritika Mishra',     'O-',  'F', '2001-03-09', '9810000028', 'kritika.m@example.com', 'Delhi'),
('Varun Dhawan',       'AB+', 'M', '1995-08-17', '9810000029', NULL,                   'Mumbai'),
('Shraddha Kapoor',    'A-',  'F', '1999-07-03', '9810000030', 'shraddha.k@example.com', 'Mumbai');

-- ---------- REQUESTS ----------
INSERT INTO requests (patient_name, blood_group, units_needed, hospital, city, urgency, contact_phone) VALUES
('Ramesh Kumar',       'O-',  2, 'Pink City Hospital',           'Jaipur',    'Critical', '9820000001'),
('Sunita Devi',        'A+',  1, 'City Care Hospital',           'Jaipur',    'High',     '9820000002'),
('Mohit Arora',        'B+',  3, 'Metro Heart Institute',        'Delhi',     'Medium',   '9820000003'),
('Farah Khan',         'AB-', 1, 'Seaside General Hospital',     'Mumbai',    'High',     '9820000004'),
('Gopal Yadav',        'O+',  1, 'Pink City Hospital',           'Jaipur',    'Low',      '9820000005'),
('Aditya Roy',         'O-',  2, 'Manipal Hospital',             'Bengaluru', 'Critical', '9820000006'),
('Meenakshi Sundaram', 'A+',  3, 'Apollo Speciality Hospital',   'Chennai',   'High',     '9820000007'),
('Kavitha Rao',        'B-',  1, 'KIMS Hospital',                'Hyderabad', 'Critical', '9820000008'),
('Anand Shinde',       'O+',  2, 'Ruby Hall Clinic',             'Pune',      'Medium',   '9820000009'),
('Debashis Mukherjee', 'AB-', 1, 'AMRI Hospital',                'Kolkata',   'High',     '9820000010'),
('Rajendra Prasad',    'B+',  2, 'SMS Medical College Hospital', 'Jaipur',    'Medium',   '9820000011'),
('Pooja Bhardwaj',     'A-',  1, 'Max Super Speciality Hospital', 'Delhi',    'Critical', '9820000012'),
('Harish Salve',       'O-',  2, 'Lilavati Hospital',            'Mumbai',    'High',     '9820000013'),
('Divya Prakash',      'AB+', 1, 'Pink City Heart Hospital',     'Jaipur',    'Low',      '9820000014');

-- ---------- DONATIONS (Relative to today so demo always looks fresh) ----------
INSERT INTO donations (donor_id, bank_id, request_id, donation_date, units) VALUES
(1,  1, NULL, DATE_SUB(CURDATE(), INTERVAL 30 DAY),  1),
(3,  1, NULL, DATE_SUB(CURDATE(), INTERVAL 120 DAY), 1),
(6,  4, NULL, DATE_SUB(CURDATE(), INTERVAL 45 DAY),  1),
(9,  5, NULL, DATE_SUB(CURDATE(), INTERVAL 200 DAY), 1),
(2,  2, NULL, DATE_SUB(CURDATE(), INTERVAL 5 DAY),   1),
(13, 6, NULL, DATE_SUB(CURDATE(), INTERVAL 15 DAY),  1),
(16, 6, NULL, DATE_SUB(CURDATE(), INTERVAL 110 DAY), 1),
(18, 7, NULL, DATE_SUB(CURDATE(), INTERVAL 10 DAY),  1),
(21, 9, NULL, DATE_SUB(CURDATE(), INTERVAL 95 DAY),  1),
(23, 10, NULL, DATE_SUB(CURDATE(), INTERVAL 140 DAY), 1);
