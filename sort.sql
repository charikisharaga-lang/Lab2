1. Выбрать дни недели, в которые почтовые отделения работают больше 8 часов.
SELECT DISTINCT day_of_week
FROM work_schedule
WHERE (end_time - start_time) -
      (break_end_time - break_start_time) > INTERVAL '8 hours';

2. Выбрать отделы почтовых отделений, которые обслуживают только физических лиц и принимают заказные письма.
SELECT *
FROM departments
WHERE serves_individuals = TRUE
  AND serves_legal_entities = FALSE
  AND department_functions ILIKE '%заказные письма%';

3. Создать таблицу, содержащую данные 1 запроса с указанием времени начала и окончания работы, времени начала и окончания перерывов и данных об отделах.
DROP TABLE IF EXISTS result_table;

CREATE TABLE result_table AS
SELECT
    ws.post_office_cod,
    ws.department_id,
    ws.day_of_week,
    ws.start_time,
    ws.end_time,
    ws.break_start_time,
    ws.break_end_time,
    d.name,
    d.serves_individuals,
    d.serves_legal_entities,
    d.department_functions
FROM work_schedule ws
JOIN departments d
    ON ws.department_id = d.department_cod
WHERE (ws.end_time - ws.start_time) -
      (ws.break_end_time - ws.break_start_time) > INTERVAL '8 hours';

 4. Добавить в созданную таблицу отделы, названия которых состоят из нескольких слов.
INSERT INTO result_table
SELECT
    ws.post_office_cod,
    ws.department_id,
    ws.day_of_week,
    ws.start_time,
    ws.end_time,
    ws.break_start_time,
    ws.break_end_time,
    d.name,
    d.serves_individuals,
    d.serves_legal_entities,
    d.department_functions
FROM work_schedule ws
JOIN departments d
    ON ws.department_id = d.department_cod
WHERE d.name ~ '\s+';

5. В созданной таблице для всех отделов, обслуживающих только юридических лиц, включить опцию обслуживания физических лиц.
UPDATE result_table
SET serves_individuals = TRUE
WHERE serves_legal_entities = TRUE
  AND serves_individuals = FALSE;

6. Удалить из созданной таблицы все отделы, перерыв в которых меньше получаса.
DELETE FROM result_table
WHERE (break_end_time - break_start_time) < INTERVAL '30 minutes';

7. Посчитать количество отделов, обслуживающих только юридических лиц, и отделов, обслуживающих все категории клиентов в каждый из дней недели.
SELECT
    day_of_week,
    COUNT(DISTINCT department_id)
        FILTER (
            WHERE serves_legal_entities = TRUE
              AND serves_individuals = FALSE
        ) AS only_legal,
    COUNT(DISTINCT department_id)
        FILTER (
            WHERE serves_legal_entities = TRUE
              AND serves_individuals = TRUE
        ) AS all_clients
FROM result_table
GROUP BY day_of_week
ORDER BY day_of_week;
