-- CREATE SCHEMA EXTENSION;

CREATE EXTENSION send_email_v2;
CREATE EXTENSION send_email_v2 SCHEMA procedures;
-- CREATE EXTENSION send_email_v2 SCHEMA EXTENSION;
DROP EXTENSION send_email_v2;
DROP EXTENSION pg_background;

CREATE EXTENSION pg_background SCHEMA  procedures;



--
CREATE OR REPLACE FUNCTION procedures.execute_send_email_v2(from_mail text, to_mail text, subject text, body text) RETURNS void AS
$$
BEGIN
	PERFORM procedures.send_email_v2(from_mail, to_mail, subject, body);
END;
$$ LANGUAGE plpgsql;

SELECT procedures.execute_send_email_v2('kuncovs19@gmail.com', 'kuncovs1.0@gmail.com', 'not', 'text');



-- поместить в триггер или функцию
SELECT pg_background_launch(
		'SELECT' ||
		'execute_send_email_v2' ||
		'(' ||
		'''kuncovs19@gmail.com'', ' ||
		'''kuncovs1.0@gmail.com'', ' ||
		'''Notification1'', ' ||
		'''Notification from pizza database''' ||
		')'
	   );


-- понять как ее вызывать:
--   - вызывать в каждой процедуре со своими аргументами
--   - сделать какой то триггер (на что???)

-- работает c 2 аргументами
CREATE OR REPLACE PROCEDURE procedures.send_email_procedure(
	p_subject text,
	p_message text
)
	LANGUAGE plpgsql
AS
$$
DECLARE
	sql text;
BEGIN
	RAISE NOTICE 'Result.';
	RAISE NOTICE '1. %', p_subject;
	RAISE NOTICE '2. %', p_message;

	sql := 'SELECT send_email_v2(' || quote_literal('kuncovs19@gmail.com') || ', ' || quote_literal('kuncovs1.0@gmail.com') || ', ' ||
		   quote_literal(p_subject) || ', ' || quote_literal(p_message) || ')';

	RAISE NOTICE '%', sql;

	PERFORM procedures.pg_background_launch(sql);
END;
$$;

-- -- работает
-- CREATE OR REPLACE PROCEDURE send_email_procedure(
-- 	p_from_email varchar,
-- 	p_to_email varchar,
-- 	p_subject text,
-- 	p_message text
-- )
-- 	LANGUAGE plpgsql
-- AS
-- $$
-- DECLARE
-- 	sql text;
-- BEGIN
-- 	sql := 'SELECT send_email_v2(' || quote_literal(p_from_email) || ', ' || quote_literal(p_to_email) || ', ' ||
-- 		   quote_literal(p_subject) || ', ' || quote_literal(p_message) || ')';
--
-- 	RAISE NOTICE '%', sql;
--
-- 	PERFORM pg_background_launch(sql);
-- END;
-- $$;