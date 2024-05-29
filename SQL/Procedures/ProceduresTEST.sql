CALL procedures.add_product_category('Пицца');
CALL procedures.add_product_category('Напиток');
CALL procedures.add_product_category('Суши');
CALL procedures.add_product_category('Десерт');
CALL procedures.add_product_category('Закуски');
CALL procedures.delete_product_category('Пудинг');

SELECT * FROM data.product_category;


CALL procedures.add_product(
		'4 Сыра',
		'Вкусная пицца',
		E'\\x0153456789AACDEF',
		32.9,
		TRUE,
		'Пицца',
		ARRAY [
			ROW (NULL, NULL, 'Тип бортиков', 'Сырные')::data.PRODUCT_PROPERTY,
			ROW (NULL, NULL, 'Размер', 'Маленький')::data.PRODUCT_PROPERTY
			]
	 );

SELECT product_id, product_name, product_description, product_price, product_instock, fk_product_category_id
	FROM data.product;

CALL procedures.add_product(
		'Картошка фри',
		'картошечка',
		E'\\x0123456789ABBDAF',
		7.99,
		TRUE,
		'Закуски',
		ARRAY [
			ROW (NULL, NULL, 'Соус', 'Терияки')::data.PRODUCT_PROPERTY
			]
	 );

SELECT *
	FROM procedures.add_product2(
			'3333333',
			'aaa',
			E'\\x0123456789ABBDAF',
			7.99,
			TRUE,
			'Закуски'
		 );


CALL procedures.update_product(
		2,
		'3333333',
		'aaa',
		E'',
		7.99,
		TRUE,
		'Закуски'
	 );

SELECT *
	FROM procedures.add_in_basket(
			'0164c212-3903-4fe4-a9ac-3718a40453af',
			6,
			3,
			ARRAY [
				ROW (NULL, NULL, NULL, 'Размер', 'Маленький ')::data.PRODUCT_PROPERTY,
				ROW (NULL, NULL, NULL, 'Тесто', 'Тонкое ')::data.PRODUCT_PROPERTY
				]
		 );
CALL procedures.add_property_for_product(2, 'qqq', 'qwe');


CALL procedures.delete_product(76677);

SELECT * FROM procedures.add_property_for_product2(1, 'Размер', 'Большая');
SELECT * FROM procedures.add_property_for_product2(1, 'Тесто', 'Тонкое');

SELECT * FROM procedures.add_property_for_product2(12, 'Размер', 'Средняя');
SELECT * FROM procedures.add_property_for_product2(4, 'Тесто', 'Тонкое');

SELECT * FROM procedures.add_in_basket2('0164c212-3903-4fe4-a9ac-3718a40453af', 12, 1);

CALL procedures.update_product(
		28,
		'Картошка фри',
		'картошечка',
		E'\\x0123456789ABBDAF',
		8.99,
		TRUE,
		'Закуски',
		ARRAY [
			ROW (NULL, NULL, 'Соус', 'Сырный')::data.PRODUCT_PROPERTY
			]
	 );

-- TODO ОТКЛЮЧИТЬ ТРИГГЕР ПРИ ТЕСТИРОВАНИИ 100.000

SELECT * FROM procedures.get_all_products() ORDER BY product_id;
SELECT * FROM procedures.get_all_products() WHERE product_name = '9' ORDER BY product_id;
SELECT * FROM procedures.get_all_products() WHERE product_name = 'десерт' ORDER BY product_id;
SELECT * FROM procedures.get_all_products_preview();
SELECT * FROM procedures.get_products_count();
SELECT * FROM procedures.get_paged_data(0, 500);
SELECT * FROM procedures.get_paged_data(1, 500);







EXPLAIN ANALYZE SELECT * FROM data.product WHERE product_price > 10;


EXPLAIN ANALYZE  SELECT * FROM data.product ORDER BY product_price;


CREATE index idx_product_price on data.product(product_price);






SELECT * FROM procedures.get_product_info(142692);

SELECT *
	FROM data.product
		 INNER JOIN data.product_property pp ON product.product_id = pp.fk_product_id;


CALL procedures.add_in_basket(
		2,
		3,
		'72700b70-8bf3-429d-be30-952c7b419741'
	 );
CALL procedures.add_in_basket(
		12,
		1,
		'72700b70-8bf3-429d-be30-952c7b419741'
	 );

CALL procedures.add_in_basket(
		29,
		1,
		'a60d11e3-8541-4e28-a720-dfb758c414f1'
	 );
SELECT procedures.add_in_basket(
		142709,
		1,
		'0164c212-3903-4fe4-a9ac-3718a40453af'
	   );



CALL procedures.delete_from_basket(41);
CALL procedures.change_product_count_in_basket(43, 10);

SELECT * FROM procedures.get_customer_basket('0164c212-3903-4fe4-a9ac-3718a40453af');
SELECT * FROM procedures.get_customer_basket2('0164c212-3903-4fe4-a9ac-3718a40453af');

SELECT * FROM procedures.get_customer_basket_product('0164c212-3903-4fe4-a9ac-3718a40453af', 10);
SELECT * FROM procedures.get_customer_basket_property(10);

SELECT * FROM procedures.update_basket_product2(17, 'Размер', 'Большая', 2);
SELECT * FROM procedures.update_basket_product2(17, 'Тесто', 'Тонкое', 2);

