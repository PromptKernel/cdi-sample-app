-- Sample rows so the screens have something to show in a local run (loaded once by `make db`).
INSERT INTO dbo.tblCities (CityName) VALUES ('Hyderabad'), ('Mumbai'), ('Delhi'), ('Bengaluru');
INSERT INTO dbo.tblDepartment (DepartmentName, HeadcountLimit) VALUES ('IT', 10), ('HR', 5), ('Finance', 8);
INSERT INTO dbo.tblEmployee (Name, City, Department, Gender) VALUES
    ('Asha', 'Hyderabad', 'IT', 'Female'),
    ('Ravi', 'Mumbai', 'Finance', 'Male'),
    ('Meera', 'Delhi', 'HR', 'Female');
