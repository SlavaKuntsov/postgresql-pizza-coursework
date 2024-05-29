REVOKE EXECUTE ON PROCEDURE procedures.accept_order(uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.add_courier(varchar, varchar,varchar,varchar) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.add_customer(varchar, varchar,varchar,varchar, varchar) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.add_in_basket2(uuid, int, int) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.add_manager(varchar, varchar,varchar,varchar) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.add_order(uuid, bool) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.add_product(varchar, text, bytea, double precision, bool, varchar, data.product_property[]) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.add_product2(varchar, text, bytea, double precision, bool, varchar) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.add_product_category(varchar) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.add_product_to_basket(uuid, int, int) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.add_property_for_product2(int,varchar, varchar) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.add_review(uuid, text) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.add_seller(varchar, varchar,varchar,varchar) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.authorize_employee(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.calculate_monthly_revenue(timestamp with time zone, timestamp with time zone) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.cancel_order(uuid) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.complete_deliver_order(uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.complete_order(uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.deauthorize_employee(uuid) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.delete_employee(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.delete_from_basket(int) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.delete_product(int) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.delete_product_category(varchar) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.delete_review(int) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.delete_review_from_customer(int, uuid) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.deliver_order(uuid, uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_all_customers() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_all_orders() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_all_products_preview() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_all_products_preview_from_view() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_all_reviews(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_authorized_employees() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_courier_orders() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_current_user(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_customer_basket2(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_customer_basket_property(int) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_customer_basket_product(uuid, int) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_customer_order(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_product_info(int) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_paged_data(int, int) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_paged_data_instock(int, int) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_paged_data_instock(int, int, varchar, varchar) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_product_info(int) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_products_count() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_products_count_instock() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_unauthorized_employees() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.get_user_role(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.login(varchar, varchar, OUT uuid, OUT varchar, OUT varchar, OUT varchar) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.signup(varchar, varchar, varchar, varchar, varchar, varchar, OUT uuid, OUT varchar) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION procedures.update_basket_product2(int, varchar, varchar, int) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.update_customer(uuid, varchar) FROM PUBLIC;
REVOKE EXECUTE ON PROCEDURE procedures.update_product(integer, varchar, text, bytea, double precision, boolean, varchar) FROM PUBLIC;