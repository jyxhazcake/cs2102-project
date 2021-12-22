cs2102-project


Import Database Dump
====================

Step 1: Create a new database

Log into PostgreSQL (e.g., with psql) and create a new database, e.g.

CREATE DATABASE cs2102_project;  -- Feel free to pick your own name



Step 2: Import dump into the newly create database, e.g.:

psql  -d cs2102_project  -f schema.sql  -U postgres  -- you might need to add the full path where cs2102.sql is located
psql  -d cs2102_project  -f proc.sql  -U postgres


Extra requirements
==================
Run `npm install` to get required packages. Run `npm start` and point `localhost:3000` to view development server.

You will need to create an `.env` file to hide database credentials. In the `.env` file:
* DB_USER=YOUR_USER       // should be postgres
* DB_HOST=127.0.0.1       // this represents localhost, we will migrate to an online db later
* DATABASE=YOUR_OWN_DB
* DB_PASSWORD=YOUR_OWN_PASSWORD
* DB_PORT=5432            //default I believe is 5432
