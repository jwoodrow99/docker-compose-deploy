FROM python:3.9.16

WORKDIR /usr/src/app

ADD ./config/nginx/sites/python/ ./

EXPOSE 9000

CMD ["python", "./index.py"]
