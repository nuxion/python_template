FROM python:3.8-slim as builder

SHELL ["/bin/bash", "-c"]
ADD requirements.txt /tmp
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends\
    build-essential \
    git \
    #&& python -m venv /tmp/.venv \
    #&& source /tmp/.venv/bin/activate \
    && pip install --user -r /tmp/requirements.txt


FROM python:3.8.10-slim as app
LABEL maintener="Xavier Petit <nuxion@gmail.com>"
RUN useradd -m -d /home/app app 
COPY --from=builder --chown=app:app /root/.local /home/app/.local/
COPY --chown=app:app . /app

USER app
WORKDIR /app
ENV PATH=$PATH:/home/app/.local/bin
# RUN mkdir /app/multiproc
# ENV prometheus_multiproc_dir=multiproc
ENV PYTHONPATH=/app
# EXPOSE 3333
CMD ["python3", "run.py"]
