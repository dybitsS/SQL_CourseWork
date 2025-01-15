# Курсовая работа по SQL: Создание баз данных OLTP и OLAP

## Шаг 1: Создание и наполнение базы OLTP

1.  Создайте базу данных с названием `oltp_database`.
    *   Имя пользователя: `postgres`
    *   Пароль: `123`

2.  Запустите скрипт `creation_oltp_database.sql`.

   ![image](https://github.com/user-attachments/assets/f69f678b-e39d-4339-89db-6433b6689e13)
   [Link to diagram](https://dbdiagram.io/d/oltp_database-67814a656b7fa355c3867bba)


4.  Откройте файл `ETL_Goods.sql`.
    *   Укажите путь к вашему файлу `Goods.csv` в запросе:

    ```sql
    FROM 'YourPath/Goods.csv'
    ```

    *   Запустите скрипт.

5.  Запустите скрипт `ETL_Clients.sql`.
    *   Укажите путь к вашему файлу `Clients.csv` в запросе:

    ```sql
    FROM 'YourPath/Clients.csv'
    ```

    *   Запустите скрипт.

6.  Запустите скрипт `ETL_Orders_and_OrderDetails.sql`.
    *   Укажите путь к вашему файлу `orders.csv` в запросе:

    ```sql
    FROM 'YourPath/orders.csv'
    ```

    *   Запустите скрипт.

## Шаг 2: Создание базы OLAP

1.  Создайте базу данных с названием `olap_database`.
    *   Имя пользователя: `postgres`
    *   Пароль: `123`

2.  Запустите скрипт `creation_olap_database.sql`.
   
   ![image](https://github.com/user-attachments/assets/2018c430-a434-448d-8337-f187240c6821)
   [link to diagram](https://dbdiagram.io/d/olap_database-67814ac46b7fa355c38682e9)


5.  Запустите скрипт `ETL_from_oltp_to_olap.sql`.

    *   **Важно:** Если все предыдущие шаги выполнены корректно, этот скрипт должен отработать без ошибок.
    *   **Проблема с подключением:** Если возникла проблема с именем базы данных, именем пользователя или паролем, необходимо изменить строку подключения в каждом `INSERT` запросе внутри файла `ETL_from_oltp_to_olap.sql`.

    *   **Пример изменения строки подключения:**

    ```sql
    'dbname=oltp_database user=postgres password=123 host=localhost'
    ```

    *   Замените значения на актуальные, если они отличаются от стандартных. Например, если база данных называется `my_oltp_db`, пользователь `myuser`, а пароль `mypassword`, строка подключения будет выглядеть так:

    ```sql
        'dbname=my_oltp_db user=myuser password=mypassword host=localhost'
    ```

## Шаг 3: Запуск запросов

1.  Запустите запросы из файла `olap_queries.sql` для анализа данных в базе OLAP (`olap_database`). 

2.  Запустите запросы из файла `oltp_queries.sql` для работы с транзакционными данными в базе OLTP (`oltp_database`).

## Шаг 4: Отчет в Power BI

1.  Откройте файл `CourseWorkPB.pbix` в Power BI Desktop.

   
 *   **Важно:** Карта в отчете может не показываться, чтобы это исравить нажмите зайти как гость. Если же карта отображается, но не выделяет страны которые описаны в slicer, то нажмите несколько раз на страны которые описаны в slicer.


## Пояснения

Данный README описывает процесс создания и наполнения баз данных OLTP (Online Transaction Processing) и OLAP (Online Analytical Processing) с использованием SQL. Процесс включает в себя создание баз данных, импорт данных из CSV файлов, перенос данных из OLTP базы в OLAP базу с помощью ETL (Extract, Transform, Load) процесса, выполнение запросов к обеим базам и чтение отчета в Power BI.

**Ключевые файлы:**

*   `creation_oltp_database.sql`: Скрипт создания структуры базы данных OLTP.
*   `ETL_Goods.sql`, `ETL_Clients.sql`, `ETL_Orders_and_OrderDetails.sql`: Скрипты для импорта данных из CSV файлов в OLTP базу.
*   `ETL_from_oltp_to_olap.sql`: Скрипт для переноса данных из OLTP базы в OLAP базу.
*   `olap_queries.sql`: Скрипты с запросами к OLAP базе.
*   `oltp_queries.sql`: Скрипты с запросами к OLTP базе.
*   `CourseWorkPB.pbix`: Файл проекта Power BI с отчетом внутри.

**Важные моменты:**

*   Убедитесь, что пути к CSV файлам в скриптах указаны корректно.
*   При возникновении проблем с подключением к базе данных, проверьте корректность имени базы данных, имени пользователя и пароля в строке подключения.


Этот README был сгенерирован с помощью Gemini 2.0 :)
