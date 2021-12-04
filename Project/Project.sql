--- QUERIES


-- TO FIND PACKAGES ON CRUSHED TRACK
SELECT client_id
FROM order_primary_info op
WHERE op.id = (SELECT id
               FROM order_secondary_info
               WHERE employee_id = 'some_number');


-- TO FIND THE CUSTOMER WHO HAS SHIPPED MOST PACKAGES IN THE PAST YEAR;

SELECT lmao.client_id
FROM (SELECT client_id, count(client_id) as c_c
      FROM order_primary_info
      WHERE is_complete = True
        and current_date - completion_date < 365
      GROUP BY client_id) as lmao
WHERE lmao.c_c = (SELECT max(c_c)
                  FROM (SELECT client_id, count(client_id) as c_c
                        FROM order_primary_info
                        WHERE is_complete = True
                        GROUP BY client_id) as foo);


-- TO FIND CUSTOMER WHO HAS SPENT THE MOST MONEY ON SHIPPING THE PAST YEAR;

SELECT client_id, s
FROM (SELECT client_id, sum(total_sum) as s
      FROM (SELECT op.client_id, ot.total_sum
            FROM order_primary_info op,
                 order_total_info ot
            WHERE op.id = ot.order_id) as lmao
      GROUP BY client_id) as foo
WHERE foo.s = (SELECT max(s)
               FROM (SELECT sum(total_sum) as s
                     FROM (SELECT op.client_id, ot.total_sum
                           FROM order_primary_info op,
                                order_total_info ot
                           WHERE op.id = ot.order_id
                             and current_date - op.completion_date < 365) as lmao
                     GROUP BY client_id) as kek
               GROUP BY client_id);


-- TO FIND THE STREET WITH THE MOST CUSTOMERS;

SELECT street, s
FROM (SELECT street, count(street) as s FROM client_address c GROUP BY street)
         as foo
WHERE foo.s =
      (SELECT max(s)
       FROM (SELECT count(street) as s FROM client_address c GROUP BY street)
                as foo
       GROUP BY street);


-- TO FIND THE PACKAGES THAT WERE NOT DELIVERED WITHIN THE PROMISED TIME;

SELECT id, creation_date, completion_date, delivery_type_name
FROM order_primary_info op
WHERE completion_date - creation_date > (SELECT duration
                                         FROM delivery_types d
                                         WHERE d.name = op.delivery_type_name);


--- BILLS

-- SIMPLE BILL
SELECT first_name, second_name, country, city, street, house, foo.tot_sum as amount
FROM client_address ca,
     client_personal_info cp,
     (SELECT client_id, sum(total_sum) as tot_sum
      FROM order_primary_info op,
           order_total_info ot
      WHERE op.id = ot.order_id
        and current_date - op.completion_date < 30
      GROUP by client_id)
         as foo
WHERE foo.client_id = ca.client_id
  and foo.client_id = cp.id;

-- CHARGES BY TYPE OF SERVICE

SELECT kek1.client_id, international, to_the_door, hazardous, overnight, express
FROM (SELECT client_id, international, to_the_door
      FROM (SELECT client_id, 10000 * count(is_international) as international, 5000 * count(to_the_door) as to_the_door
            FROM order_primary_info
            GROUP BY client_id) as foo) as kek
         FULL JOIN
     (SELECT client_id, hazardous
      FROM (SELECT client_id, 10000 * count(has_hazardous) as hazardous
            FROM order_total_info ot,
                 order_primary_info op
            WHERE ot.order_id = op.id
            GROUP BY client_id) as foo2) as kek1 on kek.client_id = kek1.client_id
         FULL JOIN
     (SELECT client_id, overnight
      FROM (SELECT client_id, 0.9 * total_sum as overnight
            FROM order_primary_info op,
                 order_total_info ot
            WHERE op.id = ot.order_id
              and op.delivery_type_name = 'Overnight') as foo3) as kek2 on kek.client_id = kek2.client_id
         FULL JOIN
     (SELECT client_id, express
      FROM (SELECT client_id, 0.67 * total_sum as express
            FROM order_primary_info op,
                 order_total_info ot
            WHERE op.id = ot.order_id
              and op.delivery_type_name = 'Express') as foo4) as kek3 on kek.client_id = kek3.client_id;


-- ITEMIZE BILLING;

SELECT client_id, name as item_name, item_amount, weight * item_amount * 1000 as cost
FROM (SELECT order_id, name, item_id, item_amount, weight
      FROM order_items_list as foo
               INNER JOIN
           products p on foo.item_id = p.id) as kek
         INNER JOIN order_primary_info op on op.id = kek.order_id;

