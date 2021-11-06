-- Manual insertions
/*
Department constraint -> Department 0 is reserved for Resigned employees whose department has been deleted.
*/

/*
General Comments (Wed, 3 Nov 21) Wei Howe:
1. Block-room-without capcity = Checks for joins with no capacity room
But what about booking an room with no capacity? (Shouldn't work, and does'nt -> IDK WHY)
Maybe we should do an explicit check on Books instead.

2. What if all employees leave the meeting? (IE the booker just decides to fk off)
Should we keep the booking? Or delete the booking?

3. Block-Fever-Meeting does not seem to work. Fever employees are able to join and book meetings.
Should fever employees be able to apporve meetings? (Yes, right?)

4. Did not test the triggers that was commented out previously. Left it blank

5. Block resigned-employees - Looks like its only checking against joining and approving.
Should we check against booking?

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
insert into Employees (ename, email, mobile_num, role, did) values ('Meryl', 'mnorbury1c@bluehost.com', '183-753-4531', 'Senior', 6);
insert into Employees (ename, email, mobile_num, role, did) values ('Julieta', 'jebourne1d@ning.com', '620-542-6070', 'Senior', 11);

CALL add_room (1, 1, 'Germany', 1, 1, 4, '2020-01-01'); --room with 1 capacity
INSERT INTO Books VALUES (2, '2020-01-02', '12:00:00', 1, 1); --should automatically join
INSERT INTO Meeting_Rooms VALUES (1, 2, 'dank-room-no-capcity', 1); -- Should still work
INSERT INTO Books VALUES (2, '2020-01-02', '12:00:00', 1, 2); --FAILURES YOU SHOULDN'T BE ABLE TO BOOK A ROOM WITH NO CAPACITY
Call declare_health(24, TO_DATE('01/01/2020', 'DD/MM/YYYY'), 37.9); -- FEVER EMPLOYEE
CALL add_room (1, 3, 'Germany', 10, 1, 4, '2020-01-01'); -- room with 10 capacity
INSERT INTO Books VALUES (4, '2020-01-02', '22:00:00', 1, 3); -- Should work
INSERT INTO Books VALUES (2, '2020-01-03', '22:00:00', 1, 3); -- Should work
/*
Juniors:  5 8 12 13 15 16 17 19 22 25 27 28 30 34 36 39 42 44 45 51 1 10 41
Seniors:  2 3 6 7 9 20 23 26 29 31 33 37 38 40 43 46 47 49 50 21 52
Managers:  4 11 14 18 24 32 35 48 53 54 55
*/
SELECT count(*) FROM Employees; -- Just to break successful insertion streak

--check-only-junior
INSERT INTO Junior VALUES (2); --Try inserting Senior
INSERT INTO Junior VALUES (4); --Try inserting Manager
INSERT INTO Junior VALUES (7); --Try inserting Booker/Senior

--check-only-senior
INSERT INTO Senior VALUES (5); -- Try inserting junior
INSERT INTO Senior VALUES (11); -- Try inserting Manager

--check-only--manager
INSERT INTO Manager VALUES (22); -- Try inserting Junior
INSERT INTO Manager VALUES (50); -- Try inserting Senior

--check-only-booker
INSERT INTO Booker VALUES (1); -- Try inserting Junior

--help-insert-role
SELECT count(*) as Junior_count FROM Junior;
SELECT count(*) as Booker_count FROM Booker; 
SELECT count(*) as Senior_count FROM Senior;
SELECT count(*) as Manager_count FROM Manager;

INSERT INTO Employees (ename, email, mobile_num, role, did) values ('Junior', 'junior-employee@ning.com', '620-542-6070', 'Junior', 11); -- Insert Junior
SELECT count(*) as Junior_count FROM Junior;
SELECT count(*) as Booker_count FROM Booker; 
SELECT count(*) as Senior_count FROM Senior;
SELECT count(*) as Manager_count FROM Manager;

INSERT INTO Employees (ename, email, mobile_num, role, did) values ('Senior', 'senior-employee@ning.com', '620-542-6070', 'Senior', 11); -- Insert Senior
SELECT count(*) as Junior_count FROM Junior;
SELECT count(*) as Booker_count FROM Booker; 
SELECT count(*) as Senior_count FROM Senior;
SELECT count(*) as Manager_count FROM Manager;

