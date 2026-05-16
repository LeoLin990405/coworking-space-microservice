FROM python:3.11-slim

WORKDIR /app

# Install build dependencies for psycopg2 and remove package lists to keep the
# final image compact.
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV APP_PORT=5153
EXPOSE 5153

CMD ["python", "app.py"]
