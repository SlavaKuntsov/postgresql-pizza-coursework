CREATE ROLE COURIER_ROLE;

CREATE USER COURIER WITH LOGIN;

GRANT COURIER_ROLE TO COURIER;
GRANT USAGE ON SCHEMA procedures TO courier_role;

REVOKE USAGE ON SCHEMA procedures FROM courier_role;

GRANT EXECUTE ON FUNCTION procedures.login(varchar, varchar) TO courier_role;
-- GRANT EXECUTE ON FUNCTION procedures.(varchar, varchar) TO seller_role;


GRANT EXECUTE ON FUNCTION procedures.get_customer_order( uuid) TO courier_role;
GRANT EXECUTE ON PROCEDURE procedures.complete_deliver_order(uuid, uuid) TO courier_role;
GRANT EXECUTE ON PROCEDURE procedures.deliver_order(uuid, uuid) TO courier_role;
GRANT EXECUTE ON FUNCTION procedures.get_courier_orders() TO courier_role;
GRANT EXECUTE ON FUNCTION procedures.get_current_user(uuid) TO courier_role;
GRANT EXECUTE ON FUNCTION procedures.get_user_role(uuid) TO courier_role;
GRANT EXECUTE ON FUNCTION procedures.login(varchar, varchar, OUT uuid, OUT varchar, OUT varchar, OUT varchar) TO courier_role;



COMMIT ;







--
REVOKE EXECUTE ON FUNCTION procedures.get_user_role(uuid) FROM manager_role;




--
SELECT *
	FROM information_schema.role_routine_grants
	WHERE grantee = 'courier_role';
