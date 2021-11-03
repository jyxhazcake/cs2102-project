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
   did INTEGER NOT NULL DEFAULT 0,
   PRIMARY KEY (eid),
   FOREIGN KEY (did) REFERENCES Departments (did) ON UPDATE CASCADE ON DELETE SET DEFAULT
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
   floor INTEGER,
   room INTEGER,
   PRIMARY KEY(date, time, floor, room),
   FOREIGN KEY (room, floor) REFERENCES Meeting_Rooms (room, floor) ON DELETE CASCADE
);

CREATE TABLE Joins (
   eid INTEGER REFERENCES Employees ON DELETE CASCADE,
   date DATE,
   time TIME, 
   floor INTEGER,
   room INTEGER,
   PRIMARY KEY(eid, date, time, floor, room),
   FOREIGN KEY (date, time, floor, room) REFERENCES Books (date, time, floor, room) ON DELETE CASCADE
);
 
CREATE TABLE Approves (
   aid INTEGER REFERENCES Manager ON DELETE CASCADE,
   date DATE,
   time TIME,
   floor INTEGER,
   room INTEGER,
   PRIMARY KEY(date, time, floor, room),
   FOREIGN KEY (date, time, floor, room) REFERENCES Books (date, time, floor, room) ON DELETE CASCADE
);


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

-- ************ Works in preventing insertion of senior employee into manager and junior ********************
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

-- ************ Works in preventing insertion of manager employee into senior and junior ********************
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

CREATE OR REPLACE FUNCTION check_only_booker() RETURNS TRIGGER AS $$
DECLARE
    n_role VARCHAR(50);
BEGIN
    IF (NEW.eid IN (SELECT eid FROM Junior))
        THEN RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_booker_employee_type
BEFORE INSERT OR UPDATE ON Booker
FOR EACH ROW
EXECUTE FUNCTION check_only_booker();


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


/*
Jon
*/
--Prevents joins on full room
CREATE OR REPLACE FUNCTION block_join_on_full_room() RETURNS TRIGGER AS $$
DECLARE
    max_capacity INTEGER;
    current_capacity INTEGER;
    available_capacity INTEGER;
BEGIN
    SELECT return_latest_capacity(NEW.floor, NEW.room) INTO max_capacity;
    SELECT COUNT(*) INTO current_capacity
    FROM Joins
    WHERE NEW.floor = Joins.floor
    AND NEW.room = Joins.room
    AND NEW.date = Joins.date
    AND NEW.time = Joins.time;
    available_capacity:= max_capacity - current_capacity;

    IF available_capacity > 0 THEN
        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fully_joined_room
BEFORE INSERT ON Joins
FOR EACH ROW EXECUTE FUNCTION block_join_on_full_room();

--Prevents booking on room without capacity
CREATE OR REPLACE FUNCTION block_room_booking_without_capacity() RETURNS TRIGGER AS $$
DECLARE
    capacity_declared NUMERIC;
BEGIN
    SELECT COUNT(*) into capacity_declared
    FROM Updates
    WHERE Updates.floor = NEW.floor
    AND Updates.room = NEW.room;

    IF capacity_declared > 0 THEN
        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER booking_room_with_no_capacity
BEFORE INSERT OR UPDATE ON Books
FOR EACH ROW EXECUTE FUNCTION block_room_booking_without_capacity();

--FIXES 13 & 14
-- Prevents a junior employee from booking a meeting
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
    AND Health_Declaration.fever = true
    AND CURRENT_DATE = Health_Declaration.date;

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
    INSERT INTO Joins VALUES (NEW.eid, NEW.date, NEW.time, NEW.floor, NEW.room);
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
    FROM Employees, Books, Meeting_Rooms
    WHERE NEW.aid = Employees.eid --approver is part of employees
        AND NEW.date = Books.date --approved date is booked date
        AND NEW.time = Books.time --approved time is booked time
        AND NEW.room = Books.room --approved room is booked room
        AND NEW.floor = Books.floor --approved floor is booked floor
        AND NEW.room = Meeting_Rooms.room
        AND NEW.floor = Meeting_Rooms.floor --approved room exists
        AND Employees.did = Meeting_Rooms.did; --approver did matches approved room did

    IF count > 0 THEN
        RETURN NEW;
    ELSE
        RETURN NULL;
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


