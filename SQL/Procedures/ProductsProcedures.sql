CREATE SCHEMA procedures;
CREATE EXTENSION "uuid-ossp";
DROP EXTENSION "uuid-ossp";


-- только сам basket, без свойств						--
CREATE OR REPLACE FUNCTION procedures.add_in_basket2(
	customer_id_ uuid,
	product_id_ int,
	count int,
	OUT basket_id_ int,
	OUT error varchar
)
	RETURNS record
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures
AS
$$
DECLARE
	product_in_basket_exists boolean;
	customer_exists          boolean;
	product_exists           boolean;
	product_instock_         boolean;
BEGIN
	-- Check if the customer exists
	SELECT EXISTS(SELECT 1 FROM data.customer WHERE customer_id = customer_id_) INTO customer_exists;
	IF NOT customer_exists THEN
		error := 'Customer not found!';
		RAISE NOTICE 'Customer not found!';
		RETURN;
	END IF;

	-- Check if the product exists
	SELECT EXISTS(SELECT 1 FROM data.product WHERE product_id = product_id_) INTO product_exists;
	IF NOT product_exists THEN
		error := 'Product not found!';
		RAISE NOTICE 'Product not found!';
		RETURN;
	END IF;

	-- Check if the product is in stock
	SELECT product_instock FROM data.product WHERE product_id = product_id_ INTO product_instock_;
	IF NOT product_instock_ THEN
		error := 'Product is out of stock!';
		RAISE NOTICE 'Product is out of stock!';
		RETURN;
	END IF;

	-- Insert the product into the basket
	INSERT INTO data.basket(fk_product_id, product_count, customer_id)
		VALUES (product_id_, count, customer_id_)
		RETURNING basket_id INTO basket_id_;
END;
$$;


--																	--
CREATE OR REPLACE FUNCTION procedures.add_property_for_product2(
	basket_id_ int,
	name varchar,
	value varchar,
	OUT inserted_property_id int,
	OUT error varchar
)
	RETURNS record
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures
AS
$$
DECLARE
	count                   int;
	product_id_in_basket    int;
	existing_property_count int;
	existing_properties     data.PRODUCT_PROPERTY[];
	prop                    data.PRODUCT_PROPERTY;
BEGIN
	-- Проверяем существование корзины
	SELECT COUNT(*) INTO count FROM data.basket WHERE basket_id = basket_id_;
	IF count = 0 THEN
		error := 'Basket not found!';
		RETURN;
	END IF;

	RAISE NOTICE '1';

	-- Получаем id продукта в корзине
	SELECT fk_product_id INTO product_id_in_basket FROM data.basket WHERE basket_id = basket_id_;

	RAISE NOTICE '2';

	-- Проверяем количество существующих свойств для данного продукта в корзине
	SELECT COUNT(*)
		INTO existing_property_count
		FROM data.product_property
		WHERE fk_basket_id = basket_id_;

	RAISE NOTICE '22';

	-- Если уже есть свойства для данного продукта в корзине
	IF existing_property_count > 0 THEN

		RAISE NOTICE '221';

		-- Получаем все существующие свойства для данного продукта
		SELECT ARRAY_AGG(p)
			INTO existing_properties
			FROM data.product_property p
			WHERE p.fk_basket_id = basket_id_;

		RAISE NOTICE '222';

		-- Проверяем, есть ли уже в корзине свойства с такими же значениями
		FOR prop IN SELECT * FROM UNNEST(existing_properties)
			LOOP
				IF prop.product_property_name = name THEN
					IF prop.product_property_value = value THEN
						error := 'Product with the same properties already exists in the basket!';
						RETURN;
					ELSE
						-- Обновляем существующее свойство
						UPDATE data.product_property
						SET
							product_property_value = value
							WHERE product_property_id = prop.product_property_id;

						inserted_property_id := prop.product_property_id;
						RETURN;
					END IF;
				END IF;
			END LOOP;
	END IF;

	RAISE NOTICE '3';

	-- Если таких свойств еще нет, добавляем новое свойство для продукта
	INSERT INTO data.product_property (fk_basket_id, fk_order_details_id, product_property_name, product_property_value)
		VALUES (basket_id_, NULL, name, value)
		RETURNING product_property_id INTO inserted_property_id;

	RAISE NOTICE '4';
END;
$$;



