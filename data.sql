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
    SELECT return_latest_capacity_before_input_date(NEW.floor, NEW.room, NEW.date) INTO max_capacity;
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
    AND Updates.room = NEW.room
    AND Updates.date < NEW.date;

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

--Prevents multiple bookings on same meeting room slot
CREATE OR REPLACE FUNCTION block_multiple_booking() RETURNS TRIGGER AS $$
DECLARE
    count numeric;
BEGIN
    SELECT COUNT(*) into count
    FROM Books
    WHERE NEW.floor = Books.floor
    AND NEW.room = Books.room
    AND NEW.date = Books.date
    AND NEW.time = Books.time;

    IF count > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER multiple_booking_on_meeting_slot
BEFORE INSERT OR UPDATE ON Books
FOR EACH ROW EXECUTE FUNCTION block_multiple_booking();

--Prevents same guy making multiple bookings at same time
CREATE OR REPLACE FUNCTION block_same_time_booking() RETURNS TRIGGER AS $$
DECLARE
    count numeric;
BEGIN
    SELECT COUNT(*) into count
    FROM Books
    WHERE NEW.eid = Books.eid
    AND NEW.date = Books.date
    AND NEW.time = Books.time;

    IF count > 0 THEN
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER same_guy_booking_multiple_rooms_concurrently
BEFORE INSERT OR UPDATE ON Books
FOR EACH ROW EXECUTE FUNCTION block_same_time_booking();

--Prevents approve on empty meeting
CREATE OR REPLACE FUNCTION block_approve_empty_meeting() RETURNS TRIGGER AS $$
DECLARE
    employee_count numeric;
BEGIN
    SELECT COUNT(*) INTO employee_count
    FROM Joins
    WHERE NEW.floor = Joins.floor
    AND NEW.room = Joins.room
    AND NEW.date = Joins.date
    AND NEW.time = Joins.time;

    IF employee_count > 0 THEN
        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER approving_empty_meeting
BEFORE INSERT OR UPDATE ON Approves
FOR EACH ROW EXECUTE FUNCTION block_approve_empty_meeting();

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
    book_count NUMERIC;
    count NUMERIC;
    is_fever BOOLEAN;
BEGIN
    SELECT fever INTO is_fever
    FROM Health_Declaration
    WHERE OLD.eid = Health_Declaration.eid;

    SELECT COUNT(*) into book_count
        FROM Books
        WHERE OLD.date = Books.date
        AND OLD.time = Books.time
        AND OLD.room = Books.room
        AND OLD.floor = Books.floor;

    IF is_fever = true THEN
        RETURN OLD;
    ELSIF book_count = 0
        THEN RETURN OLD;
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

CREATE TRIGGER a_resigned_employee_cannot_book
BEFORE INSERT OR UPDATE ON Books
FOR EACH ROW EXECUTE FUNCTION block_resigned_employees();

CREATE TRIGGER a_resigned_employee_cannot_update
BEFORE INSERT OR UPDATE ON Updates
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


CREATE OR REPLACE FUNCTION block_other_days_hd()
RETURNS TRIGGER AS $$
BEGIN
    IF(NEW.date <> CURRENT_DATE)
        THEN RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER health_declaration_only_today
BEFORE INSERT OR UPDATE ON Health_Declaration
FOR EACH ROW EXECUTE FUNCTION block_other_days_hd();

/* FIXES Requirement:
Prevents Update on meeting_room where date is in the past as that would cause all meeting
records to be lost.

*/

CREATE OR REPLACE FUNCTION block_past_updates()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.date < CURRENT_DATE)
        THEN RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER only_future_updates
BEFORE INSERT OR UPDATE ON Updates
FOR EACH ROW
EXECUTE FUNCTION block_past_updates();




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
Assumes that all updates will be made "today"
Need to find entry in updates where updates.date > New.date
*/

CREATE OR REPLACE FUNCTION delete_over_capacity_meetings()
RETURNS TRIGGER AS $$
DECLARE
    upper_cap_date DATE;
BEGIN
    SELECT MIN(date) INTO upper_cap_date
    FROM Updates
    WHERE Updates.date > NEW.date;

    WITH number_of_people_booked AS (
      SELECT floor, room, date, time, COUNT(*) as attendees
          FROM Joins
          WHERE Joins.date > New.date
                AND Joins.date <= upper_cap_date
          GROUP BY floor, room, date, time
          HAVING COUNT(*) > NEW.new_cap
    )

    DELETE FROM Books using number_of_people_booked as N
    WHERE Books.floor = N.floor
        AND Books.room = N.room
        AND Books.date = N.date
        AND Books.time = N.time;
    
    RETURN NULL;
        
