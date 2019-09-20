from flask import Flask, request, jsonify
import os
import psycopg2
import time
import random
application = Flask(__name__)


def slow_process_to_calculate_availability(provider, name):
    time.sleep(5)
    return random.choice(['HIGH', 'MEDIUM', 'LOW'])


@application.route('/hardware/')
def hardware():
    con_string = "host="+ os.environ['DB_ENDPOINT']  \
    +" port=5432 dbname=hardwareavailability user=postgres" \
    +" password="+ os.environ['DB_PASSWORD']
    con = psycopg2.connect(con_string)

    c = con.cursor()
    c.execute('SELECT * from hardware')
    statuses = [
        {
            'provider': row[1],
            'name': row[2],
            'availability': slow_process_to_calculate_availability(
                row[1],
                row[2]
            ),
        }
        for row in c.fetchall()
    ]

    con.close()

    return jsonify(statuses)


if __name__ == "__main__":
    application.run(host='0.0.0.0', port=5001)
