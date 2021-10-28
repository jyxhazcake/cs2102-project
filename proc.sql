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
