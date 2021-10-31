cs2102-project


Import Database Dump
====================

Step 1: Create a new database

Log into PostgreSQL (e.g., with psql) and create a new database, e.g.

CREATE DATABASE cs2102_project;  -- Feel free to pick your own name



Step 2: Import dump into the newly create database, e.g.:

psql  -d cs2102_project  -f schema.sql  -U postgres  -- you might need to add the full path where cs2102.sql is located