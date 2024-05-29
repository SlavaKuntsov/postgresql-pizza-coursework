--																						--
CREATE OR REPLACE PROCEDURE procedures.add_order(customer_id_ uuid, delivery boolean)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	order_id_         uuid;
	order_date_value  TIMESTAMP;
	total_price       DOUBLE PRECISION := 0;
	product_price     DOUBLE PRECISION;
	basket_row        RECORD;
	order_details_row RECORD;
	order_details_id_ int;
	basket_id_list    int[];
BEGIN
	-- Генерация нового UUID для заказа
	SELECT procedures.uuid_generate_v4() INTO order_id_;
-- 	order_date_value := CURRENT_TIMESTAMP;

	-- Получение всех basket_id для данного customer_id
	SELECT ARRAY_AGG(basket_id)
		INTO basket_id_list
		FROM data.basket
		WHERE customer_id = customer_id_;

	-- Подсчет общей стоимости заказа
	FOR basket_row IN
		SELECT p.product_price, b.product_count
			FROM data.basket b
				 INNER JOIN data.product p ON p.product_id = b.fk_product_id
			WHERE b.customer_id = customer_id_
		LOOP
			product_price := basket_row.product_price * basket_row.product_count;
			total_price := total_price + product_price;
		END LOOP;

	total_price := CAST(total_price AS NUMERIC(10, 1));

	RAISE NOTICE 'total_price: %', total_price;
	RAISE NOTICE 'order_id_: %', order_id_;

	-- Вставка данных в таблицу order
	INSERT INTO data."order" (order_id, order_status, order_price, order_delivery, fk_customer_id,
							  fk_seller_id, fk_courier_id)
		VALUES (order_id_, 'Оформлен', total_price, delivery, customer_id_, NULL, NULL);

	-- Вставка данных в таблицу order_details и обновление product_property
	FOR order_details_row IN
		SELECT fk_product_id, product_count, basket_id
			FROM data.basket
			WHERE customer_id = customer_id_
		LOOP
			INSERT INTO data.order_details (fk_order_id, fk_product_id, product_count)
				VALUES (order_id_, order_details_row.fk_product_id, order_details_row.product_count)
				RETURNING order_details_id INTO order_details_id_;

			RAISE NOTICE '1';
			UPDATE data.product_property
			SET
				fk_order_details_id = order_details_id_
				WHERE fk_basket_id = order_details_row.basket_id;
			UPDATE data.product_property
			SET
				fk_basket_id = NULL
				WHERE fk_basket_id = order_details_row.basket_id;

			RAISE NOTICE '2';
		END LOOP;

	-- Удаление данных из таблицы basket должно происходить в порядке после обновления product_property
	DELETE FROM data.basket WHERE basket_id = ANY (basket_id_list);

	RAISE NOTICE '3';
END;
$$;



--																	--
CREATE OR REPLACE PROCEDURE procedures.cancel_order(order_id_ uuid)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	status varchar;
BEGIN
	SELECT order_status
		INTO status
		FROM data."order"
		WHERE order_id = order_id_;

	IF status = 'Оформлен' THEN

		UPDATE data."order"
		SET
			order_status = 'Отменен'
			WHERE order_id = order_id_;

		RAISE NOTICE 'Статус заказа % изменен на "Отменен"', order_id_;

	ELSE
		RAISE NOTICE 'Невозможно изменить статус заказа %, так как текущий статус не является "Оформлен"', order_id_;
	END IF;


	IF NOT FOUND THEN
		RAISE NOTICE 'Заказ с id % не найден.', order_id_;
	END IF;
END;
$$;



--																							--
CREATE OR REPLACE PROCEDURE procedures.accept_order(order_id_ uuid, seller_id_ uuid)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	status varchar;
BEGIN
	SELECT order_status
		INTO status
		FROM data."order"
		WHERE order_id = order_id_;

	IF status = 'Оформлен' THEN

		UPDATE data."order"
		SET
			order_status = 'Готовится',
			fk_seller_id = seller_id_
			WHERE order_id = order_id_;

		RAISE NOTICE 'Статус заказа % изменен на "Готовится"', order_id_;

	ELSE
		RAISE NOTICE 'Невозможно изменить статус заказа %, так как текущий статус не является "Оформлен"', order_id_;
	END IF;


	IF NOT FOUND THEN
		RAISE NOTICE 'Заказ с id % не найден.', order_id_;
	END IF;

END;
$$;



