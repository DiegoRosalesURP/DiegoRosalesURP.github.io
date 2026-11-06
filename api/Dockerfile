FROM alpine:3.22 AS builder

RUN apk add --no-cache \
    python3=3.12.16-r0 \
    py3-pip=25.1.1-r0 \
    && apk update \
    && apk upgrade --no-cache

WORKDIR /build

COPY requirements.txt .

RUN python3 -m venv /venv \
    && /venv/bin/pip install --no-cache-dir -r requirements.txt \
    && find /venv -type d -name "__pycache__" -prune -exec rm -rf {} + \
    && find /venv -type f -name "*.pyc" -delete


FROM alpine:3.22

LABEL org.opencontainers.image.source="https://github.com/DiegoRosalesURP/DiegoRosalesURP.github.io"

RUN apk add --no-cache python3=3.12.16-r0 \
    && apk update \
    && apk upgrade --no-cache

WORKDIR /app

COPY --from=builder /venv /venv
COPY app.py .

ENV PATH="/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1

USER nobody

EXPOSE 3000

CMD ["gunicorn", "--bind", "0.0.0.0:3000", "app:app"]
