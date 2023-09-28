FROM python:3.11-buster as runner

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ARG POETRY_VERSION=1.2.2

RUN pip install poetry==${POETRY_VERSION} \
  && apt update -y \
  && apt install -y xfonts-75dpi xfonts-base \
  && wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
  && dpkg -i  wkhtmltox_0.12.5-1.buster_amd64.deb


WORKDIR /code

COPY poetry.lock pyproject.toml /code/

RUN poetry config virtualenvs.create false && \
  poetry install --no-interaction --no-ansi --no-dev 

COPY . .

# PROD
# CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "magnificent.wsgi:application", "--timeout", "180"]
# Local
CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]