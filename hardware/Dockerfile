FROM python:alpine3.9

COPY src /app

WORKDIR /app

RUN ls -ltra && apk update && apk add sqlite

RUN sqlite3 database.db < database.sql

RUN pip install -r requirements.txt

ENTRYPOINT ["python"]

CMD ["hardware.py"]

EXPOSE 5001/tcp