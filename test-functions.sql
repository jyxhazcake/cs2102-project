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
CALL add_room (1, 2, 'Germany', 5, 2, 10, CURRENT_DATE);
CALL add_room (2, 1, 'Germany', 10, 3, 11, CURRENT_DATE);
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
CALL change_capacity(2, 1, 0, (CURRENT_DATE+1), 12);
CALL change_capacity(2, 2, 15, (CURRENT_DATE+1), 12);

SELECT * FROM Updates;

CALL book_room(2, 1, );