END;
$$LANGUAGE plpgsql;


CREATE TRIGGER enforce_meeting_capacity
AFTER INSERT OR UPDATE ON Updates
FOR EACH ROW
EXECUTE FUNCTION delete_over_capacity_meetings();

--Prevent users from being allocated to department 0 if they are not resigned
CREATE OR REPLACE FUNCTION block_unresigned_employees()
RETURNS TRIGGER AS $$
BEGIN
    IF(NEW.resigned_date IS NULL
        AND NEW.did = 0)
        THEN RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER check_resigned_status
BEFORE INSERT OR UPDATE ON Employees
FOR EACH ROW
EXECUTE FUNCTION block_unresigned_employees();

/* FIXES Requirement:
Prevents Employees from joining multiple meetings at the same time if it complicates contact tracing
*/
CREATE OR REPLACE FUNCTION prevent_joining_meeting() RETURNS TRIGGER AS $$
BEGIN
    -- Already in another meeting
    IF ((NEW.eid, NEW.date, NEW.time) IN (SELECT eid, date, time FROM Joins)) 
        THEN RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_multiple_meetings
BEFORE INSERT OR UPDATE ON JOINS
FOR EACH ROW
EXECUTE FUNCTION prevent_joining_meeting();

-- Manual insertions
/*
Department constraint -> Department 0 is reserved for Resigned employees whose department has been deleted.
*/

--Departments
insert into Departments (did, dname) values (0, 'Department deleted after Resignation');
insert into Departments (did, dname) values (1, 'Product Management');
insert into Departments (did, dname) values (2, 'Legal');
insert into Departments (did, dname) values (3, 'Training');
insert into Departments (did, dname) values (4, 'Human Resources');
insert into Departments (did, dname) values (5, 'Services');
insert into Departments (did, dname) values (6, 'Accounting');
insert into Departments (did, dname) values (7, 'Product Management');
insert into Departments (did, dname) values (8, 'Research and Development');
insert into Departments (did, dname) values (9, 'Services');
insert into Departments (did, dname) values (10, 'Engineering');
insert into Departments (did, dname) values (11, 'Human Resources');
insert into Departments (did, dname) values (12, 'Human Resources');
insert into Departments (did, dname) values (13, 'Product Management');
insert into Departments (did, dname) values (14, 'Sales');
insert into Departments (did, dname) values (15, 'Research and Development');

