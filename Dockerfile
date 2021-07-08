FROM python:3.8

ADD requirements.txt /requirements.txt

RUN pip install -r requirements.txt

RUN python -m ipykernel install --name conda-env-gw-py

ADD nb /repo

ENTRYPOINT nb2service /repo/ --host 0.0.0.0 --port 8000
