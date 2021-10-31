DROP TABLE IF EXISTS Employees, Junior, Booker, Senior, Manager, Health_Declaration,
Departments, Meeting_Rooms, Updates, Joins, Books, Approves CASCADE;

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
   role VARCHAR(50) NOT NULL,
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

/*

    ####################
    # TRIGGERS SECTION #
    ####################

*/


--FIXES 12
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
CREATE OR REPLACE FUNCTION block_fever_meeting() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
BEGIN
    SELECT COUNT(*) into count
    FROM Health_Declaration
    WHERE NEW.eid = Health_Declaration.eid AND Health_Declaration.fever = true;

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
    WHERE NEW.eid = Employees.eid AND NEW.date = Meeting_Rooms.date AND NEW.time = Meeting_Rooms.time
    AND NEW.room = Meeting_Rooms.room AND NEW.floor = Meeting_Rooms.floor
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
/*
--FIXES 23
CREATE OR REPLACE FUNCTION block_changes_after_approval() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
BEGIN
    SELECT COUNT(*) into count
    FROM Approves
    WHERE NEW.date = Approves.date AND NEW.time = Approves.time AND NEW.room = Approves.room
    AND NEW.floor = Approves.floor

    IF count > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION block_deletes_after_approval() RETURNS TRIGGER AS $$
DECLARE
    count NUMERIC;
BEGIN
    SELECT COUNT(*) into count
    FROM Approves
    WHERE OLD.date = Approves.date AND OLD.time = Approves.time AND OLD.room = Approves.room
    AND OLD.floor = Approves.floor

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

CREATE TRIGGER no_deletes_on_joins_after_approval
BEFORE DELETE ON Joins
FOR EACH ROW EXECUTE FUNCTION block_leaving_after_approval();

*/

--FIXES 25
CREATE OR REPLACE FUNCTION block_book_past_meetings() RETURNS TRIGGER AS $$
DECLARE 
current_time := SELECT CONVERT (TIME, CURRENT_TIMESTAMP);
current_date := Convert(date, getdate());
BEGIN
    IF current_date > NEW.date THEN
        RETURN NULL;
    ELSE IF current_date = NEW.date AND current_time > NEW.time THEN
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
CREATE OR REPLACE FUNCTION block_join_past_meetings() RETURNS TRIGGER AS $$
DECLARE 
current_time := SELECT CONVERT (TIME, CURRENT_TIMESTAMP);
current_date := Convert(date, getdate());
BEGIN
    IF current_date > NEW.date THEN
        RETURN NULL;
    ELSE IF current_date = NEW.date AND current_time > NEW.time THEN
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
CREATE OR REPLACE FUNCTION block_approve_past_meetings() RETURNS TRIGGER AS $$
DECLARE 
current_time := SELECT CONVERT (TIME, CURRENT_TIMESTAMP);
current_date := Convert(date, getdate());
BEGIN
    IF current_date > NEW.date THEN
        RETURN NULL;
    ELSE IF current_date = NEW.date AND current_time > NEW.time THEN
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
    WHERE NEW.eid = Employees.eid AND Employees.resigned_date IS NOT NULL;

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

