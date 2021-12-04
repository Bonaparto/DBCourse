import psycopg2
from config import config

def get_trucks():
    sql = "SELECT * FROM employee_work_info WHERE way_of_delivery = 'truck';"
    conn = None
    try:
        params = config()
        conn = psycopg2.connect(**params)
        cur = conn.cursor()
        cur.execute(sql)
        rows = cur.fetchall()
        print('The number of parts:', cur.rowcount)
        with open('carriers.txt', 'w') as f:
            for row in rows:
                f.write("INSERT INTO carriers VALUES ({});\n".format(row[0]))
        cur.close()
    except(Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

get_trucks()