--															--
CREATE OR REPLACE FUNCTION procedures.delete_from_basket(
	basket_id_ int,
	OUT error varchar
)
	RETURNS varchar
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures
AS
$$
BEGIN
	error := '';

	-- Проверка существования корзины
	IF NOT EXISTS(SELECT 1 FROM data.basket WHERE basket_id = basket_id_) THEN
		error := 'Basket not found!';
		RETURN;
	END IF;

	-- Удаление связанных строк из таблицы product_property
	DELETE
		FROM data.product_property
		WHERE fk_basket_id = basket_id_;

	-- Удаление из таблицы basket
	DELETE
		FROM data.basket
		WHERE basket_id = basket_id_;

	RETURN;
EXCEPTION
	WHEN OTHERS THEN
		error := SQLERRM;
		RETURN;
END;
$$;



--																--
CREATE OR REPLACE FUNCTION procedures.update_basket_product2(
	basket_id_ int,
	name varchar,
	value varchar,
	count int,
	OUT error varchar
)
	RETURNS varchar
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	product_id_in_basket int;
	existing_property_id int;
BEGIN
	BEGIN
		-- Найти ID продукта в корзине по basket_id
		SELECT fk_product_id
			INTO product_id_in_basket
			FROM data.basket
			WHERE basket_id = basket_id_;

		-- Проверяем, существует ли свойство с таким именем для данного basket_id
		SELECT product_property_id
			INTO existing_property_id
			FROM data.product_property
			WHERE fk_basket_id = basket_id_
				AND product_property_name = name;

		-- Если свойство существует, обновляем его значение
		IF FOUND THEN
			UPDATE data.product_property
			SET
				product_property_value = value
				WHERE product_property_id = existing_property_id;
		ELSE
			-- Если свойство не существует, добавляем новое
			INSERT INTO data.product_property (fk_basket_id, product_property_name, product_property_value)
				VALUES (basket_id_, name, value);
		END IF;

		-- Обновляем количество продукта в корзине
		UPDATE data.basket
		SET
			product_count = count
			WHERE basket_id = basket_id_;

		error := NULL;
	EXCEPTION
		-- Обработка ошибок
		WHEN NO_DATA_FOUND THEN
			error := 'No data found for the given basket_id or product_property_name.';
		WHEN OTHERS THEN
			error := SQLERRM;
	END;
	RETURN;
END;
$$;


--1
-- 													--
CREATE OR REPLACE PROCEDURE procedures.add_product(
	name varchar,
	description text,
	image bytea,
	price double precision,
	inStock bool,
	category varchar,
	p_product_properties data.PRODUCT_PROPERTY[]
)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	product_id_             int;
	category_id             int;
	product_category_exists boolean;
	product_exists          boolean;
	prop                    data.PRODUCT_PROPERTY;
BEGIN
	SELECT EXISTS(SELECT product_category_name
					  FROM data.product_category
					  WHERE product_category_name = category)
		INTO product_category_exists;

	IF NOT product_category_exists THEN
		RAISE NOTICE 'Category not found: %', category;
		RETURN;
	END IF;

	SELECT EXISTS(SELECT product_name
					  FROM data.product
					  WHERE product_name = name)
		INTO product_exists;

	IF product_exists THEN
		RAISE NOTICE 'Product already exist with name: %', name;
		RETURN;
	END IF;

	SELECT product_category_id
		FROM data.product_category
		WHERE product_category_name = category
		INTO category_id;

	INSERT INTO data.product (product_name, product_description, product_image, product_price, product_instock,
							  fk_product_category_id)
		VALUES (name, description, image, CAST(price AS NUMERIC(10, 2)), inStock, category_id)
		RETURNING product_id INTO product_id_;

	IF p_product_properties IS NOT NULL THEN
		FOREACH prop IN ARRAY p_product_properties
			LOOP
			-- +++ TODO добавить проверку на существование такого свойства
			-- +++ TODO обращаться к ним по названиям а не по айди дабы не множить одинаковые строки
				IF EXISTS (SELECT 1
							   FROM data.PRODUCT_PROPERTY
							   WHERE product_property_name = prop.product_property_name
								   AND product_property_value = prop.product_property_value) THEN

					INSERT INTO data.PRODUCT_PROPERTY (fk_basket_id, fk_order_details_id, product_property_name,
													   product_property_value)
					SELECT product_id_, NULL, product_property_name, product_property_value
						FROM data.PRODUCT_PROPERTY
						WHERE product_property_name = prop.product_property_name
							AND product_property_value = prop.product_property_value
						LIMIT 1;
				ELSE

					INSERT INTO data.PRODUCT_PROPERTY (fk_basket_id, fk_order_details_id, product_property_name,
													   product_property_value)
						VALUES (product_id_, NULL, prop.product_property_name, prop.product_property_value);

				END IF;
			END LOOP;
	END IF;

	RAISE NOTICE 'Add product: %', name;

