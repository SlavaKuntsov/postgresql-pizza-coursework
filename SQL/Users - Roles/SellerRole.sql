CREATE ROLE SELLER_ROLE;

CREATE USER SELLER WITH LOGIN;

GRANT SELLER_ROLE TO SELLER;
GRANT USAGE ON SCHEMA procedures TO seller_role;

REVOKE USAGE ON SCHEMA procedures FROM seller_role;

GRANT EXECUTE ON FUNCTION procedures.login(varchar, varchar) TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_orders() TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_customer_order(uuid) TO seller_role;
-- GRANT EXECUTE ON FUNCTION procedures.(varchar, varchar) TO seller_role;




GRANT EXECUTE ON PROCEDURE procedures.accept_order(uuid, uuid) TO seller_role;
GRANT EXECUTE ON PROCEDURE procedures.complete_order(uuid, uuid) TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_orders() TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_current_user(uuid) TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_product_info(int) TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data(int, int) TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data_instock(int, int) TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data_instock(int, int, varchar, varchar) TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_product_info(int) TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_products_count() TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_products_count_instock() TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.get_user_role(uuid) TO seller_role;
GRANT EXECUTE ON FUNCTION procedures.login(varchar, varchar, OUT uuid, OUT varchar, OUT varchar, OUT varchar) TO seller_role;






COMMIT ;




--
REVOKE EXECUTE ON FUNCTION procedures.get_user_role(uuid) FROM manager_role;




--
SELECT *
	FROM information_schema.role_routine_grants
	WHERE grantee = 'seller_role';
