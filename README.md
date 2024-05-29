Docker с Postgresql 16.
С помощью утилиты make/cmake установить сколмпилированные файлы библиотеки(расширения) в директории postgresql.

На всякий случай проверить наличие:
```
sudo apt-get install gcc make libpq-dev postgresql-server-dev-<version>
```

С помощью команд ниже установить расширение в директории:
```
make
sudo make install
```

И чтобы получить расширение в самой бд, сделать:
```
CREATE EXTENSION send_email_v2;  
CREATE EXTENSION pg_background;
```
```
SELECT procedures.send_email_v2('kuncovs19@gmail.com', 'kuncovs1.0@gmail.com', 'Subject', 'Body');
```

### Connect to psql:
docker exec -it postgres psql -U postgres
### Ports:
* 5423 - local
* 5433 - docker

### Приложение:
По ссылке https://github.com/SlavaKuntsov/PizzaApplication
