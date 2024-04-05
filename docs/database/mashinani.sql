CREATE TABLE Bank (
    bank_id SERIAL PRIMARY KEY,
    bank_name VARCHAR(200) UNIQUE NOT NULL
);

CREATE TABLE Institution (
    institution_id SERIAL PRIMARY KEY,
    institution_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Account (
    account_id SERIAL PRIMARY KEY,
    institution_id INT NOT NULL,
    bank_id INT NOT NULL,
    account_number VARCHAR(200) UNIQUE NOT NULL,
    FOREIGN KEY (institution_id) REFERENCES Institution(institution_id) ON DELETE CASCADE,
    FOREIGN KEY (bank_id) REFERENCES Bank(bank_id) ON DELETE CASCADE
);

CREATE TABLE Country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Region (
    region_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    region_name VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (country_id) REFERENCES Country(country_id) ON DELETE CASCADE
);

CREATE TABLE County (
    county_id SERIAL PRIMARY KEY,
    region_id INT NOT NULL,
    county_name VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (region_id) REFERENCES Region(region_id) ON DELETE CASCADE
);

CREATE TABLE Constituency (
    constituency_id SERIAL PRIMARY KEY,
    county_id INT NOT NULL,
    constituency_name VARCHAR(255) UNIQUE NOT NULL,
    FOREIGN KEY (county_id) REFERENCES County(county_id) ON DELETE CASCADE
);

CREATE TABLE Ward (
    ward_id SERIAL PRIMARY KEY,
    constituency_id INT NOT NULL,
    ward_name VARCHAR(200) UNIQUE NOT NULL,
    FOREIGN KEY (constituency_id) REFERENCES Constituency(constituency_id) ON DELETE CASCADE
);

CREATE TABLE Resident (
    resident_id SERIAL PRIMARY KEY,
    national_id_no VARCHAR(200) UNIQUE NOT NULL,
    ward_id INT NOT NULL,
    FOREIGN KEY (ward_id) REFERENCES Ward(ward_id) ON DELETE CASCADE
);

CREATE TABLE Student (
    student_id SERIAL PRIMARY KEY,
    national_id_no VARCHAR(200) UNIQUE NOT NULL,
    institution_id INT NOT NULL,
    registration_number VARCHAR(200) UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (institution_id) REFERENCES Institution(institution_id) ON DELETE CASCADE
);

CREATE TABLE FinancialYear (
    financial_year_id SERIAL PRIMARY KEY,
    financial_year VARCHAR(9) UNIQUE NOT NULL,
    financial_year_status VARCHAR(6) NOT NULL,
    CHECK (financial_year_status IN ('Open', 'Closed'))
);

CREATE TABLE BursaryApplication (
    bursary_application_id SERIAL PRIMARY KEY,
    national_id_no VARCHAR(200) UNIQUE NOT NULL,
    registration_number VARCHAR(200) UNIQUE NOT NULL,
    institution_id INT NOT NULL,
    account_number VARCHAR(200) UNIQUE NOT NULL,
    ward_id INT NOT NULL,
    financial_year_id INT NOT NULL,
    serial_number VARCHAR(200) UNIQUE NOT NULL,
    date_submitted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount_disbursed DECIMAL(10, 2),
    date_disbursed TIMESTAMP,
    FOREIGN KEY (institution_id) REFERENCES Institution(institution_id) ON DELETE CASCADE,
    FOREIGN KEY (ward_id) REFERENCES Ward(ward_id) ON DELETE CASCADE,
    FOREIGN KEY (financial_year_id) REFERENCES FinancialYear(financial_year_id) ON DELETE CASCADE
);

CREATE TABLE UserAccount (
    user_id SERIAL PRIMARY KEY,
    national_id_no VARCHAR(200) UNIQUE NOT NULL,
    email_address VARCHAR(200) UNIQUE NOT NULL,
    password_hash VARCHAR(128) NOT NULL
);

CREATE TABLE PasswordResetToken (
    email VARCHAR(200),
    token VARCHAR(32),
    expiry_timestamp TIMESTAMP
);

-- Insert data into the Bank table
INSERT INTO Bank (bank_name) VALUES
    ('Bank A'),
    ('Bank B'),
    ('Bank C');

-- Insert data into the Institution table
INSERT INTO Institution (institution_name) VALUES
    ('Institution 1'),
    ('Institution 2'),
    ('Institution 3');

-- Insert data into the Country table
INSERT INTO Country (country_name) VALUES
    ('Country A'),
    ('Country B'),
    ('Country C');

-- Insert data into the Region table
INSERT INTO Region (country_id, region_name) VALUES
    (1, 'Region 1'),
    (2, 'Region 2'),
    (3, 'Region 3');

-- Insert data into the County table
INSERT INTO County (region_id, county_name) VALUES
    (1, 'County 1'),
    (2, 'County 2'),
    (3, 'County 3');

-- Insert data into the Constituency table
INSERT INTO Constituency (county_id, constituency_name) VALUES
    (1, 'Constituency 1'),
    (2, 'Constituency 2'),
    (3, 'Constituency 3');

-- Insert data into the Ward table
INSERT INTO Ward (constituency_id, ward_name) VALUES
    (1, 'Ward 1'),
    (2, 'Ward 2'),
    (3, 'Ward 3');

-- Insert data into the FinancialYear table
INSERT INTO FinancialYear (financial_year, financial_year_status) VALUES
    ('2022/2023', 'Open'),
    ('2023/2024', 'Closed'),
    ('2024/2025', 'Open');

-- Insert data into the UserAccount table
INSERT INTO UserAccount (national_id_no, email_address, password_hash) VALUES
    ('12345678', 'user1@example.com', 'hashed_password1'),
    ('87654321', 'user2@example.com', 'hashed_password2'),
    ('11111111', 'user3@example.com', 'hashed_password3');

-- Create a stored procedure to insert data into the Bank table
CREATE OR REPLACE PROCEDURE insert_kenyan_banks()
LANGUAGE plpgsql
AS $$
DECLARE
    bank_name_var VARCHAR(200);
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_banks_data;
        CREATE TEMP TABLE temp_banks_data (
            bank_name VARCHAR(200)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_banks_data (bank_name)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Insert data from the temporary table into the Bank table
        INSERT INTO Bank (bank_name)
        SELECT bank_name FROM temp_banks_data;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_kenyan_banks();

-- Create a stored procedure to insert data into the Institution table
CREATE OR REPLACE PROCEDURE insert_kenyan_institutions()
LANGUAGE plpgsql
AS $$
DECLARE
    institution_name_var VARCHAR(255);
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_institutions_data;
        CREATE TEMP TABLE temp_institutions_data (
            institution_name VARCHAR(255)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_institutions_data (institution_name)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Insert data from the temporary table into the Institution table
        INSERT INTO Institution (institution_name)
        SELECT institution_name FROM temp_institutions_data;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_kenyan_institutions();

-- Create a stored procedure to insert account data
CREATE OR REPLACE PROCEDURE insert_account_data()
LANGUAGE plpgsql
AS $$
DECLARE
    institution_name_var VARCHAR(255);
    bank_name_var VARCHAR(200);
    account_number_var VARCHAR(200);
    institution_id_var INT;
    bank_id_var INT;
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_accounts_data;
        CREATE TEMP TABLE temp_accounts_data (
            institution_name VARCHAR(255),
            bank_name VARCHAR(200),
            account_number VARCHAR(200)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_accounts_data (institution_name, bank_name, account_number)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Iterate over rows in the temporary table and insert data into the Account table
        FOR account_row IN (SELECT * FROM temp_accounts_data)
        LOOP
            -- Fetch institution id
            SELECT institution_id INTO institution_id_var FROM Institution WHERE institution_name = account_row.institution_name;
            IF NOT FOUND THEN
                RAISE NOTICE 'Institution "%s" not found.', account_row.institution_name;
                CONTINUE;
            END IF;

            -- Fetch bank id
            SELECT bank_id INTO bank_id_var FROM Bank WHERE bank_name = account_row.bank_name;
            IF NOT FOUND THEN
                RAISE NOTICE 'Bank "%s" not found.', account_row.bank_name;
                CONTINUE;
            END IF;

            -- Insert account data into the Account table
            INSERT INTO Account (institution_id, bank_id, account_number)
            VALUES (institution_id_var, bank_id_var, account_row.account_number);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_account_data();

-- Create a stored procedure to insert data into the Country table
CREATE OR REPLACE PROCEDURE insert_countries()
LANGUAGE plpgsql
AS $$
DECLARE
    country_name_var VARCHAR(255);
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_countries_data;
        CREATE TEMP TABLE temp_countries_data (
            country_name VARCHAR(255)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_countries_data (country_name)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Insert data from the temporary table into the Country table
        INSERT INTO Country (country_name)
        SELECT country_name FROM temp_countries_data;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_countries();

-- Create a stored procedure to insert data into the Region table
CREATE OR REPLACE PROCEDURE insert_regions()
LANGUAGE plpgsql
AS $$
DECLARE
    country_name_var VARCHAR(255);
    region_name_var VARCHAR(255);
    country_id_var INT;
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_regions_data;
        CREATE TEMP TABLE temp_regions_data (
            country_name VARCHAR(255),
            region_name VARCHAR(255)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_regions_data (country_name, region_name)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Iterate over rows in the temporary table and insert data into the Region table
        FOR region_row IN (SELECT * FROM temp_regions_data)
        LOOP
            -- Fetch country id
            SELECT country_id INTO country_id_var FROM Country WHERE country_name = region_row.country_name;
            IF NOT FOUND THEN
                RAISE NOTICE 'Country "%s" not found.', region_row.country_name;
                CONTINUE;
            END IF;

            -- Insert region data into the Region table
            INSERT INTO Region (country_id, region_name)
            VALUES (country_id_var, region_row.region_name);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_regions();

-- Create a stored procedure to insert data into the County table
CREATE OR REPLACE PROCEDURE insert_counties()
LANGUAGE plpgsql
AS $$
DECLARE
    region_name_var VARCHAR(255);
    county_name_var VARCHAR(255);
    region_id_var INT;
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_counties_data;
        CREATE TEMP TABLE temp_counties_data (
            region_name VARCHAR(255),
            county_name VARCHAR(255)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_counties_data (region_name, county_name)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Iterate over rows in the temporary table and insert data into the County table
        FOR county_row IN (SELECT * FROM temp_counties_data)
        LOOP
            -- Fetch region id
            SELECT region_id INTO region_id_var FROM Region WHERE region_name = county_row.region_name;
            IF NOT FOUND THEN
                RAISE NOTICE 'Region "%s" not found.', county_row.region_name;
                CONTINUE;
            END IF;

            -- Insert county data into the County table
            INSERT INTO County (region_id, county_name)
            VALUES (region_id_var, county_row.county_name);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_counties();

-- Create a stored procedure to insert data into the Constituency table
CREATE OR REPLACE PROCEDURE insert_constituencies()
LANGUAGE plpgsql
AS $$
DECLARE
    county_name_var VARCHAR(255);
    constituency_name_var VARCHAR(255);
    county_id_var INT;
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_constituencies_data;
        CREATE TEMP TABLE temp_constituencies_data (
            county_name VARCHAR(255),
            constituency_name VARCHAR(255)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_constituencies_data (county_name, constituency_name)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Iterate over rows in the temporary table and insert data into the Constituency table
        FOR constituency_row IN (SELECT * FROM temp_constituencies_data)
        LOOP
            -- Fetch county id
            SELECT county_id INTO county_id_var FROM County WHERE county_name = constituency_row.county_name;
            IF NOT FOUND THEN
                RAISE NOTICE 'County "%s" not found.', constituency_row.county_name;
                CONTINUE;
            END IF;

            -- Insert constituency data into the Constituency table
            INSERT INTO Constituency (county_id, constituency_name)
            VALUES (county_id_var, constituency_row.constituency_name);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_constituencies();

-- Create a stored procedure to insert data into the Ward table
CREATE OR REPLACE PROCEDURE insert_wards()
LANGUAGE plpgsql
AS $$
DECLARE
    constituency_name_var VARCHAR(255);
    ward_name_var VARCHAR(200);
    constituency_id_var INT;
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_wards_data;
        CREATE TEMP TABLE temp_wards_data (
            constituency_name VARCHAR(255),
            ward_name VARCHAR(200)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_wards_data (constituency_name, ward_name)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Iterate over rows in the temporary table and insert data into the Ward table
        FOR ward_row IN (SELECT * FROM temp_wards_data)
        LOOP
            -- Fetch constituency id
            SELECT constituency_id INTO constituency_id_var FROM Constituency WHERE constituency_name = ward_row.constituency_name;
            IF NOT FOUND THEN
                RAISE NOTICE 'Constituency "%s" not found.', ward_row.constituency_name;
                CONTINUE;
            END IF;

            -- Insert ward data into the Ward table
            INSERT INTO Ward (constituency_id, ward_name)
            VALUES (constituency_id_var, ward_row.ward_name);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_wards();

-- Create a stored procedure to insert data into the Resident table
CREATE OR REPLACE PROCEDURE insert_residents()
LANGUAGE plpgsql
AS $$
DECLARE
    ward_name_var VARCHAR(200);
    national_id_no_var VARCHAR(200);
    ward_id_var INT;
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_residents_data;
        CREATE TEMP TABLE temp_residents_data (
            national_id_no VARCHAR(200),
            ward_name VARCHAR(200)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_residents_data (national_id_no, ward_name)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Iterate over rows in the temporary table and insert data into the Resident table
        FOR resident_row IN (SELECT * FROM temp_residents_data)
        LOOP
            -- Fetch ward id
            SELECT ward_id INTO ward_id_var FROM Ward WHERE ward_name = resident_row.ward_name;
            IF NOT FOUND THEN
                RAISE NOTICE 'Ward "%s" not found.', resident_row.ward_name;
                CONTINUE;
            END IF;

            -- Insert resident data into the Resident table
            INSERT INTO Resident (national_id_no, ward_id)
            VALUES (resident_row.national_id_no, ward_id_var);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_residents();

-- Create a stored procedure to insert data into the FinancialYear table
CREATE OR REPLACE PROCEDURE insert_financial_years()
LANGUAGE plpgsql
AS $$
DECLARE
    financial_year_var VARCHAR(9);
    financial_year_status_var VARCHAR(6);
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_financial_years_data;
        CREATE TEMP TABLE temp_financial_years_data (
            financial_year VARCHAR(9),
            financial_year_status VARCHAR(6)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_financial_years_data (financial_year, financial_year_status)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Iterate over rows in the temporary table and insert data into the FinancialYear table
        FOR financial_year_row IN (SELECT * FROM temp_financial_years_data)
        LOOP
            -- Insert financial year data into the FinancialYear table
            INSERT INTO FinancialYear (financial_year, financial_year_status)
            VALUES (financial_year_row.financial_year, financial_year_row.financial_year_status);
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_financial_years();

-- Create a stored procedure to insert data into the Student table
CREATE OR REPLACE PROCEDURE insert_students()
LANGUAGE plpgsql
AS $$
DECLARE
    national_id_no_var VARCHAR(200);
    institution_name_var VARCHAR(255);
    registration_number_var VARCHAR(200);
    first_name_var VARCHAR(255);
    last_name_var VARCHAR(255);
BEGIN
    -- Load data from Excel workbook
    BEGIN
        -- Assuming path to the Excel file is known
        DROP TABLE IF EXISTS temp_students_data;
        CREATE TEMP TABLE temp_students_data (
            national_id_no VARCHAR(200),
            institution_name VARCHAR(255),
            registration_number VARCHAR(200),
            first_name VARCHAR(255),
            last_name VARCHAR(255)
        );

        -- Load data from Excel file into the temporary table
        COPY temp_students_data (national_id_no, institution_name, registration_number, first_name, last_name)
        FROM 'path_to_your_excel_file/data.xlsx' DELIMITER ',' CSV HEADER;

        -- Iterate over rows in the temporary table and insert data into the Student table
        FOR student_row IN (SELECT * FROM temp_students_data)
        LOOP
            -- Fetch institution_id based on institution_name
            DECLARE
                institution_id_var INT;
            BEGIN
                SELECT institution_id INTO institution_id_var
                FROM mashinani_institution
                WHERE institution_name = student_row.institution_name;

                -- Insert student data into the Student table
                INSERT INTO mashinani_student (national_id_no, institution_id, registration_number, first_name, last_name)
                VALUES (student_row.national_id_no, institution_id_var, student_row.registration_number, student_row.first_name, student_row.last_name);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE NOTICE 'Institution with name % not found.', student_row.institution_name;
                WHEN OTHERS THEN
                    RAISE NOTICE 'An error occurred: %', SQLERRM;
            END;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'An error occurred: %', SQLERRM;
    END;
END;
$$;

CALL insert_students();
