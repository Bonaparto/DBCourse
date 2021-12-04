--- CLIENT INFO


--- Клиент сначала создает аккаунт в любом случае.
--- если у клиента есть контракт с компанией,
--- то на него есть триггер, который списывает в начале месяца
--- определенную сумму с карты.
CREATE TABLE client_account
(
    id           serial PRIMARY KEY,
    email        varchar(100) NOT NULL,
    password     varchar(100) NOT NULL,
    has_contract boolean      NOT NULL
);

--- Затем собирается нужная личная информация клиента.
CREATE TABLE client_personal_info
(
    id          integer references client_account PRIMARY KEY,
    first_name  varchar(100)                      NOT NULL,
    second_name varchar(100)                      NOT NULL,
    gender      char CHECK (gender in ('m', 'f')) NOT NULL,
    age         integer                           NOT NULL,
    phone       varchar(15)                       NOT NULL
);


--- Обязательная информация для доставки до двери.
--- Возможны доставки либо до пункта выдачи, либо до двери заказчика.
CREATE TABLE client_address
(
    client_id integer references client_account PRIMARY KEY,
    country   varchar(100) NOT NULL,
    city      varchar(100) NOT NULL,
    street    varchar(100) NOT NULL,
    house     varchar(100) NOT NULL,
    zip       integer      NOT NULL
);

--- Т.к. предусмотрена только оплата наличными или картой(и никак больше онлайн),
--- создается таблица для случая нескольких карт на одном аккаунте
CREATE TABLE client_payment_cards
(
    id          serial PRIMARY KEY,
    client_id   integer references client_account NOT NULL,
    card_number numeric(16)                       NOT NULL
);


--- EMPLOYEE INFO

CREATE TABLE employee_account
(
    id       serial PRIMARY KEY,
    email    varchar(100) NOT NULL,
    password varchar(100) NOT NULL
);

CREATE TABLE employee_personal_info
(
    employee_id integer references employee_account PRIMARY KEY,
    first_name  varchar(100)                      NOT NULL,
    second_name varchar(100)                      NOT NULL,
    gender      char CHECK (gender in ('m', 'f')) NOT NULL,
    age         integer                           NOT NULL,
    phone       varchar(15)                       NOT NULL
);

CREATE TABLE employee_address
(
    employee_id integer references employee_account PRIMARY KEY,
    country     varchar(100) NOT NULL,
    city        varchar(100) NOT NULL,
    street      varchar(100) NOT NULL,
    house       varchar(100) NOT NULL
);

CREATE TABLE employee_work_info
(
    id               integer references employee_account PRIMARY KEY,
    recruitment_date date         NOT NULL,
    salary           integer      NOT NULL,
    way_of_delivery  varchar(100) NOT NULL
);

CREATE TABLE couriers
(
    id         integer references employee_account PRIMARY KEY,
    heading_to integer references client_address
);

CREATE TABLE carriers
(
    id         integer references employee_account PRIMARY KEY,
    heading_to integer references delivery_points
);


--- DELIVERY INFO

CREATE TABLE tracking
(
    id       serial PRIMARY KEY,
    order_id integer references order_primary_info NOT NULL,
    location varchar(100)                          NOT NULL,
    date     date DEFAULT current_date             NOT NULL
);

CREATE TABLE delivery_types
(
    name     varchar(100) PRIMARY KEY,
    duration integer NOT NULL,
    cost     numeric NOT NULL
);


--- order_primary_info


CREATE TABLE order_primary_info
(
    id                 serial PRIMARY KEY,
    client_id          integer references client_account      NOT NULL,
    delivery_type_name varchar(100) references delivery_types NOT NULL,
    where_from         varchar(100)                           NOT NULL,
    where_to           varchar(100)                           NOT NULL,
    to_the_door        boolean                                NOT NULL,
    is_complete        boolean                                NOT NULL,
    is_international   boolean                                NOT NULL,
    creation_date      date DEFAULT current_date              NOT NULL,
    completion_date    date DEFAULT current_date
);

