FROM python:alpine3.9

COPY src /app

WORKDIR /app

RUN pip install -r requirements.txt

ENTRYPOINT ["python"]

CMD ["portal.py"]

EXPOSE 5000/tcp
