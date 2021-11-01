DROP TABLE IF EXISTS Employees, Junior, Booker, Senior, Manager, Health_Declaration,
Departments, Meeting_Rooms, Updates, Joins, Books, Approves CASCADE;

/*
Should we add INITIALLY DEFERRABLE IMMEDIATE to our constraints?
*/

CREATE TABLE Departments (
   did INTEGER PRIMARY KEY,
   dname varchar(50)
);
  
CREATE TABLE Employees (
   eid SERIAL,
   ename VARCHAR(50),
   email TEXT UNIQUE,
   home_num VARCHAR(50),
   mobile_num VARCHAR(50),
   office_num VARCHAR(50),
   resigned_date DATE,
   role VARCHAR(50) NOT NULL CHECK(role IN ('Junior', 'Senior', 'Manager')),
   did INTEGER NOT NULL,
   PRIMARY KEY (eid),
   FOREIGN KEY (did) REFERENCES Departments (did) ON UPDATE CASCADE
);
 
CREATE TABLE Junior (
   eid INTEGER PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES Employees (eid) ON UPDATE CASCADE
);
 
CREATE TABLE Booker (
   eid INTEGER PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES Employees (eid) ON UPDATE CASCADE 
);
 
CREATE TABLE Senior (
   eid INTEGER PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES Booker (eid) ON UPDATE CASCADE
); 
 
CREATE TABLE Manager (
   eid INTEGER PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES Booker (eid) ON UPDATE CASCADE
);
 
CREATE TABLE Health_Declaration (
    eid INTEGER REFERENCES Employees ON DELETE CASCADE,
    date DATE,
    temp NUMERIC CHECK (temp < 43 AND temp > 34),
    fever BOOLEAN,
    PRIMARY KEY (date, eid)
);
 
CREATE TABLE Meeting_Rooms (
   floor INTEGER,
   room INTEGER,
   rname varchar(50),
   did INTEGER NOT NULL REFERENCES Departments,
   PRIMARY KEY (room, floor)
);
 
 
CREATE TABLE Updates (
   date DATE,
   floor INTEGER,
   room INTEGER,
   new_cap INTEGER,
   eid INTEGER REFERENCES Manager ON DELETE CASCADE,
   PRIMARY KEY (date, room, floor),
   FOREIGN KEY (room, floor) REFERENCES Meeting_Rooms (room, floor)
);
 
CREATE TABLE Books (
   eid INTEGER NOT NULL REFERENCES Booker ON DELETE CASCADE,
   date DATE,
   time TIME, 
   room INTEGER,
   floor INTEGER,
   PRIMARY KEY(date, time, room, floor),
   FOREIGN KEY (room, floor) REFERENCES Meeting_Rooms (room, floor) ON DELETE CASCADE
);

CREATE TABLE Joins (
   eid INTEGER REFERENCES Employees ON DELETE CASCADE,
   date DATE,
   time TIME, 
   room INTEGER,
   floor INTEGER,
   PRIMARY KEY(eid, date, time, room, floor),
   FOREIGN KEY (date, time, room, floor) REFERENCES Books (date, time, room, floor)                 
   ON DELETE CASCADE
);
 
CREATE TABLE Approves (
   aid INTEGER REFERENCES Manager ON DELETE CASCADE,
   date DATE,
   time TIME,
   room INTEGER,
   floor INTEGER,
   PRIMARY KEY(date, time, room, floor),
   FOREIGN KEY (date, time, room, floor) REFERENCES Books (date, time, room, floor) ON DELETE CASCADE
);

-- 12 Tables --> 120 
/*

    ####################
    # TRIGGERS SECTION #
    ####################

*/

--FIXES 12 (WH - Tested for juniors only)
CREATE OR REPLACE FUNCTION check_only_junior() RETURNS TRIGGER AS $$
BEGIN
    -- Need to check whether is already in employee table(?)
    IF (NEW.eid IN (SELECT eid FROM Booker) 
        OR NEW.eid IN (SELECT eid FROM Senior) 
        OR NEW.eid IN (SELECT eid FROM Manager))
        THEN RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_only_is_junior
