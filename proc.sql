/* 
    ###################
    # Wei Howe's Code #
    ###################  */

CREATE OR REPLACE FUNCTION add_employee
    -- This assumes that the employee will always have minimally a mobilenum
    (IN e_name VARCHAR(50), IN mobilenum VARCHAR(50), IN kind VARCHAR(50), IN d_id INTEGER)
RETURN VOID AS $$
DECLARE 
new_eid INTEGER:= 0;
new_email VARCHAR(50):= "@demo_company.com"
BEGIN
    
    -- Should we assume that the departments will always exist first before adding an employee?
    -- We probably need a trigger, else we can't insert both the d_id as well as the name for department
    IF NOT EXISTS (SELECT 1 FROM Departments WHERE did = d_id)
    THEN INSERT INTO Department ...

    new_eid:= SELECT max(id) FROM Employees;
    new_eid:= new_eid + 1;
    new_email:= CONCAT(CAST(new_eid AS VARCHAR(50)), new_email);
    
    -- How to insert multiple values for mobile num/ home num?
    -- Is there a better way of generating the eid than using AUTOINCREMENT?
    INSERT INTO Employees(ename, mobile_num, email, did)
    VALUES (e_name, mobilenum, new_email, d_id);
    
    
    -- For updating kind of employee
    IF kind = 'junior'
    THEN INSERT INTO Junior VALUES new_eid;
    IF kind = 'senior'
        BEGIN
        INSERT INTO Senior VALUES new_eid;
        INSERT INTO Booker VALUES new_eid;
        END
    IF kind = 'manager'
        BEGIN
        THEN INSERT INTO Manager VALUES new_eid;
        INSERT INTO Booker VALUES new_eid;
        END
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION remove_employee
    (IN e_id INTEGER, IN resign_d DATE)
RETURN VOID AS $$
BEGIN
    UPDATE Employee
    SET resigned_date = resign_d
    WHERE eid = e_id;
END;
-- should the langage just be psql?
$$LANGUAGE plpgsql

CREATE OR REPLACE FUNCTION view_future_meeting
    (IN start_date DATE, IN e_id INTEGER)
RETURN TABLE (date DATE, time TIME, room INTEGER, floor INTEGER) AS $$
BEGIN
    SELECT j.date, j.time, j.room, j.floor 
    FROM Join j, Approves a
    WHERE j.date = a.date
    AND j.time = a.time
    AND j.room = a.room
    AND j.floor = a.floor
    AND j.eid = e_id
    --should this be >=?
    AND j.date > start_date
    ORDER BY j.date, j.time ASC;
END;
$$LANGUAGE plpgsql

--Comment by Wei Xuan: Did not use start_date in function yet

CREATE OR REPLACE FUNCTION view_manager_report
    (IN start_date, IN e_id INTEGER)
RETURN TABLE (date DATE, time TIME, room INTEGER, floor INTEGER, m_eid INTEGER) AS $$
DECLARE manager_did:= 0;
BEGIN
    -- If not manager, do nothing
    IF e_id IN (SELECT eid FROM Manager)
    THEN 
    manager_did = SELECT did FROM Employee WHERE eid = m_eid;

    -- Get all meetings not approved yet using left join
    WITH all_na AS (
        SELECT * 
        FROM Books b
        LEFT JOIN Approves a 
        ON b.date = a.date
        AND b.time = a.time
        AND b.room = a.room
        AND b.floor = a.floor
        WHERE a.date = NULL
    );

    --Only select meetings which the booker and the manager is from the same department
    SELECT all_na.date, all_na.time, all_na.room, all_na.floor, all_na.eid
    FROM all_na, employee e
    WHERE all_na.eid = e.eid
    AND e.did = manager_did
    ORDER BY all_na.date, all_na.time ASC;
END:
$$LANGUAGE plpgsql


/* 
    ###################
    # Wei Xuan's Code #
    ###################  */

--add_room routine
CREATE OR REPLACE PROCEDURE add_room
	(floor INTEGER, room INTEGER, rname VARCHAR(50), room_capacity INTEGER, did INTEGER, mid INTEGER, date DATE)