SELECT * FROM data.all_basket_view;

-- +++ TODO добавить проверку на существование такого заказа в таблице
CALL procedures.add_order('72700b70-8bf3-429d-be30-952c7b419741', FALSE);
CALL procedures.add_order('0164c212-3903-4fe4-a9ac-3718a40453af', FALSE);
CALL procedures.cancel_order('4d04bb62-08bb-493d-9aeb-46c5b735038a');


-- когда добавляю второй заказ, оно берет в order_details айди прошлого заказа
SELECT * FROM procedures.get_customer_order('72700b70-8bf3-429d-be30-952c7b419741');
SELECT * FROM procedures.get_customer_order('0164c212-3903-4fe4-a9ac-3718a40453af');
SELECT * FROM procedures.get_all_orders();
SELECT * FROM procedures.get_courier_orders();

-- сделать вывод по типу статуса

SELECT * FROM data.order_details;
-- SELECT * FROM data.order;

--    SELECT order_details_id
--     FROM data.order_details
--     WHERE customer_id = '72700b70-8bf3-429d-be30-952c7b419741';


CALL procedures.accept_order('2cece1b4-0df9-43a2-b0cd-c246cedbdde4');
CALL procedures.complete_order('26d81237-932b-45ab-afe4-543cc98e16a9', 'bc800390-9493-47e0-9240-c7b0a663082b');
CALL procedures.complete_deliver_order('0ba06da2-38ec-4270-bae4-9f25294b9826', 'a983b75a-2a82-40f4-801c-1a17094b2877');


SELECT * FROM data.customer;


SELECT procedures.login_customer('email', '123');
SELECT procedures.login_customer('email@gmail.com', '123');
SELECT procedures.login_customer('kuncovs19@gmail.com', '111');
SELECT procedures.login_customer('qwe', 'qwe');
SELECT * FROM procedures.login('q', 'q');
SELECT * FROM procedures.login('pasha@gmail.com', '123');

-- CALL procedures.add_customer('slava', 'kuntsov', 'kuncovs19@gmail.com', '111', NULL);
CALL procedures.signup('Customer', 'pasha', 'aaa', 'pasha@gmail.com', '1');
SELECT * FROM procedures.signup('Customer', 'qwe', 'qwe', 'qwe', 'qwe');
SELECT * FROM procedures.signup('Customer', 'g', 'g', 'g', 'g');
SELECT * FROM procedures.signup('Customer', 'gqe', 'gqe', 'gqe@gmail.com', 'gqe');
SELECT * FROM procedures.signup('Seller', 'pasha', 'pasha', 'pasha@gmail.com', '123', '');


SELECT * FROM procedures.get_unauthorized_employees();
CALL procedures.authorize_employee('19df4d00-a84e-4014-b8b8-319372b32f35');
CALL procedures.deauthorize_employee('19df4d00-a84e-4014-b8b8-319372b32f35');


SELECT * FROM procedures.get_all_customers();
SELECT procedures.get_current_user('0164c212-3903-4fe4-a9ac-3718a40453af');
SELECT procedures.get_current_user('1');

SELECT procedures.get_user_role('15b4b795-71e9-4c7b-baa2-4951c5e3a75d');

-- CALL procedures.add_customer('user1', 'email@gmail.com', 'street...', '123');


SELECT * FROM data.basket;

SELECT * FROM data.product;
SELECT * FROM data.product_property;
SELECT * FROM data.product_category;

COMMIT;


-- где вызывать
CALL send_email_procedure(
		'Notification!',
		'Notification from pizza database'
	 );














CREATE OR REPLACE PROCEDURE export_data_to_json(start_date DATE, end_date DATE)
SECURITY DEFINER
AS $$
DECLARE
    encryption_key TEXT := '109995Kaug95';
BEGIN
    EXECUTE format('COPY (
        SELECT json_agg(row_to_json(decrypted_progress))::text
        FROM (
             SELECT * FROM data.seller
        ) AS decrypted_progress
    ) TO ''/Users/nikitapapko/univer/coursework/progress_out.json''',
    encryption_key, encryption_key, encryption_key, encryption_key, start_date, end_date);

    RAISE NOTICE 'Data exported to progress_out.json';
END;
$$
LANGUAGE plpgsql;










-- Экспорт данных из таблицы в JSON
COPY (
    SELECT json_agg(row_to_json(t))
    FROM (
        SELECT * FROM data.seller
    ) t
) TO 'C:\my\seller.json';


CREATE OR REPLACE FUNCTION generate_sales_report_car()
RETURNS VOID AS $$
BEGIN
    EXECUTE format('COPY (
        SELECT to_json(manager) FROM data.manager
    ) TO %L', 'C:/my/seller.json');
END;
$$ LANGUAGE plpgsql;

SELECT generate_sales_report_car();







CREATE OR REPLACE FUNCTION procedures.export_seller_to_json_file(file_path TEXT)
    RETURNS VOID
    LANGUAGE plpgsql
AS
$$
DECLARE
    export_query TEXT;
BEGIN
    export_query := format('COPY (SELECT row_to_json(seller) FROM data.seller) TO %L', file_path);
    EXECUTE export_query;
END;
$$;

SELECT procedures.export_seller_to_json_file('C:/my/study/db/coursework/SQL/Procedures/seller_data.json');