--																						--
CREATE OR REPLACE PROCEDURE procedures.complete_order(order_id_ uuid, seller_id_ uuid)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	status        varchar;
	delivery      boolean;
	fk_seller_id_ uuid;
BEGIN
	SELECT order_status, order_delivery, fk_seller_id
		INTO status, delivery, fk_seller_id_
		FROM data."order"
		WHERE order_id = order_id_;

	-- Проверка, что переданный seller_id_ совпадает с fk_seller_id
	IF seller_id_ <> fk_seller_id_ THEN
		RAISE NOTICE 'Невозможно изменить статус заказа %, так как seller_id не совпадает.', order_id_;
		RETURN;
	END IF;

	IF status = 'Готовится' THEN
		IF delivery THEN
			UPDATE data."order"
			SET
				order_status = 'Передан в доставку'
				WHERE order_id = order_id_;
			RAISE NOTICE 'Статус заказа % изменен на "Передан в доставку"', order_id_;
		ELSE
			UPDATE data."order"
			SET
				order_status = 'Завершен(Выдан)'
				WHERE order_id = order_id_;
			RAISE NOTICE 'Статус заказа % изменен на "Завершен(Выдан)"', order_id_;
		END IF;
	ELSE
		RAISE NOTICE 'Невозможно изменить статус заказа %, так как текущий статус не является "Готовится"', order_id_;
	END IF;

	IF NOT FOUND THEN
		RAISE NOTICE 'Заказ с id % не найден.', order_id_;
	END IF;
END;
$$;



--																						--
CREATE OR REPLACE PROCEDURE procedures.deliver_order(order_id_ uuid, courier_id_ uuid)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	status varchar;
BEGIN
	SELECT order_status
		INTO status
		FROM data."order"
		WHERE order_id = order_id_;

	IF status = 'Передан в доставку' THEN

		UPDATE data."order"
		SET
			order_status  = 'В пути',
			fk_courier_id = courier_id_
			WHERE order_id = order_id_;

		RAISE NOTICE 'Статус заказа % изменен на "В пути"', order_id_;

	ELSE
		RAISE NOTICE 'Невозможно изменить статус заказа %, так как текущий статус не является "Передан в доставку"', order_id_;
	END IF;


	IF NOT FOUND THEN
		RAISE NOTICE 'Заказ с id % не найден.', order_id_;
	END IF;

END;
$$;



--																								--
CREATE OR REPLACE PROCEDURE procedures.complete_deliver_order(order_id_ uuid, courier_id_ uuid)
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
DECLARE
	status         varchar;
	delivery       boolean;
	fk_courier_id_ uuid;
BEGIN
	SELECT order_status, order_delivery, fk_courier_id
		INTO status, delivery, fk_courier_id_
		FROM data."order"
		WHERE order_id = order_id_;

	-- Проверка, что переданный courier_id_ совпадает с fk_courier_id
	IF courier_id_ <> fk_courier_id_ THEN
		RAISE NOTICE 'Невозможно изменить статус заказа %, так как courier_id не совпадает.', order_id_;
		RETURN;
	END IF;

	IF status = 'В пути' THEN
		UPDATE data."order"
		SET
			order_status = 'Завершен(Доставлен)',
			fk_courier_id = courier_id_
		WHERE order_id = order_id_;

		RAISE NOTICE 'Статус заказа % изменен на "Завершен(Доставлен)"', order_id_;
	ELSE
		RAISE NOTICE 'Невозможно изменить статус заказа %, так как текущий статус не является "В пути"', order_id_;
	END IF;

	IF NOT FOUND THEN
		RAISE NOTICE 'Заказ с id % не найден.', order_id_;
	END IF;
END;
$$;


-- TODO сделать процедуры вывода с определнными условиями для статуса или к этой процудуре добавлять просто условие
-- Все заказы (с любыми статусами)
-- CREATE OR REPLACE FUNCTION procedures.get_all_orders()
-- 	RETURNS SETOF data.all_orders_view
-- 	LANGUAGE plpgsql
-- 	SECURITY DEFINER SET SEARCH_PATH = procedures
-- AS
-- $$
-- BEGIN
-- 	RETURN QUERY
-- 		SELECT *
-- 			FROM data.all_orders_view;
-- END;
-- $$;