AS $$
-- should i create a variable 'mid' assigned to 0? 
-- DECLARE mid INT := 0;
BEGIN
    INSERT INTO Meeting_Rooms(floor, room, rname, did);
    INSERT INTO Updates(date, floor, room, room_capacity, mid);
END;
$$LANGUAGE plpgsql;


--change_capacity routine
CREATE OR REPLACE PROCEDURE change_capacity
    (floor INTEGER, room INTEGER, new_capacity INTEGER, date DATE)
AS $$
BEGIN
    INSERT INTO Updates(date, room, floor, room_capacity, mid);
END;
$$LANGUAGE plpgsql;


/* search_room routine: 
1st step: get all entries in Updates where date is before query_date
2nd step: filter out Updates so that only the max(date) for each (floor,room) remains --> latest update
3rd step: filter out Updates where new_cap >= required_cap 
4th step: return rooms where --> floor, room not in Books where time >=start_hour and time < end_hour
*/

CREATE OR REPLACE FUNCTION search_room
    (IN required_cap INTEGER, IN query_date DATE, IN start_hour TIME, IN end_hour TIME)
RETURNS TABLE(floor INTEGER, room INTEGER, did INTEGER, available_capacity INTEGER) AS $$
BEGIN
    --get the latest updates: step 1 and 2
    WITH latest_updates AS (
        SELECT floor, room, MAX(date)
        FROM Updates
        WHERE date <= query_date
        GROUP BY floor, room, new_cap
    )

    --get the rooms with capactity >= required capacity: step 3
    -- e.g. 3 floor, room which meets the required capacity
    cap_available AS (
        SELECT floor, room, did, new_cap,
        FROM Updates as u JOIN Meeting_Rooms as m
        ON u.floor = m.floor
            AND u.room = m.room
        WHERE (floor, room, date) IN latest_updates
            AND new_cap >= required_cap
        ORDER BY new_cap ASC;
    )

    --step 4:
    SELECT floor, room, did, new_cap
    FROM cap_available AS c
    WHERE NOT EXISTS (SELECT 1
                        FROM Books AS b
                        WHERE b.time >= start_hour
                            AND b.time < end_hour
                            AND b.floor = c.floor
                            AND b.room = c.room);

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

/*
step 1: get all the rooms which were booked
step 2: check if they are approved
*/
CREATE OR REPLACE FUNCTION view_booking_report
    (IN start_date DATE, IN bid INTEGER)
RETURNS TABLE(floor INTEGER, room INTEGER, date DATE, start_hour TIME, is_approved BOOLEAN) AS $$
BEGIN
    WITH booked_rooms AS (
        SELECT *
        FROM Books as b JOIN Approves as a
        ON b.date = a.date
            AND b.time = a.time
            AND b.floor = a.floor
            AND b.room = a.room
        WHERE date >= start_date
            AND b.bid = bid
    )

    SELECT floor, room, date, time, CASE
        WHEN aid IS NULL THEN TRUE
        ELSE FALSE
      END AS is_approved
    FROM booked_rooms
END
$$ LANGUAGE plpgsql;
/*
    SELECT c.floor, c.room, c.did, c.new_cap
    FROM cap_available as c, Books as b
    WHERE (c.floor, c.room) NOT IN (b.floor, b.room)
        OR (c.floor = b.floor
        AND c.room = b.room
        AND (b < start_hour
        OR b > end_hour));

*/

/*
    ###################
    #    Jon Code     #
    ###################  */
--book_room
CREATE OR REPLACE PROCEDURE book_room
    (IN floor INTEGER, IN room INTEGER, IN date DATE, IN start_hour TIME, IN end_hour TIME, IN eid INTEGER)
AS $$
BEGIN
    INSERT INTO Books VALUES (eid, date, time, room, floor);
END;
$$ LANGUAGE plpgsql;

--unbook_room
CREATE OR REPLACE PROCEDURE unbook_room
    (IN floor INTEGER, IN room INTEGER, IN date DATE, IN start_hour TIME, IN end_hour TIME, IN eid INTEGER)