CREATE TABLE order_items_list
(
    id          serial primary key,
    order_id    integer references order_primary_info NOT NULL,
    item_id     integer references products           NOT NULL,
    item_amount integer                               NOT NULL
);

CREATE TABLE order_total_info
(
    order_id      integer references order_primary_info PRIMARY KEY,
    items_amount  integer NOT NULL,
    total_weight  numeric NOT NULL,
    total_sum     numeric NOT NULL,
    has_hazardous boolean NOT NULL
);

CREATE TABLE order_secondary_info
(
    id                        integer references order_primary_info PRIMARY KEY,
    employee_id               integer references employee_account NOT NULL,
    approximate_delivery_date date                                NOT NULL,
    paid_online               boolean                             NOT NULL
);


--- DELIVERY POINTS

CREATE table delivery_points
(
    id      serial primary key,
    country varchar(100) NOT NULL,
    city    varchar(100) NOT NULL
);

CREATE table delivery_point_orders
(
    id                serial PRIMARY KEY,
    delivery_point_id integer references delivery_points    NOT NULL,
    order_id          integer references order_primary_info NOT NULL
);


--- DROP TABLES

drop table tracking, order_items_list, products,
    client_personal_info, client_address, client_payment_cards,
    couriers, carriers, employee_work_info, employee_address, employee_personal_info,
    delivery_point_orders, delivery_points, order_secondary_info, order_total_info, order_items_list,
    order_primary_info, client_account, employee_account, delivery_types;


--- INDICES

CREATE INDEX op_id
    on order_primary_info (id);

CREATE INDEX op_from
    on order_primary_info (where_from);

CREATE INDEX op_to
    on order_primary_info (where_to);

CREATE INDEX os_id
    on order_secondary_info (id);

CREATE INDEX os_employee
    on order_secondary_info (employee_id);

CREATE INDEX track_order
    on tracking (order_id);

CREATE INDEX product_id
    on products (id);


--- TRIGGERS

CREATE FUNCTION fill_secondary()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
as
$$
DECLARE
    e_id                     integer;
    DECLARE approximate_date integer;
    DECLARE paid_online      boolean;
    DECLARE delivery_point   integer;
BEGIN

    e_id = (SELECT id FROM carriers ORDER BY RANDOM() LIMIT 1);

    approximate_date = (SELECT duration FROM delivery_types WHERE delivery_types.name = new.delivery_type_name);

    paid_online = (SELECT has_contract FROM client_account WHERE client_account.id = new.client_id);

    delivery_point = (SELECT id FROM delivery_points d WHERE new.where_to = d.city);

    INSERT INTO order_secondary_info
    VALUES (new.id, e_id, new.creation_date + approximate_date, paid_online);

    UPDATE carriers SET heading_to = delivery_point WHERE id = e_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER fill_order_secondary_info
    after INSERT
    on order_primary_info
    for each row
execute function fill_secondary();



CREATE FUNCTION make_total()
    RETURNS TRIGGER
    LANGUAGE plpgsql
as
$$
DECLARE
    tot_sum            integer;
    DECLARE hazardous  boolean;
    DECLARE tot_weight numeric;
begin
    IF (SELECT order_id
        FROM order_total_info o
        WHERE o.order_id = new.order_id) IS NULL THEN
        tot_sum = 0;
        IF (SELECT is_international FROM order_primary_info WHERE new.order_id = order_primary_info.id) THEN
            tot_sum = tot_sum + 10000;
        end if;
        IF (SELECT to_the_door FROM order_primary_info WHERE new.order_id = order_primary_info.id) THEN
            tot_sum = tot_sum + 5000;
        end if;
        hazardous = (SELECT is_hazardous FROM products p WHERE new.item_id = p.id);
        IF hazardous = True THEN
            tot_sum = tot_sum + 10000;
        end if;
        tot_weight = (SELECT weight FROM products p WHERE p.id = new.item_id) * new.item_amount;
        tot_sum = tot_sum + tot_weight * 1000;
        tot_sum = tot_sum * (SELECT cost
                             FROM delivery_types d,
                                  order_primary_info o
                             WHERE new.order_id = o.id
                               AND o.delivery_type_name = d.name);
        INSERT INTO order_total_info
        VALUES (new.order_id, new.item_amount, tot_weight, tot_sum, hazardous);
    ELSE
        hazardous = (SELECT is_hazardous FROM products p WHERE new.item_id = p.id);
        UPDATE order_total_info o
        SET items_amount  = items_amount + new.item_amount,
            total_weight  = total_weight + new.item_amount * (SELECT weight FROM products p WHERE new.item_id = p.id),
            total_sum     = total_sum + 1000 * (SELECT weight FROM products p WHERE new.item_id = p.id),
            has_hazardous = hazardous
        WHERE o.order_id = new.order_id;
    end if;
    RETURN NEW;
