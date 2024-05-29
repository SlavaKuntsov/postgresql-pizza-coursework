--																						--
CREATE OR REPLACE PROCEDURE procedures.add_review(customer_id_ UUID, review_text_ TEXT)
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures
AS
$$
BEGIN
	-- Проверка на существование аналогичного отзыва
	IF NOT EXISTS (SELECT 1
					   FROM data.review
					   WHERE fk_customer_id = customer_id_
						   AND review_text = review_text_) THEN
		-- Вставка нового отзыва
		INSERT INTO data.review (review_text, fk_customer_id)
			VALUES (review_text_, customer_id_);
	END IF;
END;
$$;



--																			--
CREATE OR REPLACE FUNCTION procedures.get_all_reviews(customer_id_ UUID)
	RETURNS TABLE
			(
				review_id        INT,
				review_text      text,
				review_date      TIMESTAMP,
				customer_id      uuid,
				customer_name    varchar,
				customer_surname varchar
			)
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures
AS
$$
BEGIN
	RETURN QUERY
		SELECT r.review_id,
			r.review_text,
			r.review_date,
			c.customer_id,
			c.customer_name,
			c.customer_surname
			FROM data.review r
				 JOIN data.customer c ON c.customer_id = r.fk_customer_id
			ORDER BY CASE
						 WHEN fk_customer_id = customer_id_ THEN 0
						 ELSE 1
				END, review_date;
END;
$$;


--																		--
CREATE OR REPLACE PROCEDURE procedures.delete_review(review_id_ int)
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures
AS
$$
BEGIN
	-- Проверка существования отзыва
	IF NOT EXISTS(SELECT 1 FROM data.review WHERE review_id = review_id_) THEN
		RAISE NOTICE 'Review not found!';
		RETURN;
	END IF;

	-- Удаление отзыва
	DELETE FROM data.review WHERE review_id = review_id_;

	RETURN;
END;
$$;


--																										--
CREATE OR REPLACE PROCEDURE procedures.delete_review_from_customer(review_id_ int, customer_id_ UUID)
	LANGUAGE plpgsql
	SECURITY DEFINER
	SET SEARCH_PATH = procedures
AS
$$
BEGIN
	-- Проверка существования отзыва
	IF NOT EXISTS(SELECT 1 FROM data.review WHERE review_id = review_id_) THEN
		RAISE NOTICE 'Review not found!';
		RETURN;
	END IF;

	-- Проверка совпадения идентификатора клиента
	IF NOT EXISTS(SELECT 1 FROM data.review WHERE review_id = review_id_ AND fk_customer_id = customer_id_) THEN
		RAISE NOTICE 'Review does not belong to the specified customer!';
		RETURN;
	END IF;

	-- Удаление отзыва
	DELETE FROM data.review WHERE review_id = review_id_;

	RETURN;
END;
$$;



-- CALL procedures.add_review('0164c212-3903-4fe4-a9ac-3718a40453af', 'haha');
-- SELECT * FROM procedures.get_all_reviews('0164c212-3903-4fe4-a9ac-3718a40453af');