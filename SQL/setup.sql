-- Setup database Umfragen

DROP DATABASE IF EXISTS Umfragen;

CREATE DATABASE IF NOT EXISTS Umfragen;

GRANT ALL PRIVILEGES ON Umfragen.* TO 'Umfragen'@'localhost' IDENTIFIED BY 'eelaeZuK4ohGoh7Z';

FLUSH PRIVILEGES;