BEFORE INSERT OR UPDATE ON Junior
FOR EACH ROW
EXECUTE FUNCTION check_only_junior();


CREATE OR REPLACE FUNCTION check_only_senior() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.eid IN (SELECT eid FROM Junior) 
        OR NEW.eid IN (SELECT eid FROM Manager))
        THEN RETURN NULL;
    END IF;
    
    /*
    --If not in Booker table, void transaction or help insert?
    --Update: May be unnecessary. New function help_insert_role() will prevent empty booker
    IF (NEW.eid NOT IN (SELECT eid FROM Booker))
        THEN INSERT INTO Booker VALUES (NEW.eid);
    END IF;
    */
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_only_is_senior
BEFORE INSERT OR UPDATE ON Senior
FOR EACH ROW
EXECUTE FUNCTION check_only_senior();

CREATE OR REPLACE FUNCTION check_only_manager() RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.eid IN (SELECT eid FROM Junior) 
        OR NEW.eid IN (SELECT eid FROM Senior))
        THEN RETURN NULL;
    END IF;
    
    /*
    --If not in Booker table, void transaction or help insert?
    --Update: May be unnecessary. New function help_insert_role() will prevent empty booker
    IF (NEW.eid NOT IN (SELECT eid FROM Booker))
        THEN INSERT INTO Booker VALUES (NEW.eid);
    END IF;
    */

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_only_is_manager
BEFORE INSERT OR UPDATE ON Manager
FOR EACH ROW
EXECUTE FUNCTION check_only_manager();


/*
When user inserts into booker directly --> 
1. check not junior
2. query for role in Employees
3. add into manager/senior
*/

/*
Update weihowe: Not necessary. New trigger of help_update_role() will prevent ensures that 
EITHER 
1) Employee is a junior (prevent insertion)
2) Employee is already inserted into senior/manager (duplicated insertion into Booker)

Because it is not possible to insert into Booker a value that is not in Employee already. 
Insertion in Employee will cause help_role_insert() to be run.

CREATE OR REPLACE FUNCTION check_only_booker() RETURNS TRIGGER AS $$
DECLARE
    n_role VARCHAR(50);
BEGIN
    IF (NEW.eid IN (SELECT eid FROM Junior) OR NEW.eid NOT IN (SELECT eid FROM Employees))
        THEN RETURN NULL;
    END IF;
    
    SELECT role INTO n_role 
    FROM Employee 
    WHERE NEW.eid = eid;

    IF (role = 'Senior')
        THEN INSERT INTO Senior VALUES (NEW.eid);
    END IF;

    IF (role = 'Manager')
        THEN INSERT INTO Manager VALUES (NEW.eid);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_booker_employee_type
BEFORE INSERT OR UPDATE ON Booker
FOR EACH ROW
EXECUTE FUNCTION check_only_booker();
*/

--New function: Helps guard against manual insertion into employees (removed from proc.sql)
CREATE OR REPLACE FUNCTION help_insert_role() RETURNS TRIGGER AS $$
BEGIN
    -- For updating kind of employee

    /*
    It is necessary to check if the values exist in the corresponding tables already.
    This is in the case of remove_employee(), where UPDATE employee will be called.

    UPDATE: Should we delete entries Junior/Senior/Manager or leave it?
    */
    
    IF (NEW.role = 'Junior' AND NEW.EID NOT IN (SELECT eid FROM Junior))
    THEN INSERT INTO Junior VALUES (NEW.eid);
    END IF;
    IF (NEW.role = 'Senior' 
        AND NEW.EID NOT IN (SELECT eid FROM Senior)
        AND NEW.EID NOT IN (SELECT eid FROM Booker))
    THEN
        BEGIN
        INSERT INTO Booker VALUES (NEW.eid);
        INSERT INTO Senior VALUES (NEW.eid);
        END;
    END IF;
    IF (NEW.role = 'Manager' 
        AND NEW.EID NOT IN (SELECT eid FROM Booker)
        AND NEW.EID NOT IN (SELECT eid FROM Manager))
    THEN
        BEGIN
        INSERT INTO Booker VALUES (NEW.eid);
        INSERT INTO Manager VALUES (NEW.eid);
        END;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER help_insert_employee_role
