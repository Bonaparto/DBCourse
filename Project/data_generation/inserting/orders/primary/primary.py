import random
import psycopg2
from config import config

client_city = {}

def get_cities():
    sql = "SELECT client_id, city FROM client_address;"
    conn = None
    try:
        clit = {}
        params = config()
        conn = psycopg2.connect(**params)
        cur = conn.cursor()
        cur.execute(sql)
        rows = cur.fetchall()
        print('The number of parts:', cur.rowcount)
        global client_city
        for row in rows:
            client_city[row[0]] = row[1]
        # with open('couriers.txt', 'w') as f:
        #     for row in rows:
        #         f.write("INSERT INTO carriers VALUES ({});\n".format(row[0]))
        cur.close()
    except(Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

get_cities()

cities = ['Almaty', 'Astana', 'Atyrau', 'Moscow', 'Beijing']

city_country = {
    'Kazakhstan': ['Almaty', 'Astana', 'Atyrau'], 
    'Russia': 'Moscow', 
    'China': 'Beijing'
}

delivery = ['Overnight', 'Express', 'Standard']

b = [True, False]

chars = 'ABCDEFGHIJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz'
digits = '01234567890123456789'

with open('orders.txt', 'w') as f:
    for i in range(100):
        where_from = cities[random.randint(0, 4)]
        while where_from == client_city[i+1]:
            where_from = cities[random.randint(0, 4)]
        is_international = True
        kz = city_country['Kazakhstan']
        if where_from in kz and client_city[i+1] in kz:
            is_international = False
        f.write("INSERT INTO order_primary_info VALUES(DEFAULT, {}, '{}', '{}', '{}', {}, False, {}, DEFAULT, False);\n".format(i + 1, delivery[random.randint(0, 2)], where_from, client_city[i+1],
        b[random.randint(0, 1)], is_international))