-- 	COMMIT;
END;
$$;


--2 добавление продукта для демонстрации, без массивом	--
CREATE OR REPLACE FUNCTION procedures.add_product(
	name varchar,
	description text,
	image bytea,
	price double precision,
	inStock bool,
	category varchar,
	OUT id int,
	OUT error varchar
)
	RETURNS record
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	category_id             int;
	product_category_exists boolean;
	product_exists          boolean;
BEGIN
	SELECT EXISTS(SELECT product_category_name
					  FROM data.product_category
					  WHERE product_category_name = category)
		INTO product_category_exists;

	IF NOT product_category_exists THEN
		error := 'Category not found!';
		RAISE NOTICE 'Category not found: %', category;
		RETURN;
	END IF;

	SELECT EXISTS(SELECT product_name
					  FROM data.product
					  WHERE product_name = name)
		INTO product_exists;

	IF product_exists THEN
		error := 'Product already exists!';
		RAISE NOTICE 'Product already exists with name: %', name;
		RETURN;
	END IF;

	SELECT product_category_id
		FROM data.product_category
		WHERE product_category_name = category
		INTO category_id;

	INSERT INTO data.product (product_name, product_description, product_image, product_price, product_instock,
							  fk_product_category_id)
		VALUES (name, description, image, CAST(price AS NUMERIC(10, 2)), inStock, category_id)
		RETURNING product_id INTO id;

	RAISE NOTICE 'Add product: %', name;
END;
$$;


--4 												--
CREATE OR REPLACE FUNCTION procedures.add_product2(
	name varchar,
	description text,
	image bytea,
	price double precision,
	inStock bool,
	category varchar
)
	RETURNS TABLE
			(
				id    int,
				error VARCHAR(100)
			)
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures
AS
$$
DECLARE
	int_id                  int;
	category_id             int;
	product_category_exists boolean;
	product_exists          boolean;
-- 	inStock_bool            boolean;
BEGIN
	SELECT EXISTS(SELECT product_category_name
					  FROM data.product_category
					  WHERE product_category_name = category)
		INTO product_category_exists;

	IF NOT product_category_exists THEN
		RAISE NOTICE 'Category not found: %', category;
		RETURN QUERY SELECT NULL, CAST('Category not found!' AS VARCHAR);
		RETURN;
	END IF;

	SELECT EXISTS(SELECT product_name
					  FROM data.product
					  WHERE product_name = name)
		INTO product_exists;

	IF product_exists THEN
		RAISE NOTICE 'Product already exists with name: %', name;
		RETURN QUERY SELECT CAST(NULL AS int), CAST('Product already exists!' AS VARCHAR);
		RETURN;
	END IF;

	SELECT product_category_id
		FROM data.product_category
		WHERE product_category_name = category
		INTO category_id;

	INSERT INTO data.product (product_name,
							  product_description,
							  product_image,
							  product_price,
							  product_instock,
							  fk_product_category_id)
		VALUES (name,
				description,
				image,
				CAST(price AS NUMERIC(10, 2)),
				inStock,
				category_id)
		RETURNING product_id INTO int_id;

	RAISE NOTICE 'Add product: %', name;

	RETURN QUERY SELECT 123, CAST(NULL AS varchar);

END;
$$;


--														--
CREATE OR REPLACE PROCEDURE procedures.update_product(
	product_id_ int,
	name varchar,
	description text,
	image bytea,
	price double precision,
	instock bool,
	category varchar
)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	category_id             int;
	product_category_exists boolean;
	product_exists          boolean;
	product_property_id_    int;