CREATE OR REPLACE FUNCTION block_leaving_after_approval() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
    is_fever BOOLEAN;
BEGIN
    SELECT fever INTO is_fever
    FROM Health_Declaration
    WHERE OLD.eid = Health_Declaration.eid;

    IF is_fever = true THEN
        RETURN OLD;
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
            RETURN OLD;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER no_deletes_on_joins_after_approval_unless_fever
BEFORE DELETE ON Joins
FOR EACH ROW EXECUTE FUNCTION block_leaving_after_approval();

/*
Jim
*/


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

CREATE OR REPLACE FUNCTION block_resigned_managers() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
BEGIN
    SELECT COUNT(*) into count
    FROM Employees
    WHERE NEW.aid = Employees.eid
        AND Employees.resigned_date IS NOT NULL;

    IF count > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER a_resigned_employee_cannot_approve
BEFORE INSERT OR UPDATE ON Approves
FOR EACH ROW EXECUTE FUNCTION block_resigned_managers();


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
    --are automatically deleted under FK Constraint

    DELETE FROM approves
    WHERE approves.aid = NEW.eid
        AND approves.date >= NEW.resigned_date;

    RETURN NULL;
END;
$$LANGUAGE plpgsql;

--Trigger is activated when employee resigned_date is changed
CREATE TRIGGER resigned_employee_removed
AFTER UPDATE ON Employees
FOR EACH ROW WHEN (New.resigned_date IS NOT NULL)
EXECUTE FUNCTION remove_future_records();

/* FIXES Requirement:
Checks that all employees under the department have been removed (resign_date IS NOT NULL) when department is deleted.
BEFORE DELETE
-> Change the did of resigned_employees to another placeholder 
*/
CREATE OR REPLACE FUNCTION check_remove_department()
RETURNS TRIGGER AS $$
DECLARE
    count numeric;
BEGIN
    SELECT COUNT(*) INTO count
    FROM Employees
    WHERE Employees.did = OLD.did
        AND resigned_date IS NULL;

    IF (count > 0) -- there is an employee which is still under the department and not resigned
        THEN RETURN NULL; -- PREVENT DELETE
    ELSE
        RETURN OLD;
    END IF;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER remove_department_check
BEFORE DELETE ON Departments
FOR EACH ROW
EXECUTE FUNCTION check_remove_department();

--PREVENT NON-HOURLY INPUTS
CREATE OR REPLACE FUNCTION block_non_hourly_input() RETURNS TRIGGER AS $$
DECLARE
    number_of_minutes INTEGER;
    number_of_seconds INTEGER;
BEGIN
    SELECT EXTRACT (MINUTE FROM NEW.time) INTO number_of_minutes;
    SELECT EXTRACT (SECOND FROM NEW.time) INTO number_of_seconds;
    IF number_of_minutes > 0 THEN
        RETURN NULL;
    ELSIF number_of_seconds > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER only_hourly_input
BEFORE INSERT OR UPDATE ON Books
FOR EACH ROW EXECUTE FUNCTION block_non_hourly_input();

CREATE TRIGGER only_hourly_input
BEFORE INSERT OR UPDATE ON Joins
FOR EACH ROW EXECUTE FUNCTION block_non_hourly_input();

CREATE TRIGGER only_hourly_input
BEFORE INSERT OR UPDATE ON Approves
FOR EACH ROW EXECUTE FUNCTION block_non_hourly_input();


/* FIXES Requirement:
When a meeting room has its capacity changed --> INSERT INTO Updates,
any room booking after the change date with more participants (including the employee who made the booking) will automatically be removed. 
--> SELECT floor, room, date, time, COUNT(*)
    FROM Booking as B Join Joins as J
    ON B date, time, room, floor == J
        AND date >= Updates
    GROUP BY floor, room, date, time
remove_booking;
This is regardless of whether they are approved or not.
*/


/* FIXES Requirement:
Prevents Employees from joining multiple meetings at the same time if it complicates contact tracing
*/
