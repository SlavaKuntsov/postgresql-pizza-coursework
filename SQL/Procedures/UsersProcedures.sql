
--																											--
CREATE OR REPLACE PROCEDURE procedures.add_manager(name varchar, surname varchar, email varchar, password varchar)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	id uuid;
BEGIN
	SELECT uuid_generate_v4() INTO id;

	INSERT INTO data.manager (manager_id, manager_name, manager_surname, manager_email, manager_password)
		VALUES (id, name, surname, email, password);

	RAISE NOTICE 'Add manager: %', name;
END;
$$;



--																												--
CREATE OR REPLACE PROCEDURE procedures.add_seller(name varchar, surname varchar, email varchar, password varchar)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	id          uuid;
	manager_id_ uuid;
BEGIN
	SELECT uuid_generate_v4() INTO id;

	-- может быть добавить поле current_manager boolean и по нему брать активный id
	SELECT manager_id FROM data.manager LIMIT 1 INTO manager_id_;

	INSERT INTO data.seller (seller_id, seller_name, seller_surname, seller_email, seller_password, fk_manager_id)
		VALUES (id, name, surname, email, password, manager_id_);

	RAISE NOTICE 'Add seller: %', name;
END;
$$;



--																											--
CREATE OR REPLACE PROCEDURE procedures.add_courier(name varchar, surname varchar, email varchar, password varchar)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	id          uuid;
	manager_id_ uuid;
BEGIN
	SELECT uuid_generate_v4() INTO id;

	-- может быть добавить поле current_manager boolean и по нему брать активный id
	SELECT manager_id FROM data.manager LIMIT 1 INTO manager_id_;

	INSERT INTO data.courier (courier_id, courier_name, courier_surname, courier_email, courier_password, fk_manager_id)
		VALUES (id, name, surname, email, password, manager_id_);

	RAISE NOTICE 'Add seller: %', name;
END;
$$;



--																													--
CREATE OR REPLACE PROCEDURE procedures.add_customer(name varchar, surname varchar, email varchar, password varchar,
													address varchar)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	id uuid;
BEGIN
	SELECT procedures.uuid_generate_v4() INTO id;

	INSERT INTO data.customer(customer_id, customer_name, customer_surname, customer_email, customer_password,
							  customer_address)
		VALUES (id, name, surname, email, password, address);

	RAISE NOTICE 'Add customer: %, %', name, email;
END;
$$;



--																							--
CREATE OR REPLACE PROCEDURE procedures.update_customer(customer_id_ uuid, address varchar)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	id uuid;
BEGIN

	IF address = '' THEN
		RETURN;
	END IF;

	UPDATE data.customer
	SET
		customer_address = address
		WHERE customer_id = customer_id_;

END;
$$;





--																					--
CREATE OR REPLACE FUNCTION procedures.get_customer(email varchar, password varchar)
	RETURNS SETOF data.customer
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	SELECT *
		FROM data.customer
		WHERE customer_email = email
			AND customer_password = password;
END;
$$;



--																	--
CREATE OR REPLACE FUNCTION procedures.get_unauthorized_employees()
	RETURNS TABLE
			(
				id      UUID,
				name    VARCHAR,
				surname VARCHAR
			)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT seller_id, seller_name, seller_surname
			FROM data.seller
			WHERE auth_permission = FALSE;

	RETURN QUERY
		SELECT courier_id, courier_name, courier_surname
			FROM data.courier
			WHERE auth_permission = FALSE;
END;
$$;



--																	--
CREATE OR REPLACE FUNCTION procedures.get_authorized_employees()
	RETURNS TABLE
			(
				id      UUID,
				name    VARCHAR,
				surname VARCHAR
			)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT seller_id, seller_name, seller_surname
			FROM data.seller
			WHERE auth_permission = TRUE;

	RETURN QUERY
		SELECT courier_id, courier_name, courier_surname
			FROM data.courier
			WHERE auth_permission = TRUE;
END;
$$;



--																				--
CREATE OR REPLACE PROCEDURE procedures.authorize_employee(employee_id UUID)
    LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
    -- Проверяем, существует ли сотрудник с данным идентификатором среди продавцов
    UPDATE data.seller SET auth_permission = TRUE WHERE seller_id = employee_id;
    IF FOUND THEN
        RETURN;
    END IF;

    -- Проверяем, существует ли сотрудник с данным идентификатором среди курьеров
    UPDATE data.courier SET auth_permission = TRUE WHERE courier_id = employee_id;
    IF FOUND THEN
        RETURN;
    END IF;

    -- Если сотрудник с данным идентификатором не найден, возвращаем ошибку
    RAISE NOTICE 'Employee with ID % not found', employee_id;
--     error := 'Employee with ID not found';
END;
$$;



--																			--
CREATE OR REPLACE PROCEDURE procedures.deauthorize_employee(employee_id UUID)
    LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
    -- Проверяем, существует ли сотрудник с данным идентификатором среди продавцов
    UPDATE data.seller SET auth_permission = FALSE WHERE seller_id = employee_id;
    IF FOUND THEN
        RETURN;
    END IF;

    -- Проверяем, существует ли сотрудник с данным идентификатором среди курьеров
    UPDATE data.courier SET auth_permission = FALSE WHERE courier_id = employee_id;
    IF FOUND THEN
        RETURN;
    END IF;

    -- Если сотрудник с данным идентификатором не найден, возвращаем ошибку
    RAISE NOTICE 'Employee with ID % not found', employee_id;
--     error := 'Employee with ID not found';
END;
$$;



--																--
CREATE OR REPLACE PROCEDURE procedures.delete_employee(employee_id UUID)
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET SEARCH_PATH = procedures
AS
$$
BEGIN
    -- Проверяем, существует ли сотрудник с данным идентификатором среди продавцов
    DELETE FROM data.seller WHERE seller_id = employee_id;
    IF FOUND THEN
        RETURN;
    END IF;

    -- Проверяем, существует ли сотрудник с данным идентификатором среди курьеров
    DELETE FROM data.courier WHERE courier_id = employee_id;
    IF FOUND THEN
        RETURN;
    END IF;

    -- Если сотрудник с данным идентификатором не найден, возвращаем ошибку
    RAISE NOTICE 'Employee with ID % not found', employee_id;
END;
$$;