BEGIN
	-- Логирование начала процедуры
	RAISE NOTICE 'Обновление продукта: %', name;

	-- Проверка существования категории
	SELECT product_category_id
		INTO category_id
		FROM data.product_category
		WHERE product_category_name = category;

	IF NOT FOUND THEN
		RAISE EXCEPTION 'Категория % не существует', category;
	END IF;

	-- Проверка существования продукта
	SELECT EXISTS (SELECT 1 FROM data.product WHERE product_id = product_id_) INTO product_exists;

	IF NOT product_exists THEN
		RAISE EXCEPTION 'Продукт с ID % не существует', product_id_;
	END IF;

	-- Обновление основной информации о продукте
	UPDATE data.product
	SET
		product_name           = name,
		product_description    = description,
		product_image          = image,
		product_price          = price,
		product_instock        = inStock,
		fk_product_category_id = category_id
		WHERE product_id = product_id_;

	-- Завершение процедуры
	RAISE NOTICE 'Продукт % успешно обновлен', name;
END;
$$;



--															--
CREATE OR REPLACE PROCEDURE procedures.delete_product(id int)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	IF EXISTS (SELECT 1
				   FROM data.product
				   WHERE product_id = id) THEN
		DELETE
			FROM data.product
			WHERE product_id = id;

		RAISE NOTICE 'Deleted product: %', id;
	ELSE
		RAISE NOTICE 'Product with id % does not exist', id;
	END IF;
END;
$$;


--																			--
CREATE OR REPLACE PROCEDURE procedures.add_product_category(value varchar)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	INSERT INTO data.product_category (product_category_name)
		VALUES (value);

	RAISE NOTICE 'Add product category: %', value;

	COMMIT;
END;
$$;

--																			--
CREATE OR REPLACE PROCEDURE procedures.delete_product_category(value varchar)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	DELETE
		FROM data.product_category
		WHERE product_category_name = value;

	RAISE NOTICE 'Add product category: %', value;

	COMMIT;
END;
$$;



-- 											   				--
CREATE OR REPLACE FUNCTION procedures.get_products_count()
	RETURNS int
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	count int;
BEGIN
	SELECT count(*) FROM data.product INTO count;

	RETURN count;
END;
$$;



-- 											   				--
CREATE OR REPLACE FUNCTION procedures.get_products_count_instock()
	RETURNS int
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	count int;
BEGIN
	SELECT count(*) FROM data.product
	                WHERE product_instock = true
	                INTO count;

	RETURN count;
END;
$$;



-- вывод продуктов для пагинации														--
CREATE OR REPLACE FUNCTION procedures.get_paged_data(page_number INT, page_size INT)
    RETURNS TABLE
            (
                product_id            INT,
                product_name          VARCHAR(50),
                product_description   TEXT,
                product_image         BYTEA,
                product_price         DOUBLE PRECISION,
                product_instock       BOOLEAN,
                product_category_name VARCHAR(50),
                error                 VARCHAR(100)
            )
AS
$$
DECLARE
    -- Вычисляем OFFSET для пагинации
    offset_value INT := (page_number - 1) * page_size;
BEGIN
    -- Проверяем валидность значения page_number
    IF page_number < 1 THEN
        -- Если page_number невалидный, возвращаем ошибку в столбце error
        RETURN QUERY SELECT NULL::INT,
                         NULL::varchar,
                         NULL::TEXT,
                         NULL::BYTEA,
                         NULL::DOUBLE PRECISION,
                         NULL::boolean,
                         NULL::varchar,
                         'Invalid page number'::VARCHAR;
        RAISE NOTICE 'Invalid page number';
        RETURN;
    END IF;

    RETURN QUERY
        SELECT p.product_id,
               p.product_name,
               p.product_description,
               p.product_image,
               p.product_price,
               p.product_instock,
               pc.product_category_name AS fk_product_category_name,
               NULL::VARCHAR -- Значение error будет NULL, если нет ошибки
        FROM data.product p
             JOIN data.product_category pc ON p.fk_product_category_id = pc.product_category_id
        ORDER BY p.product_id
        OFFSET offset_value LIMIT page_size;
END;
$$ LANGUAGE plpgsql
    SECURITY DEFINER
    SET SEARCH_PATH = procedures;



-- вывод продуктов для пагинации С УСЛОВИЕМ НАЛИЧИЯ												--
CREATE OR REPLACE FUNCTION procedures.get_paged_data_instock(page_number INT, page_size INT)
    RETURNS TABLE
            (
                product_id            INT,
                product_name          VARCHAR(50),
                product_description   TEXT,
                product_image         BYTEA,
                product_price         DOUBLE PRECISION,
                product_instock       BOOLEAN,
                product_category_name VARCHAR(50),
                error                 VARCHAR(100)
            )
AS
$$
DECLARE
    -- Вычисляем OFFSET для пагинации
    offset_value INT := (page_number - 1) * page_size;
