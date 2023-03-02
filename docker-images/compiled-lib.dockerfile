FROM python:3.11.2 AS develop-stage
WORKDIR /app
ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    POETRY_VERSION=1.1.7 \
    PYTHONPATH=/app \
    TA_LIBRARY_PATH=/ta-lib/lib \
    TA_INCLUDE_PATH=/ta-lib/include
ADD vendor/ta-lib-0.4.0.tar.gz /tmp
COPY ./app/pyproject.toml /app/
RUN python -m venv /venv
RUN cd /tmp/ta-lib/ && \
  ./configure --prefix=/ta-lib && \
  make && \
  make install
ENV PATH="/venv/bin:$PATH" \
    VIRTUAL_ENV=/venv
RUN pip install "poetry==$POETRY_VERSION"
RUN poetry install -E talib
ENTRYPOINT ["dumb-init", "--"]
CMD ["/app/scripts/run.sh"]

FROM python:3.11.2 AS build-stage
WORKDIR /app
ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    POETRY_VERSION=1.1.7 \
    PYTHONPATH=/app \
    TA_LIBRARY_PATH=/ta-lib/lib \
    TA_INCLUDE_PATH=/ta-lib/include
ADD vendor/ta-lib-0.4.0.tar.gz /tmp
COPY ./app/pyproject.toml /app/
RUN python -m venv /venv
RUN cd /tmp/ta-lib/ && \
  ./configure --prefix=/ta-lib && \
  make && \
  make install
ENV PATH="/venv/bin:$PATH" \
    VIRTUAL_ENV=/venv
RUN pip install "poetry==$POETRY_VERSION"
RUN poetry install --no-dev -E talib

FROM python:3.11.2-slim
WORKDIR /app
ENV PATH="/venv/bin:$PATH"
ENV PYTHONPATH=/app
COPY ./app /app
COPY --from=build-stage /venv /venv
COPY --from=develop-stage /ta-lib /ta-lib
ENTRYPOINT ["dumb-init", "--"]
CMD ["/app/scripts/run.sh"]
