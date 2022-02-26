FROM python:3.7-alpine3.10

# Arguments for build tracking
ARG BRANCH=
ARG COMMIT=

ENV \
  APP_DIR=traktarr \
  BRANCH=${BRANCH} \
  COMMIT=${COMMIT} \
  TRAKTARR_CONFIG=/config/config.json \
  TRAKTARR_CACHEFILE=/config/cache.db \
  TRAKTARR_LOGFILE=/config/traktarr.log

RUN rm -rvf /${APP_DIR}
COPY . /${APP_DIR}

RUN echo "** BRANCH: ${BRANCH} COMMIT: ${COMMIT} **" 
RUN echo "** Upgrade all packages **"
RUN apk --no-cache -U upgrade
RUN pip install --no-cache-dir --upgrade pip setuptools
RUN ls -lia /${APP_DIR} && pip install --no-cache-dir --upgrade -r /${APP_DIR}/requirements.txt

# Change directory
WORKDIR /${APP_DIR}

RUN rm -rvf /${APP_DIR}

# Entrypoint
ENTRYPOINT ["python", "traktarr.py", "run"]
