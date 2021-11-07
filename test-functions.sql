CALL add_department(0, 'Department deleted after resignation');
CALL add_department(1, 'Marketing');
CALL add_department(2, 'Sales');
CALL add_department(3, 'Accounting');
CALL add_department(4, 'R&D');
CALL add_department(5, 'Production');
CALL add_department(6, 'To remove');

SELECT * from Departments;

CALL add_employee('Harmon', '228-522-9018', 'Junior', 1); --eid 1
CALL add_employee('Carlen', '518-799-1538', 'Junior', 2); --eid 2
CALL add_employee('Yul', '544-211-6100', 'Junior', 3); --eid 3
CALL add_employee('Yul', '544-211-6100', 'Junior', 3, '123-4567-89'); --eid 4
CALL add_employee('Phelia', '267-458-8830', 'Senior', 1); --eid 5
CALL add_employee('Carlie', '209-753-9805', 'Senior', 2); --eid 6
CALL add_employee('Oliy', '107-139-2328', 'Senior', 3); --eid 7
CALL add_employee('Louie', '972-606-7549', 'Senior', 5); --eid 8
CALL add_employee('Darcy', '292-756-6824', 'Manager', 1); --eid 9
CALL add_employee('Debra', '333-831-1507', 'Manager', 2); --eid 10
CALL add_employee('Estella', '322-712-9156', 'Manager', 3); --eid 11
CALL add_employee('Estella', '322-712-9156', 'Manager', 3); --eid 12
CALL add_employee('Debra', '333-831-1507', 'Manager', 3); --eid 13

CALL add_employee('Harmon', '228-522-9018', 'Junior', 0); --negative test case: did cannot be 0

SELECT * from Employees;

CALL remove_employee(4, CURRENT_DATE);
CALL remove_employee(5, CURRENT_DATE);
CALL remove_employee(8, (CURRENT_DATE + 3));
CALL remove_employee(9, (CURRENT_DATE - 3));

SELECT * from Employees;

CALL remove_department(6);
CALL remove_department(1); --negative test case
CALL remove_department(5); --eid 8 --> did should change to 0

SELECT * FROM Employees;

CALL add_room (1, 1, 'Germany', 10, 1, 1, '2020-01-01'); --neg test case: non-manager eid
CALL add_room (1, 1, 'Germany', 10, 1, 9, '2020-01-01'); --neg test case: manager resigned
Call add_room(1, 1, 'France', 5, 2, 10, '2021-01-01'); --neg test case: insertion into updates cannot be in the past and thus room cannot be created
CALL add_room (1, 1, 'Germany', 10, 1, 10, CURRENT_DATE); --neg test_case: wrong did

SELECT * FROM Meeting_Rooms;
SELECT * FROM Updates;

CALL add_room (1, 1, 'Germany', 10, 2, 10, CURRENT_DATE);
CALL add_room (1, 2, 'Germany', 6, 2, 10, CURRENT_DATE);
CALL add_room (2, 1, 'Germany', 5, 3, 11, CURRENT_DATE);
CALL add_room (2, 2, 'Germany', 10, 3, 11, CURRENT_DATE);

SELECT * FROM Meeting_Rooms;
SELECT * FROM Updates;

--does not remove from meeting_rooms and updates
CALL remove_employee(11, (CURRENT_DATE - 3));

SELECT * FROM Meeting_Rooms;
SELECT * FROM Updates;

-- UPDATE Employees SET did = 1 WHERE did = 3;
-- CALL remove_department(3); --FK constraint on departments combined with line 62

SELECT search_room(5, CURRENT_DATE, '00:00', '24:00'); --no results since room is only available for booking on updates.date + 1
SELECT * FROM search_room(5, (CURRENT_DATE + 1), '00:00', '24:00');

CALL change_capacity(2, 2, -10, (CURRENT_DATE+1), 12); --neg test case: negative capacity
CALL change_capacity(2, 1, 0, (CURRENT_DATE+1), 12); --neg test case: 0 capacity
CALL change_capacity(2, 1, 5, (CURRENT_DATE+1), 12);
CALL change_capacity(2, 2, 15, (CURRENT_DATE+1), 12);

SELECT * FROM Updates;

CALL book_room(1, 1, (CURRENT_DATE + 1), '1:00', '4:00', 10);

CALL book_room(2, 1, CURRENT_DATE, '1:00', '4:00', 10); -- negative test case: manager from different department
CALL book_room(2, 1, CURRENT_DATE, '1:00', '4:00', 12); --neg test case: unable to book room on newly added/updated rooms
CALL book_room(2, 1, (CURRENT_DATE + 1), '1:00', '4:00', 12);
CALL book_room(2, 1, (CURRENT_DATE + 1), '0:00', '4:00', 13); -- overlap, cannot book
--CALL book_room(2, 1, (CURRENT_DATE + 1), '0:00', '1:00', 13); -- can book
CALL book_room(2, 1, (CURRENT_DATE + 1), '4:00', '5:00', 13); -- can book

SELECT * FROM BOOKS;
SELECT * FROM JOINS;

