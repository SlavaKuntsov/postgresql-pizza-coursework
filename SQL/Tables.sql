CREATE SCHEMA DATA;

-- CREATE TABLE data.ROLE
-- (
-- 	role_id   SERIAL             NOT NULL PRIMARY KEY,
-- 	role_name varchar(50) UNIQUE NOT NULL
-- );

CREATE TABLE data.MANAGER
(
	manager_id       UUID         NOT NULL PRIMARY KEY,
	manager_name     varchar(50)  NOT NULL,
	manager_surname  varchar(50)  NOT NULL,
	manager_email    varchar(100) NOT NULL UNIQUE,
	manager_password varchar(100) NOT NULL
-- 	fk_seller_id    UUID        NOT NULL REFERENCES SELLER (seller_id) ,
-- 	fk_courier_id   UUID        NOT NULL REFERENCES COURIER (courier_id)
);

CREATE TABLE data.SELLER
(
	seller_id       UUID         NOT NULL PRIMARY KEY,
	seller_name     varchar(50)  NOT NULL,
	seller_surname  varchar(50)  NOT NULL,
	seller_email    varchar(100) NOT NULL UNIQUE,
	seller_password varchar(100) NOT NULL,
	auth_permission bool         NOT NULL,
	fk_manager_id   UUID         NOT NULL REFERENCES data.MANAGER (manager_id)
-- 	customer_id    UUID        NOT NULL
);

CREATE TABLE data.COURIER
(
	courier_id       UUID         NOT NULL PRIMARY KEY,
	courier_name     varchar(50)  NOT NULL,
	courier_surname  varchar(50)  NOT NULL,
	courier_email    varchar(100) NOT NULL UNIQUE,
	courier_password varchar(100) NOT NULL,
	auth_permission  bool         NOT NULL,
	fk_manager_id    UUID         NOT NULL REFERENCES data.MANAGER (manager_id)
-- 	fk_order_id      UUID         NOT NULL REFERENCES data."order" (order_id)
);

CREATE TABLE data.CUSTOMER
(
	customer_id       UUID         NOT NULL PRIMARY KEY,
	customer_name     varchar(50)  NOT NULL,
	customer_surname  varchar(50)  NOT NULL,
	customer_email    varchar(100) NOT NULL UNIQUE,
	customer_password varchar(100) NOT NULL,
	customer_address  varchar(100)
-- 	fk_seller_id     UUID         NOT NULL REFERENCES data.SELLER (seller_id)
);


CREATE TABLE data.BASKET
(
	basket_id     SERIAL NOT NULL PRIMARY KEY,
-- 	fk_order_id UUID NOT NULL REFERENCES "order"_
-- 	fk_customer_id UUID NOT NULL REFERENCES CUSTOMER (customer_id) ,
	fk_product_id SERIAL NOT NULL REFERENCES data.PRODUCT (product_id),
-- 	fk_product_property_id SERIAL NOT NULL REFERENCES data.PRODUCT_PROPERTY (product_property_id),
	product_count INT    NOT NULL,
	customer_id   UUID   NOT NULL
);

CREATE TABLE data.ORDER_DETAILS
(
	order_details_id SERIAL NOT NULL PRIMARY KEY,
-- 	order_status     varchar(50) NOT NULL, -- в ORDER
-- 	order_date       date        NOT NULL, -- в ORDER
	fk_order_id      UUID   NOT NULL REFERENCES data."order" (order_id),
	fk_product_id    SERIAL NOT NULL REFERENCES data.PRODUCT (product_id),
	product_count    INT    NOT NULL
-- 	customer_id      UUID   NOT NULL
);

-- +++ TODO Добавить employee_id ( когда заказ оформляется, туда попадает seller_id)
-- TODO если order_delivery = false то fk_courier_id = NULL
CREATE TABLE data."order"
(
-- 	order_id       UUID DEFAULT procedures.uuid_generate_v4() PRIMARY KEY,
	order_id       UUID             NOT NULL PRIMARY KEY,
	order_status   varchar(50)      NOT NULL,                           -- из ORDER_DETAILS
	order_date     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP, -- из ORDER_DETAILS
	order_price    double precision NOT NULL,
	order_delivery boolean          NOT NULL,
-- 	fk_order_details_id SERIAL UNIQUE  NOT NULL REFERENCES data.ORDER_DETAILS (order_details_id)
	fk_customer_id UUID             NOT NULL REFERENCES DATA.CUSTOMER (customer_id),
	fk_seller_id   UUID REFERENCES data.SELLER (seller_id),
	fk_courier_id  UUID REFERENCES data.COURIER (courier_id)
);



