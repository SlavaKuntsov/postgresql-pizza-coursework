CREATE ROLE MANAGER_ROLE;
CREATE USER MANAGER WITH LOGIN;

GRANT MANAGER_ROLE TO MANAGER;
GRANT USAGE ON SCHEMA procedures TO manager_role;

REVOKE USAGE ON SCHEMA procedures FROM manager_role;


--
GRANT EXECUTE ON FUNCTION procedures.add_product(varchar, text, bytea, double precision, boolean, varchar, OUT int, OUT varchar) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_user_role(uuid) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_products_count() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data(int, int) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.delete_product(int) TO manager_role;






GRANT EXECUTE ON FUNCTION procedures.get_customer_basket2(uuid) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.add_courier(varchar, varchar,varchar,varchar) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.add_customer(varchar, varchar,varchar,varchar, varchar) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.add_product(varchar, text, bytea, double precision, bool, varchar) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.add_product2(varchar, text, bytea, double precision, bool, varchar) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.add_product_category(varchar) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.add_property_for_product2(int,varchar, varchar) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.add_seller(varchar, varchar,varchar,varchar) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.authorize_employee(uuid) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.calculate_monthly_revenue(timestamp with time zone, timestamp with time zone) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.complete_deliver_order(uuid, uuid) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.complete_order(uuid, uuid) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.deauthorize_employee(uuid) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.delete_employee(uuid) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.delete_product(int) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.delete_product_category(varchar) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.delete_review(int) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_customers() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_orders() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_products_preview() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_products_preview_from_view() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_all_reviews(uuid) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_authorized_employees() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_courier_orders() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_current_user(uuid) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_customer_order(uuid) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_product_info(int) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_paged_data(int, int) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_product_info(int) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_products_count() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_products_count_instock() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_unauthorized_employees() TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.get_user_role(uuid) TO manager_role;
GRANT EXECUTE ON FUNCTION procedures.login(varchar, varchar, OUT uuid, OUT varchar, OUT varchar, OUT varchar) TO manager_role;
GRANT EXECUTE ON PROCEDURE procedures.update_product(integer, varchar, text, bytea, double precision, boolean, varchar) TO manager_role;

COMMIT ;











--
REVOKE EXECUTE ON FUNCTION procedures.get_user_role(uuid) FROM manager_role;


--
SELECT *
	FROM information_schema.role_routine_grants
	WHERE grantee = 'manager_role';