--Employees
insert into Employees (ename, email, mobile_num, role, did) values ('Harmon', 'hsalmons0@about.com', '228-522-9018', 'Junior', 2);
insert into Employees (ename, email, mobile_num, role, did) values ('Phelia', 'pfrain1@ustream.tv', '267-458-8830', 'Senior', 12);
insert into Employees (ename, email, mobile_num, role, did) values ('Carlie', 'cchuter2@yolasite.com', '209-753-9805', 'Senior', 13);
insert into Employees (ename, email, mobile_num, role, did) values ('Darcy', 'dgoracci3@nymag.com', '292-756-6824', 'Manager', 1);
insert into Employees (ename, email, mobile_num, role, did) values ('Carlen', 'cmcrobb4@shutterfly.com', '518-799-1538', 'Junior', 9);
insert into Employees (ename, email, mobile_num, role, did) values ('Oliy', 'omcgifford5@foxnews.com', '107-139-2328', 'Senior', 8);
insert into Employees (ename, email, mobile_num, role, did) values ('Louie', 'lvaughanhughes6@so-net.ne.jp', '972-606-7549', 'Senior', 9);
insert into Employees (ename, email, mobile_num, role, did) values ('Debra', 'djane7@patch.com', '333-831-1507', 'Junior', 12);
insert into Employees (ename, email, mobile_num, role, did) values ('Conrado', 'cotley8@rakuten.co.jp', '670-264-7373', 'Senior', 11);
insert into Employees (ename, email, mobile_num, role, did) values ('Yul', 'ymacknocker9@g.co', '544-211-6100', 'Junior', 2);
insert into Employees (ename, email, mobile_num, role, did) values ('Sim', 'sgrestiea@jimdo.com', '930-123-1582', 'Manager', 6);
insert into Employees (ename, email, mobile_num, role, did) values ('Albie', 'aalimanb@nbcnews.com', '142-157-9418', 'Junior', 8);
insert into Employees (ename, email, mobile_num, role, did) values ('Guenevere', 'griccac@wordpress.org', '148-403-7184', 'Junior', 14);
insert into Employees (ename, email, mobile_num, role, did) values ('Conny', 'cboerderd@github.com', '722-203-4289', 'Manager', 6);
insert into Employees (ename, email, mobile_num, role, did) values ('Tab', 'tvallerinee@prnewswire.com', '299-853-0573', 'Junior', 12);
insert into Employees (ename, email, mobile_num, role, did) values ('Rodrick', 'rizatf@wikipedia.org', '820-586-3017', 'Junior', 1);
insert into Employees (ename, email, mobile_num, role, did) values ('Leontyne', 'lpateg@yolasite.com', '426-698-5089', 'Junior', 14);
insert into Employees (ename, email, mobile_num, role, did) values ('Estella', 'ebarnetth@engadget.com', '322-712-9156', 'Manager', 6);
insert into Employees (ename, email, mobile_num, role, did) values ('Elisha', 'ewandeni@reuters.com', '561-696-4695', 'Junior', 12);
insert into Employees (ename, email, mobile_num, role, did) values ('Gavra', 'gcommonj@prweb.com', '117-773-0040', 'Senior', 5);
insert into Employees (ename, email, mobile_num, role, did) values ('Tonye', 'tgrunwaldk@technorati.com', '965-153-0237', 'Senior', 2);
insert into Employees (ename, email, mobile_num, role, did) values ('Faunie', 'fbudnkl@slate.com', '272-701-0076', 'Junior', 12);
insert into Employees (ename, email, mobile_num, role, did) values ('Samantha', 'sbaudichonm@phpbb.com', '313-753-1584', 'Senior', 1);
insert into Employees (ename, email, mobile_num, role, did) values ('Abey', 'ahigbinn@domainmarket.com', '184-586-6133', 'Manager', 6);
insert into Employees (ename, email, mobile_num, role, did) values ('Adrian', 'astandbrookeo@weibo.com', '808-667-8434', 'Junior', 5);
insert into Employees (ename, email, mobile_num, role, did) values ('Hanson', 'hventomp@theatlantic.com', '963-790-0271', 'Senior', 13);
insert into Employees (ename, email, mobile_num, role, did) values ('Guillaume', 'gcatheeq@shutterfly.com', '205-699-9944', 'Junior', 4);
insert into Employees (ename, email, mobile_num, role, did) values ('Sonnie', 'sdevonsr@last.fm', '820-459-8958', 'Junior', 12);
insert into Employees (ename, email, mobile_num, role, did) values ('Thia', 'tkillwicks@reverbnation.com', '559-109-0662', 'Senior', 9);
insert into Employees (ename, email, mobile_num, role, did) values ('Scottie', 'solubyt@fc2.com', '872-427-7550', 'Junior', 3);
insert into Employees (ename, email, mobile_num, role, did) values ('Kelvin', 'kbulpittu@businessweek.com', '162-758-4470', 'Senior', 6);
insert into Employees (ename, email, mobile_num, role, did) values ('Porty', 'pfullerlovev@jalbum.net', '237-149-0621', 'Manager', 12);
insert into Employees (ename, email, mobile_num, role, did) values ('Misti', 'mhurstw@desdev.cn', '184-941-8179', 'Senior', 11);
insert into Employees (ename, email, mobile_num, role, did) values ('Nowell', 'njorisx@yellowpages.com', '732-279-7175', 'Junior', 15);
insert into Employees (ename, email, mobile_num, role, did) values ('Danika', 'dcraggy@marketwatch.com', '363-495-9170', 'Manager', 7);
insert into Employees (ename, email, mobile_num, role, did) values ('Marysa', 'mgreatbankz@paginegialle.it', '984-738-4096', 'Junior', 8);
insert into Employees (ename, email, mobile_num, role, did) values ('Astrix', 'akinson10@answers.com', '939-705-0389', 'Senior', 10);
insert into Employees (ename, email, mobile_num, role, did) values ('Mile', 'mclempton11@istockphoto.com', '440-254-1188', 'Senior', 4);
insert into Employees (ename, email, mobile_num, role, did) values ('Ted', 'tfabb12@thetimes.co.uk', '604-383-2945', 'Junior', 10);
insert into Employees (ename, email, mobile_num, role, did) values ('Ailbert', 'amarlon13@latimes.com', '618-542-3680', 'Senior', 11);
insert into Employees (ename, email, mobile_num, role, did) values ('Mabel', 'mcheake14@google.es', '632-240-3577', 'Junior', 2);
insert into Employees (ename, email, mobile_num, role, did) values ('Eyde', 'enowakowski15@prlog.org', '609-148-7900', 'Junior', 3);
insert into Employees (ename, email, mobile_num, role, did) values ('Dion', 'dsouthway16@tinyurl.com', '518-521-4318', 'Senior', 11);
insert into Employees (ename, email, mobile_num, role, did) values ('Bondy', 'brubenovic17@reddit.com', '395-331-8144', 'Junior', 3);
insert into Employees (ename, email, mobile_num, role, did) values ('Linzy', 'lmcgettrick18@joomla.org', '890-109-7554', 'Junior', 9);
insert into Employees (ename, email, mobile_num, role, did) values ('Gabriel', 'ginold19@jalbum.net', '158-407-5909', 'Senior', 6);
insert into Employees (ename, email, mobile_num, role, did) values ('Boony', 'bdot1a@odnoklassniki.ru', '303-402-9208', 'Senior', 3);
insert into Employees (ename, email, mobile_num, role, did) values ('Rem', 'rkemson1b@oakley.com', '442-660-0095', 'Manager', 1);
insert into Employees (ename, email, mobile_num, role, did) values ('Meryl', 'mnorbury1c@bluehost.com', '183-753-4531', 'Manager', 6);
insert into Employees (ename, email, mobile_num, role, did) values ('Julieta', 'jebourne1d@ning.com', '620-542-6070', 'Manager', 11);
 