-- -- Правильный вывод заказов
-- CREATE OR REPLACE FUNCTION procedures.get_all_orders2()
-- 	RETURNS TABLE
-- 			(
-- 				product_id     uuid,
-- 				order_status   varchar(50),
-- 				order_date     date,
-- 				order_price    double precision,
-- 				order_delivery boolean,
-- 				fk_customer_id uuid,
-- 				product_name   varchar(50),
-- 				product_image  bytea,
-- 				product_price  double precision,
-- 				product_count  int
-- 			)
-- 	LANGUAGE plpgsql
-- AS
-- $$
-- BEGIN
-- 	RETURN QUERY
-- 		SELECT o.order_id,
-- 			o.order_status,
-- 			o.order_date,
-- 			o.order_price,
-- 			o.order_delivery,
-- 			o.fk_customer_id,
-- 			p.product_name,
-- 			p.product_image,
-- 			p.product_price,
-- 			od.product_count
-- 			FROM data."order" o
-- 				 JOIN data.order_details od ON o.order_id = od.fk_order_id
-- 				 JOIN data.product p ON od.fk_product_id = p.product_id;
-- END;
-- $$;


-- Все азказы											--
CREATE OR REPLACE FUNCTION procedures.get_all_orders()
	RETURNS SETOF data.all_orders_view
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT *
			FROM (SELECT DISTINCT order_id,
					  order_status,
					  order_date,
					  order_price,
					  order_delivery,
					  customer_address,
					  fk_customer_id,
					  fk_seller_id,
					  fk_courier_id,
					  product_name,
					  product_image,
					  product_price,
					  product_count
					  FROM data.all_orders_view
					  WHERE order_status IN ('Отменен', 'Передан в доставку', 'В пути', 'Готовится', 'Оформлен',
											 'Завершен(Доставлен)', 'Завершен(Выдан)')) AS subquery
			ORDER BY CASE
						 WHEN order_status = 'Оформлен' THEN 1
						 WHEN order_status = 'Готовится' THEN 2
						 WHEN order_status = 'Передан в доставку' THEN 3
						 WHEN order_status = 'В пути' THEN 4
						 WHEN order_status = 'Завершен(Доставлен)' THEN 5
						 WHEN order_status = 'Завершен(Выдан)' THEN 6
						 WHEN order_status = 'Отменен' THEN 7
						 ELSE 8
				END;

	RETURN;
END;
$$;

-- Все азказы											--
CREATE OR REPLACE FUNCTION procedures.get_courier_orders()
	RETURNS SETOF data.all_orders_view
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT *
			FROM (SELECT DISTINCT order_id,
					  order_status,
					  order_date,
					  order_price,
					  order_delivery,
					  customer_address,
					  fk_customer_id,
					  fk_seller_id,
					  fk_courier_id,
					  product_name,
					  product_image,
					  product_price,
					  product_count
					  FROM data.all_orders_view
					  WHERE order_status IN ('Передан в доставку', 'В пути', 'Завершен(Доставлен)')) AS subquery
			ORDER BY CASE
						 WHEN order_status = 'Передан в доставку' THEN 1
						 WHEN order_status = 'В пути' THEN 2
						 WHEN order_status = 'Завершен(Доставлен)' THEN 3
						 ELSE 4
				END;

	RETURN;
END;
$$;



-- Заказ клиента															--
CREATE OR REPLACE FUNCTION procedures.get_customer_order(customer_id uuid)
	RETURNS SETOF data.all_orders_without_property_view
	LANGUAGE plpgsql
	SECURITY DEFINER SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT *
			FROM (SELECT DISTINCT order_id,
					  order_status,
					  order_date,
					  order_price,
					  order_delivery,
					  fk_customer_id,
					  product_name,
					  product_image,
					  product_price,
					  product_count
					  FROM data.all_orders_view
					  WHERE fk_customer_id = customer_id
						  AND order_status IN ('Отменен', 'Передан в доставку', 'В пути', 'Готовится', 'Оформлен',
											   'Завершен(Доставлен)', 'Завершен(Выдан)')) AS subquery
			ORDER BY CASE
						 WHEN order_status = 'Оформлен' THEN 1
						 WHEN order_status = 'Готовится' THEN 2
						 WHEN order_status = 'Готовится' THEN 2
						 WHEN order_status = 'Передан в доставку' THEN 3
						 WHEN order_status = 'В пути' THEN 4
						 WHEN order_status = 'Завершен(Доставлен)' THEN 5
						 WHEN order_status = 'Завершен(Выдан)' THEN 6
						 WHEN order_status = 'Отменен' THEN 7
						 ELSE 8
				END;

	RETURN;
END;
$$;


