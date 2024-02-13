FROM python:3.12-bookworm AS build

RUN adduser --disabled-password worker

WORKDIR /usr/src/app
RUN chown worker:worker /usr/src/app
ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  PIP_NO_CACHE_DIR=on \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_CACHE_DIR=/tmp/poetry_cache \
  POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=1 \
  POETRY_VIRTUALENVS_IN_PROJECT=1
RUN pip install poetry==1.7.1 --no-cache-dir

COPY pyproject.toml poetry.lock /usr/src/app/
RUN touch /usr/src/app/README.md

RUN --mount=type=cache,target=$POETRY_CACHE_DIR \
  poetry install --no-root



FROM python:3.12-slim-bookworm AS runtime

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password worker
USER worker

ENV VIRTUAL_ENV=/usr/src/app/.venv \
  PATH="/usr/src/app/.venv/bin:$PATH" \
  PYTHONPATH="/usr/src/app" \
  PORT=8000

COPY --from=build ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY . /usr/src/app

WORKDIR /usr/src/app/cde_demo

ENTRYPOINT ["python", "-m", "manage", "runserver", "0.0.0.0:8000"]
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "curl", "http://localhost:8000/" ]
