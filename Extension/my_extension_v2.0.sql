SELECT * FROM pg_available_extensions();

CREATE EXTENSION send_email;
DROP EXTENSION send_email;

CREATE EXTENSION send_email_v2 SCHEMA procedures;
DROP EXTENSION send_email_v2;

SELECT procedures.send_email_v2('kuncovs19@gmail.com', 'kuncovs1.0@gmail.com', 'уведомление', 'такое то');
SELECT procedures.send_email_v2('kuncovs19@gmail.com', 'kuncovs1.0@gmail.com', 'Notification', 'Notification from pizza database');


CREATE EXTENSION send_email_v3;
DROP EXTENSION send_email_v3;

SELECT send_email('kuncovs19@gmail.com', 'kuncovs1.0@gmail.com', 'уведомление', 'такое то');
SELECT send_email('kuncovs19@gmail.com', 'kuncovs1.0@gmail.com', 'asd', 'asdad');



CREATE EXTENSION send_email_v4;
DROP EXTENSION send_email_v4;


-----------------------------------------

-- в send_email_v2 добавить потоки как в send_email_v4

-----------------------------------------




