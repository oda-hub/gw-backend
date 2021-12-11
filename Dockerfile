FROM python:3.8

ADD requirements.txt /requirements.txt

RUN pip install -r requirements.txt
RUN curl -o /usr/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64; chmod +x /usr/bin/jq

ADD nb /repo
RUN for nn in /repo/*.ipynb; do mv $nn $nn-tmp;  jq '.metadata.kernelspec.name |= "python3"' $nn-tmp > $nn ; rm $nn-tmp ; done

ENTRYPOINT nb2service /repo/ --host 0.0.0.0 --port 8000
