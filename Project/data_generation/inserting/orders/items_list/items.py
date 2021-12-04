import random
import psycopg2
from config import config

products = []

def get_products():
    sql = "SELECT id FROM order_primary_info;"
    conn = None
    try:
        params = config()
        conn = psycopg2.connect(**params)
        cur = conn.cursor()
        cur.execute(sql)
        rows = cur.fetchall()
        print('The number of parts:', cur.rowcount)
        global products
        for row in rows:
            products.append(row[0])
        cur.close()
    except(Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

get_products()

b = [True, False]

chars = 'ABCDEFGHIJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz'
digits = '01234567890123456789'

with open('order_items_list.txt', 'w') as f:
    f.write("INSERT INTO order_items_list VALUES\n")
    for i in range(100):
        for j in range(random.randint(1, 5)):
            f.write("(DEFAULT, {}, {}, {}),\n".format(products[i], random.randint(1, 100), random.randint(1, 10)))