AS $$
BEGIN
    DELETE FROM Books
    WHERE eid = Books.eid AND floor = Books.floor AND room = Books.room AND date = Books.date
    AND start_hour = Books.start_hour AND end_hour = Books.end_hour;

    DELETE FROM Approves
    WHERE floor = Approves.floor AND room = Approves.room AND date = Approves.date
    AND start_hour = Approves.start_hour AND end_hour = Approves.end_hour;
END;
$$LANGUAGE plpgsql;

--join_meeting
CREATE OR REPLACE PROCEDURE join_meeting
    (IN floor INTEGER, IN room INTEGER, IN date DATE, IN start_hour TIME, IN end_hour TIME, IN eid INTEGER)
AS $$
BEGIN
    INSERT INTO Joins VALUES (eid, date, time, room, floor);
END;
$$ LANGUAGE plpgsql;

--leave_meeting
CREATE OR REPLACE PROCEDURE leave_meeting
    (IN floor INTEGER, IN room INTEGER, IN date DATE, IN start_hour TIME, IN end_hour TIME, IN eid INTEGER)
AS $$
DECLARE
    count NUMERIC
BEGIN
    SELECT COUNT(*) INTO count
    FROM Joins J JOIN Approves A
    ON  J.floor = A.floor AND J.room = A.room AND J.date = A.date AND J.start_hour = A.start_hour
    AND J.end_hour = A.end_hour AND J.eid = eid;

    IF count <= 0 THEN
        DELETE FROM Joins
        WHERE floor = Approves.floor AND room = Approves.room AND date = Approves.date
        AND start_hour = Approves.start_hour AND end_hour = Approves.end_hour;
    END IF;
END;
$$ LANGUAGE plpgsql;

--approve_meeting
CREATE OR REPLACE PROCEDURE approve_meeting
    (IN floor INTEGER, IN room INTEGER, IN date DATE, IN start_hour TIME, IN end_hour TIME, IN eid INTEGER)
AS $$
BEGIN
    INSERT INTO Approves VALUES (eid, date, time, room, floor);
END;
$$ LANGUAGE plpgsql;

/* 
    ###################
    # Zhen Hong's Code #
    ###################  */

CREATE OR REPLACE PROCEDURE add_department
    (IN did INTEGER, IN dname VARCHAR(50))
AS $$
BEGIN
    INSERT INTO departments
    VALUES (did, dname);
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE remove_department
    (IN d_id INTEGER)
AS $$
BEGIN
    DELETE FROM departments
    WHERE (did = d_id)
END;
$$LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE declare_health
    (IN eid INTEGER, IN current_date date, IN temp INTEGER)
AS $$
BEGIN
    IF (temp > 37.5) THEN has_fever = 1;
    END IF;
    INSERT INTO Health_Declaration
    VALUES (eid, current_date, temp, has_fever);
END;
$$LANGUAGE plpgsql;

--non compliance
CREATE OR REPLACE FUNCTION non_compliance
    (IN start_date date, IN end_date date)
RETURN TABLE(eid INTEGER, ename varchar(50)) AS $$
BEGIN

WITH employees_declared AS(
SELECT eid from Health_Declaration
WHERE date BETWEEN start_date and end_date
)

SELECT eid, ename FROM Employees
WHERE eid NOT IN employees_declared

END;
$$LANGUAGE plpgsql;

--contact tracing
/*
step 1: check if employee is having fever -> IF NO FEVER --> RETURN;
ELSE:
    step 1: remove all bookings by employee
    step 2: check approved meeting room containing employee
    step 3: create table of all employess in those meeting rooms
    step 4: remove close contact employees from meetings for next 7 days --> check eid in JOINS and date > current_date 

*/
CREATE OR REPLACE FUNCTION contact_tracing
    (IN e_id INTEGER)
RETURN TABLE(eid INTEGER, ename varchar(50)) AS $$
BEGIN
WITH has_fever AS(
SELECT fever FROM Health_Declaration
WHERE eid = e_id
)
IF has_fever = 0 THEN RETURN;
END IF;



END;
$$LANGUAGE plpgsql