AFTER INSERT OR UPDATE ON Employees
FOR EACH ROW
EXECUTE FUNCTION help_insert_role();

--FIXES 13 & 14
CREATE OR REPLACE FUNCTION block_junior_booking() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
BEGIN
    SELECT COUNT(*) into count
    FROM Junior
    WHERE NEW.eid = Junior.eid;

    IF count > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER junior_employee_cannot_book_room
BEFORE INSERT OR UPDATE ON Books
FOR EACH ROW
EXECUTE FUNCTION block_junior_booking();



--FIXES 16 AND 19
CREATE OR REPLACE FUNCTION block_fever_meeting()
RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
BEGIN
    SELECT COUNT(*) into count
    FROM Health_Declaration
    WHERE NEW.eid = Health_Declaration.eid 
        AND Health_Declaration.fever = true;

    IF count > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fever_cannot_book_room
BEFORE INSERT OR UPDATE ON Books
FOR EACH ROW EXECUTE FUNCTION block_fever_meeting();

CREATE TRIGGER fever_cannot_join_room
BEFORE INSERT OR UPDATE ON Joins
FOR EACH ROW EXECUTE FUNCTION block_fever_meeting();

--FIXES 18
CREATE OR REPLACE FUNCTION booker_joins_meeting() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Joins VALUES (NEW.eid, NEW.date, NEW.time, NEW.room, NEW.floor);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER the_booker_must_join_meeting
AFTER INSERT OR UPDATE ON Books
FOR EACH ROW EXECUTE FUNCTION booker_joins_meeting();

--FIXES 21
CREATE OR REPLACE FUNCTION block_outsiders_approval() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
BEGIN
    SELECT COUNT(*) into count
    FROM Employees, Meeting_Rooms
    WHERE NEW.eid = Employees.eid 
        AND NEW.date = Meeting_Rooms.date 
        AND NEW.time = Meeting_Rooms.time
        AND NEW.room = Meeting_Rooms.room 
        AND NEW.floor = Meeting_Rooms.floor
        AND Employees.did = Meeting_Rooms.did;

    IF count > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER approval_only_from_same_department
BEFORE INSERT OR UPDATE ON Approves
FOR EACH ROW EXECUTE FUNCTION block_outsiders_approval();

--FIXES 23
CREATE OR REPLACE FUNCTION block_changes_after_approval() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
BEGIN
    SELECT COUNT(*) into count
    FROM Approves
    WHERE NEW.date = Approves.date 
        AND NEW.time = Approves.time 
        AND NEW.room = Approves.room
        AND NEW.floor = Approves.floor;

    IF count > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_updates_on_joins_after_approval
BEFORE INSERT OR UPDATE ON Joins
FOR EACH ROW EXECUTE FUNCTION block_changes_after_approval();

--FIXES 24
CREATE OR REPLACE FUNCTION check_dept_before_update_capacity() RETURNS TRIGGER AS $$
BEGIN
    IF ((SELECT did FROM Employees e WHERE e.eid = NEW.eid) NOT IN 
    (SELECT did FROM Meeting_Rooms m WHERE m.room = NEW.room AND m.floor = NEW.floor))
    THEN RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER only_same_dept_update_capacity
BEFORE INSERT OR UPDATE ON Updates
FOR EACH ROW
EXECUTE FUNCTION check_dept_before_update_capacity();


/*
       ############################################
       # Missing IF condition for contact_tracing #
       ############################################
*/

CREATE OR REPLACE FUNCTION block_leaving_after_approval() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
    is_fever BOOLEAN;
BEGIN
    SELECT fever INTO is_fever
    FROM Health_Declaration
    WHERE OLD.eid = Health_Declaration.eid;

    IF is_fever = true THEN
        RETURN NEW;
    ELSE
        SELECT COUNT(*) into count
        FROM Approves
        WHERE OLD.date = Approves.date
            AND OLD.time = Approves.time
            AND OLD.room = Approves.room
            AND OLD.floor = Approves.floor;

        IF count > 0 THEN
            RETURN NULL;
        ELSE
            RETURN NEW;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_deletes_on_joins_after_approval_unless_fever