CREATE TABLE data.PRODUCT
(
	product_id             SERIAL           NOT NULL PRIMARY KEY,
	product_name           varchar(50)      NOT NULL,
	product_description    TEXT,
	product_image          BYTEA            NOT NULL,
	product_price          DOUBLE PRECISION NOT NULL,
	product_inStock        BOOLEAN          NOT NULL,
-- 	fk_product_category_name varchar(50) UNIQUE NOT NULL REFERENCES data.PRODUCT_CATEGORY (product_category_name)
	fk_product_category_id SERIAL           NOT NULL REFERENCES data.PRODUCT_CATEGORY (product_category_id)
);

CREATE TABLE data.PRODUCT_PROPERTY
(
	product_property_id    SERIAL      NOT NULL PRIMARY KEY,
-- 	fk_product_id          int         NOT NULL REFERENCES data.PRODUCT (product_id),
	fk_basket_id           int REFERENCES data.basket (basket_id),
	fk_order_details_id    int REFERENCES data.order_details (order_details_id),
	product_property_name  varchar(50) NOT NULL,
	product_property_value varchar(50) NOT NULL
-- 	какие именно поля будет принимать
);

-- CREATE TABLE data.PRODUCT_PROPERTY
-- (
-- 	product_property_id    SERIAL      NOT NULL PRIMARY KEY,
-- -- 	fk_product_id          int         NOT NULL REFERENCES data.PRODUCT (product_id),
-- 	fk_basket_id           int         NOT NULL REFERENCES data.basket (basket_id),
-- 	product_size  varchar(50) NOT NULL,
-- 	product_property_value varchar(50) NOT NULL
-- -- 	какие именно поля будет принимать
-- );

CREATE TABLE data.PRODUCT_CATEGORY
(
	product_category_id   SERIAL      NOT NULL PRIMARY KEY,
	product_category_name varchar(50) NOT NULL UNIQUE
);

CREATE TABLE data.REVIEW
(
	review_id      SERIAL    NOT NULL PRIMARY KEY,
	review_text    text      NOT NULL,
	review_date    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	fk_customer_id UUID      NOT NULL REFERENCES data.customer (customer_id)
);

CREATE OR REPLACE VIEW data.all_products_view AS
SELECT p.product_id,
	p.product_name,
	p.product_description,
	p.product_image,
	p.product_price,
	p.product_instock,
	pc.product_category_name AS fk_product_category_name,
	pp.product_property_name,
	pp.product_property_value
	FROM data.product p
		 JOIN data.product_property pp ON p.product_id = pp.fk_product_id
		 JOIN data.product_category pc ON p.fk_product_category_id = pc.product_category_id
	GROUP BY p.product_id, p.product_name, p.product_description, p.product_image,
		p.product_price, p.product_instock, pc.product_category_name,
		pp.product_property_name, pp.product_property_value;


--															возможно удалить
CREATE OR REPLACE VIEW data.all_orders_without_property_view AS
SELECT o.order_id,
	o.order_status,
	o.order_date,
	o.order_price,
	o.order_delivery,
	o.fk_customer_id,
	p.product_name,
	p.product_image,
	p.product_price,
	od.product_count
	FROM data."order" o
		 JOIN data.order_details od ON o.order_id = od.fk_order_id
		 JOIN data.product p ON od.fk_product_id = p.product_id
		 JOIN data.PRODUCT_PROPERTY PP ON od.order_details_id = PP.fk_order_details_id
		 JOIN data.product_category pc ON p.fk_product_category_id = pc.product_category_id;


CREATE OR REPLACE VIEW data.all_orders_view AS
SELECT o.order_id,
	o.order_status,
	o.order_date,
	o.order_price,
	o.order_delivery,
	c.customer_address,
	o.fk_customer_id,
	o.fk_seller_id,
	o.fk_courier_id,
	p.product_name,
	p.product_image,
	p.product_price,
	od.product_count
	FROM data."order" o
		 JOIN data.order_details od ON o.order_id = od.fk_order_id
		 JOIN data.product p ON od.fk_product_id = p.product_id
		 JOIN data.PRODUCT_PROPERTY PP ON od.order_details_id = PP.fk_order_details_id
		 JOIN data.product_category pc ON p.fk_product_category_id = pc.product_category_id
		 JOIN data.customer c ON o.fk_customer_id = c.customer_id;


CREATE OR REPLACE VIEW data.all_basket_view AS
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