CREATE OR REPLACE PROCEDURE generate_products()
    LANGUAGE plpgsql
AS
$$
DECLARE
    i              INTEGER := 41000;
    num_properties INTEGER;
    image_value    bytea; -- Переменная для хранения значения изображения
    result         RECORD;
BEGIN
    -- Извлекаем значение изображения из другой таблицы
    SELECT product_image INTO image_value
    FROM data.product
    WHERE product_name = 'Product 8';

    WHILE i <= 50000
    LOOP
        num_properties := floor(random() * 3) + 1; -- Генерация случайного числа свойств от 1 до 3
        SELECT * INTO result FROM procedures.add_product2(
                'Product ' || i::varchar,
                'Description of product ' || i::varchar,
                image_value, -- Используем значение изображения из другой таблицы
                round(random() * 100),
                CASE round(random())::INTEGER WHEN 1 THEN TRUE ELSE FALSE END,
                'Пицца'::varchar
             );

        -- Делаем что-то с результатом, если нужно
        RAISE NOTICE 'ID продукта: %, Ошибка: %', result.id, result.error;

        i := i + 1;
    END LOOP;
END;
$$;


CALL generate_products();

DELETE FROM data.product
WHERE product.product_id > 1061;
