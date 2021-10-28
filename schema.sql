DROP TABLE IF EXISTS Employees, Juniors, Booker, Senior, Manager, Health_Declaration,
Departments, Meeting_Rooms, Updates, Sessions, Joins, Books, Approves CASCADE;
 
CREATE TABLE Employees (
   eid INTEGER AUTO_INCREMENT,
   ename VARCHAR(50),
   email TEXT UNIQUE,
   home_num VARCHAR(50),
   mobile_num VARCHAR(50),
   office_num VARCHAR(50),
   resigned_date DATE,
   role VARCHAR(50) NOT NULL,
   did INTEGER NOT NULL,
PRIMARY KEY (eid)
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
   date DATE,
   temp DOUBLE CHECK (temp < 43 AND temp > 34),
   fever BOOLEAN AS (temp > 37.5),
   eid INTEGER REFERENCES Employees ON DELETE CASCADE,
   PRIMARY KEY (date, eid)
);
 
CREATE TABLE Departments (
   did INTEGER PRIMARY KEY,
   dname varchar(50)
);
 
CREATE TABLE Meeting_Rooms (
   room INTEGER,
   floor INTEGER,
   rname TEXT,
   did INTEGER NOT NULL REFERENCES Departments,
   PRIMARY KEY (room, floor)
);
 
 
CREATE TABLE Updates (
   date DATE,
   room INTEGER,
   floor INTEGER,
   new_cap INTEGER,
   eid INTEGER REFERENCES Manager ON DELETE CASCADE,
   PRIMARY KEY (date, room, floor),
   FOREIGN KEY (room, floor) REFERENCES Meeting_Rooms (room, floor)
);
 
CREATE TABLE Sessions (
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
   FOREIGN KEY (date, time, room, floor) REFERENCES Sessions (date, time, room, floor)                 
   ON DELETE CASCADE
);
 
CREATE TABLE Books (
   eid INTEGER NOT NULL REFERENCES Booker ON DELETE CASCADE,
   date DATE,
   time TIME, 
   room INTEGER,
   floor INTEGER,
   PRIMARY KEY(date, time, room, floor),
   FOREIGN KEY (date, time, room, floor) REFERENCES Sessions (date, time, room, floor)                 
   ON DELETE CASCADE
);
 
CREATE TABLE Approves (
   eid INTEGER REFERENCES Manager ON DELETE CASCADE,
   date DATE,
   time TIME,
   room INTEGER,
   floor INTEGER,
   PRIMARY KEY(date, time, room, floor),
   FOREIGN KEY (date, time, room, floor) REFERENCES Sessions (date, time, room, floor)
   ON DELETE CASCADE
);
