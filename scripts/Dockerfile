FROM registry.redhat.io/ubi8/python-36

WORKDIR /opt/app-root/src

ADD requirements.txt .
 
RUN pip3 install -r requirements.txt
RUN mkdir -p ~/workspace
RUN chgrp -R 0 ~/workspace && chmod -R g=u ~/workspace
RUN mkdir -p ~/tmp
RUN chgrp -R 0 ~/tmp && chmod -R g=u ~/tmp

ADD . .

EXPOSE 5000

ENV FLASK_APP=start.py
ENV FLASK_ENV=production

CMD [ "flask", "run", "--host", "0.0.0.0" ]