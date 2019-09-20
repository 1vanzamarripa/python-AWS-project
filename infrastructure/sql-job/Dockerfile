FROM python:3.7.4-slim

COPY src /app

WORKDIR /app

RUN apt update && apt -y install libpq-dev gcc

RUN pip install -r requirements.txt

ENTRYPOINT ["python"]

CMD ["db-init.py"]
