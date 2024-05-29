CREATE ROLE AUTH_ROLE;
CREATE USER AUTH WITH LOGIN;

GRANT AUTH_ROLE TO AUTH;
GRANT USAGE ON SCHEMA procedures TO AUTH_ROLE;

GRANT EXECUTE ON FUNCTION
	procedures.login(varchar, varchar, OUT uuid, OUT varchar, OUT varchar, OUT varchar)
	TO AUTH_ROLE;
GRANT EXECUTE ON FUNCTION
	procedures.signup(varchar, varchar, varchar, varchar, varchar, varchar)
	TO AUTH_ROLE;
GRANT EXECUTE ON FUNCTION
	procedures.get_user_role(uuid)
	TO AUTH_ROLE;

COMMIT ;

REVOKE EXECUTE ON FUNCTION
	procedures.login(varchar, varchar, OUT uuid, OUT varchar, OUT varchar, OUT varchar)
	from AUTH_ROLE;
REVOKE EXECUTE ON FUNCTION
	procedures.signup(varchar, varchar, varchar, varchar, varchar, OUT uuid, OUT varchar)
	from AUTH_ROLE;
REVOKE EXECUTE ON FUNCTION
	procedures.get_user_role(uuid)
	from AUTH_ROLE;


SELECT *
	FROM information_schema.role_routine_grants
	WHERE grantee = 'auth_role';

SELECT *
	FROM information_schema.role_routine_grants
	WHERE grantee = 'auth';

SELECT *
	FROM information_schema.role_routine_grants
	WHERE grantee = 'customer_role';
