-- CREATE OR REPLACE FUNCTION send_email_trigger_function()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS
-- $$
-- BEGIN
--   -- Вызов процедуры send_email_procedure с указанными аргументами
--   CALL send_email_procedure('Notification!', 'Change in the PRODUCT table');
--   RETURN NEW;
-- END;
-- $$;
--
-- CREATE OR REPLACE TRIGGER send_email_trigger
-- AFTER INSERT ON data.product
-- FOR EACH ROW
-- EXECUTE FUNCTION send_email_trigger_function();


--


-- CREATE OR REPLACE FUNCTION send_email_trigger_function(text varchar)
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS
-- $$
-- DECLARE
--   last_inserted_object data.product%ROWTYPE;
--   sql text;
-- BEGIN
-- 	RAISE NOTICE 'qqqqqq: %', text;
--   -- Получение последнего добавленного объекта из NEW
--   last_inserted_object := NEW;
--
--   sql:= 'Changes in the PRODUCT table with the "' || quote_literal(last_inserted_object.product_name) || '" object';
--
--   -- Вызов процедуры send_email_procedure с указанными аргументами и значениями последнего добавленного объекта
--   CALL send_email_procedure('Notification!', sql);
--
--   RETURN NEW;
-- END;
-- $$;



CREATE OR REPLACE TRIGGER send_email_trigger_insert
	AFTER INSERT
	ON data.product
	FOR EACH ROW
EXECUTE FUNCTION procedures.send_email_insert_trigger_function('For the PRODUCT table, ADDING an object with an id: ');

CREATE OR REPLACE TRIGGER send_email_trigger_update
	AFTER UPDATE
	ON data.product
	FOR EACH ROW
EXECUTE FUNCTION send_email_update_trigger_function('For the PRODUCT table, UPDATING an object with an id: ');

CREATE OR REPLACE TRIGGER send_email_trigger_delete
	AFTER DELETE
	ON data.product
	FOR EACH ROW
EXECUTE FUNCTION send_email_delete_trigger_function('For the PRODUCT table, DELETING an object with an id: ');


DROP TRIGGER IF EXISTS send_email_trigger_insert ON data.product;
DROP TRIGGER IF EXISTS send_email_trigger_update ON data.product;
DROP TRIGGER IF EXISTS send_email_trigger_delete ON data.product;




--
CREATE OR REPLACE FUNCTION procedures.send_email_insert_trigger_function()
	RETURNS TRIGGER
	LANGUAGE plpgsql

	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	trigger_text        text;
	trigger_text_result text;
BEGIN
	trigger_text := TG_ARGV[0];
	trigger_text_result := trigger_text || quote_literal(NEW.product_id) || '.';

	RAISE NOTICE '##################: %', 1;
	RAISE NOTICE 'trigger_text: %', trigger_text;
	RAISE NOTICE 'last_inserted_object: %', quote_literal(NEW.product_id);
	RAISE NOTICE 'trigger_text_result: %', trigger_text_result;

	CALL send_email_procedure('Notification!', trigger_text_result);

	RETURN NEW;
END;
$$;



--
CREATE OR REPLACE FUNCTION send_email_update_trigger_function()
	RETURNS TRIGGER
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures

AS
$$
DECLARE
	message_text        text;
	trigger_text        text;
	trigger_text_result text;
BEGIN
	trigger_text := TG_ARGV[0];
	trigger_text_result := trigger_text || ' ' || NEW.product_id || '.';

	RAISE NOTICE '##################: %', 2;
	RAISE NOTICE 'trigger_text: %', trigger_text;
	RAISE NOTICE 'last_inserted_object: %', OLD.product_id;
	RAISE NOTICE 'trigger_text_result: %', trigger_text_result;

	CALL send_email_procedure('Notification!', trigger_text_result);

	RETURN NEW;
END;
$$;



--
CREATE OR REPLACE FUNCTION send_email_delete_trigger_function()
	RETURNS TRIGGER
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	message_text        text;
	trigger_text        text;
	trigger_text_result text;
BEGIN
	trigger_text := TG_ARGV[0];
	trigger_text_result := trigger_text || ' ' || OLD.product_id || '.';

	RAISE NOTICE '##################: %', 3;
	RAISE NOTICE 'trigger_text: %', trigger_text;
	RAISE NOTICE 'last_inserted_object: %', OLD.product_id;
	RAISE NOTICE 'trigger_text_result: %', trigger_text_result;

	CALL send_email_procedure('Notification!', trigger_text_result);

	RETURN OLD;
END;
$$;


--
-- CREATE OR REPLACE FUNCTION send_email_trigger_function()
-- 	RETURNS TRIGGER
-- 	LANGUAGE plpgsql
-- AS
-- $$
-- DECLARE
-- 	last_inserted_object data.product%ROWTYPE;
-- 	message_text         text;
-- 	trigger_text         text;
-- BEGIN
-- 	last_inserted_object := NEW;
--
-- 	trigger_text := TG_ARGV[0];
--
-- 	message_text := 'Changes in the PRODUCT table for an object with an id: ' ||
-- 					quote_literal(last_inserted_object.product_id) || '.';
--
-- 	RAISE NOTICE 'trigger_text: %', trigger_text;
--
-- 	CALL send_email_procedure('Notification!', message_text);
--
-- 	RETURN NEW;
-- END;
-- $$;