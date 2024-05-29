--												--
CREATE OR REPLACE FUNCTION procedures.login(
	email VARCHAR,
	password VARCHAR,
	OUT id UUID,
	OUT name VARCHAR,
	OUT surname VARCHAR,
	OUT address VARCHAR,
	OUT error VARCHAR
)
	RETURNS record
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	auth_permission_ bool;
BEGIN
	-- Проверка в таблице customer
	SELECT customer_id, customer_name, customer_surname, customer_address
		INTO id, name, surname, address
		FROM data.customer
		WHERE customer_email = email
			AND customer_password = password;

	IF id IS NOT NULL THEN
		RETURN;
	ELSE
		-- Проверка в таблице manager
		SELECT manager_id, manager_name, manager_surname, NULL
			INTO id, name, surname, address
			FROM data.manager
			WHERE manager_email = email
				AND manager_password = password;

		IF id IS NOT NULL THEN
			RETURN;
		ELSE
			-- Проверка в таблице seller с учетом auth_permission
			SELECT seller_id, seller_name, seller_surname, NULL
				INTO id, name, surname, address
				FROM data.seller
				WHERE seller_email = email
					AND seller_password = password;

			IF id IS NOT NULL THEN
				SELECT auth_permission
					INTO auth_permission_
					FROM data.seller
					WHERE seller_email = email
						AND seller_password = password;

				IF auth_permission_ = FALSE THEN
					error := 'auth_permission is false';
					RETURN;
				ELSE
					RETURN;
				END IF;
			ELSE
				-- Проверка в таблице courier с учетом auth_permission
				SELECT courier_id, courier_name, courier_surname, NULL
					INTO id, name, surname, address
					FROM data.courier
					WHERE courier_email = email
						AND courier_password = password;

				IF id IS NOT NULL THEN
					SELECT auth_permission
						INTO auth_permission_
						FROM data.courier
						WHERE courier_email = email
							AND courier_password = password;

					IF auth_permission_ = FALSE THEN
						error := 'auth_permission is false';
						RETURN;
					ELSE
						RETURN;
					END IF;
				ELSE
					error := 'Invalid email or password';
					RETURN;
				END IF;
			END IF;
		END IF;
	END IF;
END;
$$;



-- ВЕРСИЯ 3										--
CREATE OR REPLACE FUNCTION procedures.signup(
	role VARCHAR,
	name VARCHAR,
	surname VARCHAR,
	email VARCHAR,
	password VARCHAR,
	address VARCHAR,
	OUT role_id UUID,
	OUT address_ VARCHAR,
	OUT error VARCHAR
)
	RETURNS record
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures
AS
$$
BEGIN
	IF email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
		error := 'Invalid email format!';
		RAISE NOTICE 'Invalid email format!';
	ELSE
		CASE
			WHEN role = 'Customer' THEN IF EXISTS (SELECT 1 FROM DATA.customer WHERE customer_email = email) THEN
				error := 'Customer already exists!';
				RAISE NOTICE 'Customer already exists!';
			ELSE
				CALL procedures.add_customer(name, surname, email, password, address);
				SELECT customer_id, customer_address
					INTO role_id, address_
					FROM DATA.customer
					WHERE customer_email = email;
				RAISE NOTICE 'Add customer: %', email;
			END IF;

			WHEN role = 'Manager'
				THEN IF EXISTS (SELECT 1 FROM DATA.manager) THEN -- Изменено условие на проверку существования хотя бы одного менеджера
					error := 'Manager already exists!';
					RAISE NOTICE 'Manager already exists!';
				ELSE
					CALL procedures.add_manager(name, surname, email, password);
					SELECT manager_id, NULL INTO role_id, address_ FROM DATA.manager WHERE manager_email = email;
					RAISE NOTICE 'Add Manager: %', email;
				END IF;

			WHEN role = 'Seller' THEN IF EXISTS (SELECT 1 FROM DATA.seller WHERE seller_email = email) THEN
				error := 'Seller already exists!';
				RAISE NOTICE 'Seller already exists!';
			ELSE
				CALL procedures.add_seller(name, surname, email, password);
				SELECT seller_id, NULL INTO role_id, address_ FROM DATA.seller WHERE seller_email = email;
				RAISE NOTICE 'Add Seller: %', email;
			END IF;

			WHEN role = 'Courier' THEN IF EXISTS (SELECT 1 FROM DATA.courier WHERE courier_email = email) THEN
				error := 'Courier already exists!';
				RAISE NOTICE 'Courier already exists!';
			ELSE
				CALL procedures.add_courier(name, surname, email, password);
				SELECT courier_id, NULL INTO role_id, address_ FROM DATA.courier WHERE courier_email = email;
				RAISE NOTICE 'Add Courier: %', email;
			END IF;

			ELSE error := 'Unknown role!';
				 RAISE NOTICE 'Unknown role!';
			END CASE;
	END IF;

	RETURN;
