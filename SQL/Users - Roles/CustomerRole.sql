CREATE ROLE CUSTOMER_ROLE;
CREATE USER CUSTOMER WITH LOGIN;

GRANT CUSTOMER_ROLE TO CUSTOMER;
GRANT USAGE ON SCHEMA procedures TO customer_role;

REVOKE USAGE ON SCHEMA procedures FROM customer_role;


--
GRANT EXECUTE ON FUNCTION procedures.get_all_products_preview() TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data(int, int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_products_count() TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_product_info(int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_user_role(uuid) TO customer_role;
GRANT EXECUTE ON PROCEDURE procedures.add_order(uuid, bool) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_customer_basket2(uuid) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_products_count_instock() TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data_instock(int, int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data_instock(int, int,  varchar, varchar) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.add_in_basket2(uuid, int, int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.add_property_for_product2(int,varchar, varchar) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_customer_basket_product(uuid, int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_customer_basket_property(int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.update_basket_product2(int, varchar, varchar, int) TO customer_role;


GRANT EXECUTE ON PROCEDURE procedures.cancel_order(uuid) TO customer_role;
GRANT EXECUTE ON PROCEDURE procedures.update_customer(uuid, varchar) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.add_in_basket2(uuid, int, int) TO customer_role;
GRANT EXECUTE ON PROCEDURE procedures.add_order(uuid, bool) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.add_product_to_basket(uuid, int, int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.add_property_for_product2(int,varchar, varchar) TO customer_role;
GRANT EXECUTE ON PROCEDURE procedures.add_review(uuid, text) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.delete_from_basket(int) TO customer_role;
GRANT EXECUTE ON PROCEDURE procedures.delete_review_from_customer(int, uuid) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_orders() TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_products_preview() TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_products_preview_from_view() TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_reviews(uuid) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_current_user(uuid) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_customer_basket2(uuid) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_customer_basket_property(int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_customer_basket_product(uuid, int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_customer_order(uuid) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_product_info(int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data(int, int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data_instock(int, int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data_instock(int, int, varchar, varchar) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_product_info(int) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_products_count() TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_products_count_instock() TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.get_user_role(uuid) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.login(varchar, varchar, OUT uuid, OUT varchar, OUT varchar, OUT varchar) TO customer_role;
GRANT EXECUTE ON FUNCTION procedures.update_basket_product2(int, varchar, varchar, int) TO customer_role;

COMMIT ;






--
REVOKE EXECUTE ON FUNCTION procedures.get_all_products_preview() FROM customer_role;
REVOKE EXECUTE ON FUNCTION procedures.get_product_info(int) FROM customer_role;
REVOKE EXECUTE ON FUNCTION procedures.get_products_page(int, int) FROM customer_role;
REVOKE EXECUTE ON PROCEDURE procedures.delete_product(int) FROM customer_role;


--
SELECT *
	FROM information_schema.role_routine_grants
	WHERE grantee = 'customer_role';

COMMIT;