end;
$$;

CREATE TRIGGER make_total_info
    after INSERT
    on order_items_list
    for each row
execute function make_total();



CREATE FUNCTION tracking()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
as
$$
DECLARE
    t_row order_secondary_info%rowtype;
BEGIN
    IF old.heading_to IS NULL THEN
        INSERT INTO tracking
        VALUES (DEFAULT, (SELECT os.id FROM order_secondary_info os WHERE os.employee_id = new.id),
                (SELECT where_from
                 FROM order_primary_info op
                 WHERE (SELECT os.id
                        FROM order_secondary_info os
                        WHERE new.id = os.employee_id) = op.id), DEFAULT);
    ELSE
        FOR t_row in SELECT os.id
                     FROM order_secondary_info os
                     WHERE os.employee_id = old.id
            LOOP
                INSERT INTO tracking
                VALUES (DEFAULT, t_row.id, (SELECT city FROM delivery_points d WHERE old.heading_to = d.id), DEFAULT);
            end loop;
    end if;
    RETURN NEW;
END;
$$;

CREATE TRIGGER add_to_tracking
    after UPDATE or INSERT
    on carriers
    for each row
execute function tracking();



CREATE FUNCTION change()
    RETURNS TRIGGER
    LANGUAGE plpgsql
as
$$
begin
    IF new.location = (SELECT where_to
                       FROM order_primary_info op
                       WHERE op.id = new.order_id) THEN
        IF NOT (SELECT to_the_door
                FROM order_primary_info op
                WHERE op.id = new.order_id) THEN
            INSERT INTO delivery_point_orders
            VALUES (DEFAULT, (SELECT dp.id
                              FROM delivery_points dp
                              WHERE dp.city = (SELECT op.where_to
                                               FROM order_primary_info op
                                               WHERE op.id = new.order_id)), new.order_id);
            UPDATE order_primary_info SET is_complete = True, completion_date = DEFAULT WHERE id = new.order_id;
            DELETE FROM order_secondary_info os WHERE new.order_id = os.id;
        ELSE
            UPDATE order_secondary_info
            SET employee_id = (SELECT id FROM couriers ORDER BY RANDOM() LIMIT 1)
            WHERE id = new.order_id;
            UPDATE couriers
            SET heading_to = (SELECT op.client_id
                              FROM order_primary_info op
                              WHERE op.id = new.order_id)
            WHERE couriers.id = (SELECT id FROM couriers ORDER BY RANDOM() LIMIT 1);
        end if;
    end if;
    RETURN NEW;
end;
$$;

CREATE TRIGGER status_change
    after INSERT or UPDATE
    on tracking
    for each row
execute function change();


drop trigger status_change on tracking;
drop function change();
drop trigger make_total_info on order_items_list;
drop function make_total();
drop trigger add_to_tracking on carriers;
drop function tracking();
drop trigger fill_order_secondary_info on order_primary_info;
drop function fill_secondary();


UPDATE couriers
SET heading_to = null;
UPDATE carriers
SET heading_to = null;
delete
from order_items_list;
delete
from order_total_info;
delete
from tracking;
delete
from delivery_point_orders;
delete
from order_secondary_info;
delete
from order_primary_info;