/*
Juniors:  5 8 12 13 15 16 17 19 22 25 27 28 30 34 36 39 42 44 45 1 10 41
Seniors:  2 3 6 7 9 20 23 26 29 31 33 37 38 40 43 46 47 21
Managers:  4 11 14 18 24 32 35 48 49 50
*/

--Meeting_Rooms
INSERT INTO Meeting_Rooms (floor,room, rname ,did)
VALUES
  (1,1,'Germany',1),
  (1,2,'Portugal',6),
  (1,3,'Zimbabwe',6),
  (2,1,'Italy',7),
  (2,2,'United States',11),
  (2,6,'Ireland',7),
  (2,7,'France',7),
  (4,7,'Sweden',11),
  (5,6,'Ireland',6),
  (7,1,'Spain',1);

INSERT INTO Updates (date, floor, room, new_cap, eid)
VALUES
    (CURRENT_DATE, 1, 1, 10, 4),
    (CURRENT_DATE, 1, 2, 5, 11),
    (CURRENT_DATE, 1, 3, 5, 11),
    (CURRENT_DATE, 2, 1, 5, 35),
    (CURRENT_DATE, 2, 2, 5, 50),
    (CURRENT_DATE, 2, 6, 5, 35),
    (CURRENT_DATE, 2, 7, 5, 35),
    (CURRENT_DATE, 5, 6, 5, 11),
    (CURRENT_DATE, 4, 7, 5, 50),
    (CURRENT_DATE, 7, 1, 10, 4);

-- --Books
insert into Books (eid, date, time, floor, room) values (3, '2022-01-01', '01:00:00', 4, 7); --senior books
insert into Books (eid, date, time, floor, room) values (4, '2022-01-01', '01:00:00', 5, 6); --manager books
insert into Books (eid, date, time, floor, room) values (6, '2022-01-01', '01:00:00', 2, 6); --senior books
insert into Books (eid, date, time, floor, room) values (7, '2022-01-01', '01:00:00', 7, 1); --senior books
-- --auto join trigger works for bookers

-- --Joins
insert into Joins (eid, date, time, floor, room) values (8, '2022-01-01', '01:00:00', 4, 7);
insert into Joins (eid, date, time, floor, room) values (9, '2022-01-01', '01:00:00', 5, 6);
insert into Joins (eid, date, time, floor, room) values (10, '2022-01-01', '01:00:00', 2, 6);
insert into Joins (eid, date, time, floor, room) values (5, '2022-01-01', '01:00:00', 7, 1);

--Approves
insert into Approves (aid, date, time, floor, room) values (11, '2022-01-01', '01:00:00', 5, 6); --manager approves
insert into Approves (aid, date, time, floor, room) values (4, '2022-01-01', '01:00:00', 7, 1); --manager approves
