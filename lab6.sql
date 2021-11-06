a. SELECT * FROM dealer
CROSS JOIN client;

b. SELECT s.dealer_id, c.name, c.city, c.priority, s.date, s.amount FROM
client as c INNER JOIN sell as s ON c.id = s.client_id;

c.SELECT * FROM dealer
INNER JOIN client ON dealer.location = client.city;

d. SELECT sell.id, amount, name, city FROM
client INNER JOIN sell ON client.id = sell.client_id WHERE amount >= 100 and amount <= 500;

e. SELECT dealer.id, dealer.name, dealer.location, dealer.charge FROM dealer
INNER JOIN client ON client.dealer_id = dealer.id;

f. SELECT c.name as client_name, c.city as client_city, d.name as dealer_name, charge FROM
dealer as d INNER JOIN client as c ON d.id = c.dealer_id;

g. SELECT c.name as client_name, c.city as client_city, ds.name as dealer_name, ds.charge as charge FROM
((SELECT * FROM dealer WHERE charge > 0.11) as d
INNER JOIN sell as s ON s.dealer_id = d.id) as ds
INNER JOIN client as c ON ds.client_id = c.id;

h. NOT DONE SELECT foo.name, foo.city, s.client_id, foo.name, foo.charge FROM ((dealer as d
NATURAL JOIN client as c WHERE c.dealer_id = d.id) as foo
NATURAL JOIN sell as s WHERE s.dealer_id = foo.dealer_id);


a. CREATE view general_sell_info as
    SELECT count(distinct client_id) as clients_amount, avg(amount) as avg_sum, sum(amount) as total_sum, date FROM
    (SELECT client_id, amount, date FROM sell) as foo GROUP BY date ORDER BY date;

b. CREATE view top_5_dates as
    SELECT sum(amount) as sum, date FROM
    (SELECT amount, date FROM sell) as foo GROUP BY date ORDER BY sum DESC limit 5;

c. CREATE view general_dealer_sells_info as
    SELECT distinct dealer_id, count(dealer_id) as sells_num, avg(amount) as avg_sum, sum(amount) as total_sum FROM
    (SELECT dealer_id, amount FROM sell) as foo GROUP BY dealer_id;

 d. CREATE view location_charge_earns as
    SELECT distinct  location, sum(charges) as total_charges FROM
    (SELECT location, (amount * charge) as charges FROM dealer, sell
    WHERE dealer.id = sell.dealer_id) as foo GROUP BY location;

e. CREATE view location_sales_info as
    SELECT location, count(location), sum(amount) as amount_sum, avg(amount) as avg_amount FROM
    (SELECT location, amount FROM dealer, sell
    WHERE dealer.id = sell.dealer_id) as foo GROUP BY location;

 f. CREATE view city_sales_info as
    SELECT city, count(foo.id) as num_of_sells, avg(amount) as avg_sum, sum(amount) as total_sum FROM
    (SELECT city, sell.id, amount FROM sell, client
    WHERE client.id = sell.client_id) as foo GROUP BY city;

g. CREATE view strong_cities as
    SELECT city, total_expenses FROM
    ((SELECT city, sum(amount) as total_expenses FROM sell, client WHERE sell.client_id = client.id GROUP BY city) as lol CROSS JOIN
    (SELECT sum(amount) as location_amount_sum FROM dealer, sell WHERE dealer.id = sell.dealer_id) as lmao)
    WHERE total_expenses > location_amount_sum;