BEFORE DELETE ON Joins
FOR EACH ROW EXECUTE FUNCTION block_leaving_after_approval();


--FIXES 25
CREATE OR REPLACE FUNCTION block_book_past_meetings() 
RETURNS TRIGGER AS $$
BEGIN
    IF CURRENT_DATE > NEW.date THEN
        RETURN NULL;
    ELSIF CURRENT_DATE = NEW.date 
        AND LOCALTIME > NEW.time THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cannot_book_past_meeting
BEFORE INSERT OR UPDATE ON Books
FOR EACH ROW EXECUTE FUNCTION block_book_past_meetings();

--FIXES 26
CREATE OR REPLACE FUNCTION block_join_past_meetings() 
RETURNS TRIGGER AS $$
BEGIN
    IF CURRENT_DATE > NEW.date THEN
        RETURN NULL;
    ELSIF CURRENT_DATE = NEW.date 
        AND LOCALTIME > NEW.time THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cannot_book_past_meeting
BEFORE INSERT OR UPDATE ON Joins
FOR EACH ROW EXECUTE FUNCTION block_join_past_meetings();

--FIXES 27
CREATE OR REPLACE FUNCTION block_approve_past_meetings() 
RETURNS TRIGGER AS $$
BEGIN
    IF CURRENT_DATE > NEW.date THEN
        RETURN NULL;
    ELSIF CURRENT_DATE = NEW.date 
        AND LOCALTIME > NEW.time THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER cannot_approve_past_meeting
BEFORE INSERT OR UPDATE ON Approves
FOR EACH ROW EXECUTE FUNCTION block_approve_past_meetings();



--FIXES 34
CREATE OR REPLACE FUNCTION block_resigned_employees() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
BEGIN
    SELECT COUNT(*) into count
    FROM Employees
    WHERE NEW.eid = Employees.eid 
        AND Employees.resigned_date IS NOT NULL;

    IF count > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER a_resigned_employee_cannot_join
BEFORE INSERT OR UPDATE ON Joins
FOR EACH ROW EXECUTE FUNCTION block_resigned_employees();

CREATE TRIGGER a_resigned_employee_cannot_approve
BEFORE INSERT OR UPDATE ON Approves
FOR EACH ROW EXECUTE FUNCTION block_resigned_employees();


/* FIXES Requirement:
All future records(Books) should be removed when employee resigns
assume they will not join future meeting
*/
CREATE OR REPLACE FUNCTION remove_future_records()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM Books 
    WHERE Books.eid = NEW.eid
        AND Books.date >= NEW.resigned_date;
    --Do not need to account for joins and approval as they
    -- are automatically deleted under FK Constraint
END;
$$LANGUAGE plpgsql;

--Trigger is activated when employee resigned_date is changed
CREATE TRIGGER resigned_employee_removed
AFTER UPDATE ON Employees
FOR EACH ROW
EXECUTE FUNCTION remove_future_records();

/* FIXES Requirement:
Checks that all employees under the department have been removed (resign_date IS NOT NULL) when department is deleted.
BEFORE DELETE
*/
CREATE OR REPLACE FUNCTION check_remove_department()
RETURNS TRIGGER AS $$
DECLARE
    count numeric;
BEGIN
    SELECT COUNT(*) AS count
    FROM Employees
    WHERE Employees.did = OLD.did
        AND resigned_date IS NOT NULL;

    IF (count > 0) -- there is an employee which is still under the department and not resigned
        RETURN NULL; -- PREVENT DELETE
    ELSE
        RETURN OLD;
    END IF;
END;
$$LANGUAGE plpgsql

CREATE TRIGGER remove_department_check
BEFORE DELETE ON Departments
FOR EACH ROW
EXECUTE FUNCTION check_remove_department();


/* FIXES Requirement:
When a meeting room has its capacity changed, any room booking after the change date with more participants 
(including the employee who made the booking) will automatically be removed. This is regardless of whether they are approved or not.
*/


/* FIXES Requirement:
Prevents Employees from joining multiple meetings at the same time if it complicates contact tracing
*/