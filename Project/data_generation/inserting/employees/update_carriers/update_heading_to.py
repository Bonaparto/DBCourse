import random
import psycopg2
from config import config

orders = {}

delivery = {
    'Almaty': 1,
    'Astana': 2,
    'Atyrau': 3,
    'Moscow': 5,
    'Beijing': 4
}

where_to = {}

def get_orders():
    sql = "SELECT employee_id, id FROM order_secondary_info ORDER BY employee_id ASC;"
    conn = None
    try:
        params = config()
        conn = psycopg2.connect(**params)
        cur = conn.cursor()
        cur.execute(sql)
        rows = cur.fetchall()
        print('The number of parts:', cur.rowcount)
        global orders
        for row in rows:
            if row[0] not in orders.keys():
                orders[row[0]] = []
            orders[row[0]].append(row[1])
        cur.close()
    except(Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()


def get_where_to():
    sql = "SELECT id, where_to FROM order_primary_info;"
    conn = None
    try:
        params = config()
        conn = psycopg2.connect(**params)
        cur = conn.cursor()
        cur.execute(sql)
        rows = cur.fetchall()
        print('The number of parts:', cur.rowcount)
        global where_to
        for row in rows:
            where_to[row[0]] = (row[1])
        cur.close()
    except(Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

get_orders()
get_where_to()

with open('update_carriers.txt', 'w') as f:
    emps = list(orders.keys())
    for i in range(len(emps)):
        emp_id = emps[i]
        ind = 1
        next_point = 0
        if len(orders[emp_id]) == 1:
            ind = 0
            next_point = 'null'
        else:
            next_point = delivery[where_to[orders[emp_id][ind]]]
        if(next_point != 'null'):
            f.write("UPDATE carriers SET heading_to = '{}' WHERE carriers.id = {};\n".format(next_point, emp_id))
        else:
            f.write("UPDATE carriers SET heading_to = {} WHERE carriers.id = {};\n".format(next_point, emp_id))