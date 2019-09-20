import os
import psycopg2

def insert_sql():
    con_string = "host="+ os.environ['DB_ENDPOINT']  \
    +" port=5432 dbname=hardwareavailability user=postgres" \
    +" password="+ os.environ['DB_PASSWORD']
    con = psycopg2.connect(con_string)

    cursor = con.cursor()
    cursor.execute(open("database.sql", "r").read())
    cursor.close()
    
    con.commit()
    con.close()

if __name__ == "__main__":
    insert_sql()