BEGIN
    -- Проверяем валидность значения page_number
    IF page_number < 1 THEN
        -- Если page_number невалидный, возвращаем ошибку в столбце error
        RETURN QUERY SELECT NULL::INT,
                         NULL::varchar,
                         NULL::TEXT,
                         NULL::BYTEA,
                         NULL::DOUBLE PRECISION,
                         NULL::boolean,
                         NULL::varchar,
                         'Invalid page number'::VARCHAR;
        RAISE NOTICE 'Invalid page number';
        RETURN;
    END IF;

    RETURN QUERY
        SELECT p.product_id,
               p.product_name,
               p.product_description,
               p.product_image,
               p.product_price,
               p.product_instock,
               pc.product_category_name AS fk_product_category_name,
               NULL::VARCHAR -- Значение error будет NULL, если нет ошибки
        FROM data.product p
             JOIN data.product_category pc ON p.fk_product_category_id = pc.product_category_id
        WHERE p.product_instock IS TRUE
        ORDER BY p.product_id
        OFFSET offset_value LIMIT page_size;
END;
$$ LANGUAGE plpgsql
    SECURITY DEFINER
    SET SEARCH_PATH = procedures;



-- SELECT * FROM procedures.get_paged_data_instock(1, 252, 'product_name', 'ASC');


-- универсальныя солртьрровка									--
CREATE OR REPLACE FUNCTION procedures.get_paged_data_instock(
    page_number INT,
    page_size INT,
    sort_column VARCHAR,
    sort_direction VARCHAR
)
RETURNS TABLE
        (
            product_id            INT,
            product_name          VARCHAR(50),
            product_description   TEXT,
            product_image         BYTEA,
            product_price         DOUBLE PRECISION,
            product_instock       BOOLEAN,
            product_category_name VARCHAR(50),
            error                 VARCHAR(100)
        )
AS
$$
DECLARE
    -- Вычисляем OFFSET для пагинации
    offset_value INT := (page_number - 1) * page_size;
    order_clause TEXT;
BEGIN
    -- Проверяем валидность значения page_number
    IF page_number < 1 THEN
        -- Если page_number невалидный, возвращаем ошибку в столбце error
        RETURN QUERY SELECT NULL::INT,
                         NULL::varchar,
                         NULL::TEXT,
                         NULL::BYTEA,
                         NULL::DOUBLE PRECISION,
                         NULL::boolean,
                         NULL::varchar,
                         'Invalid page number'::VARCHAR;
        RAISE NOTICE 'Invalid page number';
        RETURN;
    END IF;

    -- Создаем order_clause на основе переданных параметров
    IF sort_column = 'product_name' AND sort_direction = 'ASC' THEN
        order_clause := 'ORDER BY p.product_name ASC';
    ELSIF sort_column = 'product_name' AND sort_direction = 'DESC' THEN
        order_clause := 'ORDER BY p.product_name DESC';
    ELSIF sort_column = 'product_price' AND sort_direction = 'ASC' THEN
        order_clause := 'ORDER BY p.product_price ASC';
    ELSIF sort_column = 'product_price' AND sort_direction = 'DESC' THEN
        order_clause := 'ORDER BY p.product_price DESC';
    ELSE
        order_clause := 'ORDER BY p.product_id';
    END IF;

    RETURN QUERY EXECUTE format('
        SELECT p.product_id,
               p.product_name,
               p.product_description,
               p.product_image,
               p.product_price,
               p.product_instock,
               pc.product_category_name AS fk_product_category_name,
               NULL::VARCHAR -- Значение error будет NULL, если нет ошибки
        FROM data.product p
        JOIN data.product_category pc ON p.fk_product_category_id = pc.product_category_id
        WHERE p.product_instock IS TRUE %s OFFSET $1 LIMIT $2', order_clause)
    USING offset_value, page_size;
END;
$$ LANGUAGE plpgsql
    SECURITY DEFINER
    SET SEARCH_PATH = procedures;



-- Вся информация об одном продукте													--
CREATE OR REPLACE FUNCTION procedures.get_product_info(product_id_parameter int)
	RETURNS TABLE
			(
				product_id_           INT,
				product_name          varchar(50),
				product_description   TEXT,
				product_image         BYTEA,
				product_price         DOUBLE PRECISION,
				product_instock       boolean,
				product_category_name VARCHAR(50),
-- 				product_property_name  VARCHAR(50),
-- 				product_property_value VARCHAR(50),
				error                 VARCHAR(100)
			)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM data.product WHERE product_id = product_id_parameter) THEN
		RETURN QUERY SELECT NULL::INT,
						 NULL::VARCHAR,
						 NULL::TEXT,
						 NULL::BYTEA,
						 NULL::DOUBLE PRECISION,
						 NULL::boolean,
						 NULL::VARCHAR,
