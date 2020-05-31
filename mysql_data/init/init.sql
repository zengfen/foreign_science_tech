use mysql;
update user set host = '%' where user = 'root';
FLUSH   PRIVILEGES;