INSERT INTO Employees (ename, email, mobile_num, role, did) values ('Manager', 'manager-employee@ning.com', '620-542-6070', 'Manager', 11); -- Insert Manager
SELECT count(*) as Junior_count FROM Junior;
SELECT count(*) as Booker_count FROM Booker; 
SELECT count(*) as Senior_count FROM Senior;
SELECT count(*) as Manager_count FROM Manager;

--Block_Join_on_full_room
INSERT INTO Joins VALUES (5, '2020-01-02', '12:00:00', 1, 1); -- Try inserting into room of capacity 1 with already 1 person inside

--Blocks room without capcity
INSERT INTO Joins VALUES (6, '2020-01-02', '12:00:00', 1, 2); -- Try inserting a room of unknown capcity

--Block-junior-booking
INSERT INTO Books VALUES (5, '2020-01-02', '20:00:00', 1, 1); -- Junior tries booking a room

--Block-fever-meeting (ERROR)
INSERT INTO Books VALUES (24, '2020-01-02', '22:00:00', 1, 1); -- Try Booking a room while fever employee
INSERT INTO Joins VALUES (24, '2020-01-02', '22:00:00', 1, 3); -- Try Joining a Room while fever employee

--Booker-joins-meeting
SELECT * FROM Joins;
INSERT INTO Books VALUES (2, '2020-01-03', '12:00:00', 1, 1); -- Book room and check whether employee joins
SELECT * FROM Joins;

--Block outside approval
INSERT INTO Approves VALUES (11, '2020-01-02', '12:00:00', 1, 1); --Try to approve room with manager did(6) but meeting room did(1)

--Block-changes-after-approval
INSERT INTO Approves VALUES (4, '2020-01-02', '22:00:00', 1, 3); -- SHOULD WORK
INSERT INTO Joins VALUES (34, '2020-01-02', '22:00:00', 1, 3); -- Try joining an approved meeting (employee DOES NOT have fever)

--Block-leaving-after-approval
DELETE FROM Joins WHERE eid = 4
AND date = '2020-01-02'
AND time = '22:00:00'
AND floor = 1
AND room = 3; -- Try leaving an approved meeting (employee DOES NOT have fever)

--Block-book-past-meetings

--Block-join-past-meetings

--Block-approval-past-meetings


--Remove-future-records
SELECT * FROM Books;
SELECT * From Joins;
SELECT * From Approves;
Call remove_employee(4, '2020-01-02');
SELECT * FROM Books; -- Should remove 1 record
SELECT * From Joins; -- Should remove 1 record
SELECT * From Approves; -- Should remove 1 record

--block-resigned-employees
INSERT INTO Joins VALUES (4, '2020-01-03', '22:00:00', 1, 3); -- Try Joining a meeting after resigation
INSERT INTO Approves VALUES (4, '2020-01-03', '22:00:00', 1, 3); -- Try Approving a meeting after resignation
INSERT INTO Books VALUES(4, '2020-01-05', '22:00:00', 1, 1); -- Try Booking a meeting after resignation (WORKS BUT SHOULDN'T)

--check-remove-departments
DELETE FROM Departments WHERE did = 1;
SELECT * FROM Departments;

--Block non-hourly-input
INSERT INTO Books VALUES (2, '2020-01-04', '22:30:00', 1, 3); -- Try booking a room at 1030pm 

--Block other days hd
Call declare_health(25, TO_DATE('01/01/2020', 'DD/MM/YYYY'), 37.9); -- FEVER EMPLOYEE 
SELECT * FROM Health_Declaration;
--Block past updates
INSERT INTO UPDATES VALUES (TO_DATE('01/01/2020', 'DD/MM/YYYY'), 1, 1, 10, 4);
--Delete Over Capcity Meetings

--Block Unresigned Employees
insert into Employees (ename, email, mobile_num, role, did) values ('Harmon', 'hahaha@about.com', '228-522-9018', 'Junior', 0);

--Prevent Joining meeting (assumption that booking = joining)
CALL add_room (1, 1, 'Germany', 1, 6, 11, '2023-10-01');
INSERT INTO Books VALUES (2, '2023-10-02', '12:00:00', 1, 1); 
CALL add_room (1, 3, 'France', 1, 6, 11, '2023-10-01');
INSERT INTO Books VALUES (2, '2023-10-02', '12:00:00', 1, 3); 