-- 						 NULL::VARCHAR,
-- 						 NULL::VARCHAR,
						 'Product does not exist'::VARCHAR;
		RAISE NOTICE 'Product with id % does not exist', product_id_parameter;
		RETURN;
	END IF;

	RETURN QUERY
		SELECT DISTINCT p.product_id,
			p.product_name,
			p.product_description,
			p.product_image,
			p.product_price,
			p.product_instock,
			pc.product_category_name,
-- 			pp.product_property_name,
-- 			pp.product_property_value,
			NULL::VARCHAR
			FROM data.product p
-- 				 INNER JOIN data.product_property pp ON p.product_id = pp.fk_product_id
				 INNER JOIN data.product_category pc ON p.fk_product_category_id = pc.product_category_id
			WHERE p.product_id = product_id_parameter;
END;
$$;



-- Корзина клиента													--
CREATE OR REPLACE FUNCTION procedures.get_customer_basket(customer_id_ uuid)
	RETURNS SETOF data.all_basket_view
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT *
			FROM data.all_basket_view
			WHERE customer_id = customer_id_;
END;
$$;



-- 																									--
CREATE OR REPLACE FUNCTION procedures.get_customer_basket_product(customer_id_ uuid, basket_id_ int)
	RETURNS SETOF data.all_basket_view
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT *
			FROM data.all_basket_view
			WHERE customer_id = customer_id_
				AND basket_id = basket_id_;
END;
$$;



-- Корзина клиента																--
CREATE OR REPLACE FUNCTION procedures.get_customer_basket2(customer_id_ uuid)
	RETURNS SETOF data.all_basket_view
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT b.basket_id,
			b.customer_id,
			p.product_id,
			p.product_name,
			p.product_description,
			p.product_image,
			p.product_price,
			p.product_instock,
			b.product_count,
			pc.product_category_name,
			pp.product_property_name,
			pp.product_property_value
			FROM data.basket b
				 JOIN data.product p ON p.product_id = b.fk_product_id
				 JOIN data.product_property pp ON b.basket_id = pp.fk_basket_id
				 JOIN data.product_category pc ON p.fk_product_category_id = pc.product_category_id
			WHERE customer_id = customer_id_;
END;
$$;


--																					--
CREATE OR REPLACE FUNCTION procedures.get_customer_basket_property(basket_id int)
	RETURNS SETOF data.product_property
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT *
			FROM data.product_property
			WHERE fk_basket_id = basket_id;
END;
$$;



--																--
CREATE OR REPLACE FUNCTION procedures.calculate_monthly_revenue(
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE
)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
AS
$$
DECLARE
    total_revenue DOUBLE PRECISION;
BEGIN
    SELECT SUM(order_price)
    INTO total_revenue
    FROM data."order"
    WHERE order_date >= start_date AND order_date <= end_date;

    IF total_revenue IS NULL THEN
        total_revenue := 0;
    END IF;

    RETURN total_revenue;
END;
$$;


-- SELECT procedures.calculate_monthly_revenue(
--     date_trunc('month', CURRENT_DATE),
--     date_trunc('month', CURRENT_DATE) + interval '1 month' - interval '1 day'
-- );



CREATE OR REPLACE FUNCTION generate_json ()
RETURNS VOID AS $$
BEGIN
    EXECUTE format('COPY (
        SELECT to_json(seller) FROM data.seller
    ) TO %L', 'C:\ seller.json');
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE add_review_from_json() AS $$
BEGIN
    CREATE TEMP TABLE temp_reviews (
        data JSONB
    );

    COPY temp_reviews(data) FROM 'C:/reviews.json';

    INSERT INTO data.review(review_id, review_text, review_date, fk_customer_id)
    SELECT
        (data->>'CUSTOMER_ID')::INT,
        (data->>'DATE')::DATE,
        (data->>'RATING')::INT,
        (data->>'REVIEW')::VARCHAR(1000)
    FROM temp_reviews;
END;
$$ LANGUAGE plpgsql;