END;
$$;


--															--
CREATE OR REPLACE FUNCTION procedures.get_user_role(id uuid)
	RETURNS text
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures AS
$$
DECLARE
	table_name text;
BEGIN
	SELECT 'Customer' INTO table_name FROM data.customer WHERE customer_id = id;
	IF table_name IS NOT NULL THEN
		RETURN table_name;
	END IF;

	SELECT 'Manager' INTO table_name FROM data.manager WHERE manager_id = id;
	IF table_name IS NOT NULL THEN
		RETURN table_name;
	END IF;

	SELECT 'Seller' INTO table_name FROM data.seller WHERE seller_id = id;
	IF table_name IS NOT NULL THEN
		RETURN table_name;
	END IF;

	SELECT 'Courier' INTO table_name FROM data.courier WHERE courier_id = id;
	IF table_name IS NOT NULL THEN
		RETURN table_name;
	END IF;

	RETURN 'Auth'; -- Если UUID не найден в таблицах, возвращаем NULL
END;
$$;


--
-- --																--
-- CREATE OR REPLACE FUNCTION procedures.get_current_user(id_ uuid)
-- 	RETURNS TABLE
-- 			(
-- 				ID      UUID,
-- 				NAME    VARCHAR(50),
-- 				surname VARCHAR(50),
-- 				email   VARCHAR(100)
-- 			)
-- 	LANGUAGE plpgsql
-- 	SECURITY DEFINER SET SEARCH_PATH = procedures
-- AS
-- $$
-- DECLARE
-- 	id   uuid;
-- 	role varchar;
-- BEGIN
-- 	-- 	SELECT customer_id from data.customer INTO id;
-- 	SELECT "current_user"() INTO role;
-- 	RAISE NOTICE 'CURRENT_USER: %', role;
--
-- 	IF
-- 		CURRENT_USER = 'customer' THEN
-- 		RAISE NOTICE 'User is a customer!';
--
-- 		IF
-- 			EXISTS (SELECT 1 FROM DATA.customer WHERE customer_id = id_) THEN
-- 			RAISE NOTICE 'Customer exists!';
-- 			RETURN QUERY
-- 				SELECT customer_name, customer_email, customer_email
-- 					FROM data.customer;
-- 		ELSE
-- 			RAISE NOTICE 'Customer not exist: %', id_;
-- 		END IF;
--
-- 	ELSIF
-- 		CURRENT_USER = 'manager' THEN
-- 		RAISE NOTICE 'Manager is a manager!';
--
-- 		IF
-- 			EXISTS (SELECT 1 FROM DATA.manager WHERE manager_id = id_) THEN
-- 			RAISE NOTICE 'Manager exists!';
-- 			RETURN QUERY
-- 				SELECT manager_id, manager_name, manager_surname, manager_email
-- 					FROM data.manager;
-- 		ELSE
-- 			RAISE NOTICE 'Manager not exist: %', id_;
-- 		END IF;
--
-- 	ELSIF
-- 		CURRENT_USER = 'seller' THEN
-- 		RAISE NOTICE 'Seller is a seller!';
--
-- 		IF
-- 			EXISTS (SELECT 1 FROM DATA.seller WHERE seller_id = id_) THEN
-- 			RAISE NOTICE 'Seller exists!';
-- 			RETURN QUERY
-- 				SELECT seller_name, seller_surname, NULL::varchar
-- 					FROM data.seller;
-- 		ELSE
-- 			RAISE NOTICE 'Seller not exist: %', id_;
-- 		END IF;
--
-- 	ELSIF
-- 		CURRENT_USER = 'courier' THEN
-- 		RAISE NOTICE 'Courier is a auth!';
--
-- 		IF
-- 			EXISTS (SELECT 1 FROM DATA.courier WHERE courier_id = id_) THEN
-- 			RAISE NOTICE 'Courier exists!';
-- 			RETURN QUERY
-- 				SELECT courier_id, courier_name, courier_surname, courier_email
-- 					FROM data.courier;
-- 		ELSE
-- 			RAISE NOTICE 'Manager not exist: %', id_;
-- 		END IF;
--
-- 	ELSE
-- 		RAISE NOTICE 'Unknown user type!';
-- 	END IF;
-- END;
-- $$;
--
--
--
-- CREATE
-- 	OR REPLACE FUNCTION procedures.get_current_user(email_ varchar)
-- 	RETURNS TABLE
-- 			(
-- 				ID      UUID,
-- 				NAME    VARCHAR(50),
-- 				surname VARCHAR(50),
-- 				email   VARCHAR(100)
-- 			)
-- 	LANGUAGE plpgsql
-- 	SECURITY DEFINER SET SEARCH_PATH = procedures
-- AS
-- $$
-- 	-- DECLARE
-- -- 	id uuid;
-- BEGIN
-- 	-- 	SELECT customer_id from data.customer INTO id;
-- 	IF
-- 		CURRENT_USER = 'customer' THEN
-- 		RAISE NOTICE 'User is a customer!';
--
-- 		IF
-- 			EXISTS (SELECT 1 FROM DATA.customer WHERE customer_email = email_) THEN
-- 			RAISE NOTICE 'Customer exists!';
-- 			RETURN QUERY
-- 				SELECT customer_id, customer_name, customer_surname, customer_email
-- 					FROM data.customer;
-- 		ELSE
-- 			RAISE NOTICE 'Customer not exist: %', email_;
-- 		END IF;
--
-- 	ELSIF
-- 		CURRENT_USER = 'manager' THEN
-- 		RAISE NOTICE 'Manager is a manager!';
--
-- 		IF
-- 			EXISTS (SELECT 1 FROM DATA.manager WHERE manager_email = email_) THEN
-- 			RAISE NOTICE 'Manager exists!';
-- 			RETURN QUERY
-- 				SELECT manager_id, manager_name, manager_surname, manager_email
-- 					FROM data.manager;
-- 		ELSE
-- 			RAISE NOTICE 'Manager not exist: %', email_;
-- 		END IF;
--
-- 	ELSIF
-- 		CURRENT_USER = 'seller' THEN
-- 		RAISE NOTICE 'Seller is a seller!';
--
-- 		IF
-- 			EXISTS (SELECT 1 FROM DATA.seller WHERE seller_email = email_) THEN
-- 			RAISE NOTICE 'Seller exists!';
-- 			RETURN QUERY
-- 				SELECT seller_id, seller_name, seller_surname, seller_email
-- 					FROM data.seller;
-- 		ELSE
-- 			RAISE NOTICE 'Seller not exist: %', email_;
-- 		END IF;
--
-- 	ELSIF
-- 		CURRENT_USER = 'courier' THEN
-- 		RAISE NOTICE 'Courier is a auth!';
--
-- 		IF
-- 			EXISTS (SELECT 1 FROM DATA.courier WHERE courier_email = email_) THEN
-- 			RAISE NOTICE 'Courier exists!';
-- 			RETURN QUERY
-- 				SELECT courier_id, courier_name, courier_surname, courier_email
-- 					FROM data.courier;
-- 		ELSE
-- 			RAISE NOTICE 'Manager not exist: %', email_;
-- 		END IF;
--
-- 	ELSE
-- 		RAISE NOTICE 'Unknown user type!';
-- 	END IF;
-- END;
-- $$;




