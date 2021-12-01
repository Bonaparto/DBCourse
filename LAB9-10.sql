1.

a.

create function increment(n NUMERIC)
    returns NUMERIC
    language plpgsql
    as
    $$
    begin
        return n + 1;
    end;
    $$;

b.

create function sum(a NUMERIC, b NUMERIC)
returns NUMERIC
language plpgsql
as
$$
begin
return a + b;
end;
$$;

c.

create function is_divisible_by_two(n NUMERIC)
returns boolean
language plpgsql
as
$$
begin
    RETURN CASE
        WHEN n % 2 = 0 THEN true
        ELSE false
    end;
end;
$$;

d.

create function is_CorrectPassword(pass VARCHAR(20))
returns boolean
language plpgsql
as
$$
begin
    RETURN CASE
       WHEN pass SIMILAR TO 'blablabla%' THEN TRUE
       ELSE FALSE
    END;
end;
$$;

e.

create function square_and_cube(n NUMERIC, out square_of_n NUMERIC, out cube_of_n NUMERIC)
language plpgsql
as
$$
begin
    square_of_n = n * n;
    cube_of_n = n * n * n;
end;
$$;

select * from square_and_cube(123);


2.

a.

create table operations
(
    date timestamp PRIMARY KEY
);

create function operation_Date()
returns trigger
language plpgsql
as $$
begin
    INSERT INTO operations (date)
    VALUES (now());
    return new;
end;
$$;

create trigger operation_Date_Collect
    after INSERT OR UPDATE OR DELETE
    on task4
    for each row
    execute function operation_Date();

drop function operation_Date();
drop trigger operation_Date_Collect on task4;
drop table operations;

INSERT INTO task4 VALUES (7, 'asd', '1994-12-12', 1, 1, 1, 1);
DELETE FROM task4 WHERE id = 1;
UPDATE task4 SET id = 1 WHERE id = 2;

b.

create table ages (
    id integer PRIMARY KEY,
    age integer
);

drop table ages;
drop trigger calculate_age on task4;
drop function get_age();

create function get_age()
returns trigger
language plpgsql
as $$
begin
    INSERT INTO ages (id, age)
    VALUES (new.id, EXTRACT(YEAR from AGE(new.date_of_birth)));
    return new;
end;
$$;

create trigger calculate_age
    after INSERT on task4
        for each row
        execute function get_age();

c.

create table items
       (
    id integer PRIMARY KEY,
    price integer
);

INSERT INTO items VALUES (1, 100);

create function tax()
returns trigger
language plpgsql
as $$
begin
    UPDATE items SET price = price + price * 0.12;
    return new;
end;
$$;

create trigger add_tax
    after INSERT on items
        for each row
        execute function tax();

d.

create function cancel()
returns trigger
language plpgsql
as $$
begin
    RAISE EXCEPTION 'Deletion canceled.';
end;
$$;

drop trigger deletion_cancel on items;
drop function cancel();

create trigger deletion_cancel
    before DELETE on items
        for each row
        execute function cancel();

delete from items where id = 1;

e.

create type sq_cu as(
    sq integer,
    cu integer
);

create table temp
       (
    is_Correct boolean,
    square integer
)

drop table temp;
drop function start_functions();
drop trigger from_first_task on task4;

create function start_functions()
returns trigger
language plpgsql
as $$
    declare sq_cu record;
    declare sq integer;
begin
    sq_cu = square_and_cube(new.salary);
    sq = sq_cu.square_of_n;
    INSERT INTO temp(is_correct, square)
    VALUES (is_CorrectPassword(new.name), sq);
    return new;
end;
$$;


create trigger from_first_task
    after INSERT on task4
        for each row
        execute function start_functions();


insert into task4 values(10, 'asd', '1994-12-12', 1, 2, 1, 1);

3.

Function is used to take input and return some result;

Procedure is a set of commands, which can manipulate data in schema;


4.

a)

create procedure two_years_benefits()
language plpgsql
as $$
begin
    UPDATE task4 SET salary = salary + salary * 0.1 * floor(workexperience / 2);
    UPDATE task4 SET discount = 10 WHERE workexperience >= 2;
    UPDATE task4 SET discount = discount + (1 * floor((workexperience - 5) / 2)) WHERE workexperience > 5;
end;
$$;

b)

create procedure forty_years_benefits()
language plpgsql
as $$
    begin
        call two_years_benefits();
        UPDATE task4 SET salary = salary + salary * 0.15 WHERE age >= 40;
        UPDATE task4 SET salary = salary + salary * 0.15, discount = discount + 20 WHERE workexperience > 8;
    end;
$$;


5.

create table members (
    memid integer primary key,
    recommendedby integer references members
);

drop table members;

insert into members(memid) values (12), (22);

insert into members(memid, recommendedby) values
                           (2, 12),
                           (3, 12),
                           (4, 12),
                           (5, 22),
                           (6, 22),
                           (7, 22),
                           (8, 22),
                           (9, 12);

insert into members(memid, recommendedby) values
(10, 9),
                           (11, 9),
                           (13, 9),
                           (14, 9);

drop table members;

with recursive recommenders_chain as (
    select
        memid,
        recommendedby
    from
        members
    where
        memid = 12 or memid = 22
    union
        select
            m.memid,
            m.recommendedby
        from
            members m
        inner join recommenders_chain r on r.memid = m.recommendedby
) select
    *
    from recommenders_chain
    order by recommendedby desc;