SELECT * FROM search_room(5, (CURRENT_DATE + 1), '00:00', '24:00'); -- all rooms apart from 2,1 and 1,1
SELECT * FROM search_room(5, (CURRENT_DATE + 1), '00:00', '1:00'); -- all rooms apart from 2,1
SELECT * FROM search_room(5, (CURRENT_DATE + 1), '00:00', '2:00'); -- all rooms apart from 2, 1 and 1,1
SELECT * FROM search_room(5, (CURRENT_DATE + 1), '4:00', '24:00'); -- all rooms apart from 2,1
SELECT * FROM search_room(5, (CURRENT_DATE + 1), '5:00', '24:00'); -- all rooms

CALL unbook_room(2, 1, CURRENT_DATE, '1:00', '4:00', 12); -- no effect
CALL unbook_room(2, 1, (CURRENT_DATE + 1), '1:00', '4:00', 11); -- no sabotage rule
CALL unbook_room(2, 1, (CURRENT_DATE + 1), '1:00', '4:00', 13); -- no sabotage rule
--CALL unbook_room(2, 1, (CURRENT_DATE + 1), '1:00', '4:00', 12); TESTED WORKING

SELECT * FROM BOOKS;
SELECT * FROM JOINS;

SELECT * FROM search_room(5, (CURRENT_DATE + 1), '00:00', '24:00'); -- all rooms apart from 2,1 and 1,1
SELECT * FROM search_room(5, (CURRENT_DATE + 1), '00:00', '1:00'); -- all rooms
SELECT * FROM search_room(5, (CURRENT_DATE + 1), '00:00', '2:00'); -- all rooms apart from 2,1 and 1,1
SELECT * FROM search_room(5, (CURRENT_DATE + 1), '4:00', '24:00'); -- all rooms

SELECT view_booking_report(CURRENT_DATE, 11);
SELECT * FROM view_booking_report(CURRENT_DATE, 12);
SELECT * FROM view_booking_report((CURRENT_DATE+1), 12);
SELECT * FROM view_booking_report((CURRENT_DATE+2), 12);

SELECT view_manager_report(CURRENT_DATE, 1); --neg test case: employee is not a manager
SELECT * FROM view_manager_report((CURRENT_DATE+1), 13);

CALL join_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '1:00', 1);
CALL join_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '5:00', 1); -- 0:00 to 1:00 is not recorded due to repeat
CALL join_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '5:00', 2);
CALL join_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '5:00', 3);
CALL join_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '5:00', 4); -- neg test case: resigned employee
CALL join_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '5:00', 6);
CALL join_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '5:00', 7); --neg test case: capacity exceeded


SELECT view_future_meeting(CURRENT_DATE, 1);
SELECT * FROM view_future_meeting((CURRENT_DATE+1), 1);

SELECT * FROM JOINS WHERE DATE = (CURRENT_DATE + 1) 
                        AND TIME = '0:00' 
                        AND FLOOR = 2 
                        AND ROOM = 1; -- should have 5 entries


CALL leave_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '5:00', 6);

SELECT * FROM JOINS WHERE DATE = (CURRENT_DATE + 1) 
                        AND TIME = '0:00' 
                        AND FLOOR = 2 
                        AND ROOM = 1; -- should have 4 entries

CALL declare_health(6, (CURRENT_DATE), 37.7); --employee 6 has fever "today"
CALL join_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '5:00', 6); -- joining rejected


CALL join_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '5:00', 12);

SELECT * FROM JOINS WHERE DATE = (CURRENT_DATE + 1) 
                        AND TIME = '0:00' 
                        AND FLOOR = 2 
                        AND ROOM = 1; -- should have 5 entries

CALL declare_health(12, (CURRENT_DATE), 37.7); --employee 3 (manager) has fever "today"
SELECT contact_tracing(12); -- remove all future bookings and joined meetings


SELECT * FROM JOINS WHERE DATE = (CURRENT_DATE + 1) 
                        AND (time >= '1:00'
                            AND time < '4:00')
                        AND FLOOR = 2 
                        AND ROOM = 1; -- should have 0 entries

CALL approve_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '2:00', 13); --time range exceeds the booked slots
SELECT * FROM Approves;
SELECT * FROM view_booking_report(CURRENT_DATE, 13);

SELECT view_future_meeting(CURRENT_DATE, 1);
SELECT * FROM view_future_meeting((CURRENT_DATE+1), 1);

SELECT view_manager_report(CURRENT_DATE, 13);
SELECT * FROM view_manager_report((CURRENT_DATE+1), 13);

CALL leave_meeting(2, 1, (CURRENT_DATE + 1), '0:00', '1:00', 1); --neg test case: cannot leave approved meeting

SELECT * FROM JOINS WHERE DATE = (CURRENT_DATE + 1) 
                        AND TIME = '0:00' 
                        AND FLOOR = 2 
                        AND ROOM = 1;

CALL declare_health(13, (CURRENT_DATE), 37.7); --employee 3 (manager) has fever "today"
SELECT contact_tracing(13); -- remove all future bookings and joined meetings

SELECT * FROM Joins;
SELECT * FROM Approves;
SELECT * FROM Books;

SELECT non_compliance(CURRENT_DATE-1, (CURRENT_DATE+1));
SELECT non_compliance(CURRENT_DATE, CURRENT_DATE);
SELECT non_compliance(CURRENT_DATE+1, (CURRENT_DATE+1));
SELECT non_compliance(CURRENT_DATE+2, (CURRENT_DATE+2));
SELECT non_compliance(CURRENT_DATE, (CURRENT_DATE+1));