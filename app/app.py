
import os
from flask import Flask, jsonify
import psycopg

app = Flask(__name__)

SERVER_NAME = os.getenv("SERVER_NAME", "FinanceCorp-v2")


def get_database_stats():
    connection_settings = {
        "host": os.environ["DB_HOST"],
        "port": int(os.getenv("DB_PORT", "5432")),
        "dbname": os.getenv("DB_NAME", "financecorp"),
        "user": os.environ["DB_USER"],
        "password": os.environ["DB_PASSWORD"],
        "connect_timeout": 5,
        "sslmode": "require",
    }

    with psycopg.connect(**connection_settings) as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) FROM employees")
            employees = cursor.fetchone()[0]

            cursor.execute("SELECT COUNT(*) FROM accounts")
            accounts = cursor.fetchone()[0]

            cursor.execute("SELECT COUNT(*) FROM transactions")
            transactions = cursor.fetchone()[0]

            cursor.execute(
                "SELECT COALESCE(SUM(balance), 0) FROM accounts"
            )
            total_balance = cursor.fetchone()[0]

    return {
        "employees": employees,
        "accounts": accounts,
        "transactions": transactions,
        "total_balance": float(total_balance),
    }


@app.route("/")
def home():
    return f"""
    <html>
    <head>
      <title>FinanceCorp v2</title>
      <style>
        body {{
          background: #0f172a;
          color: #e2e8f0;
          font-family: Arial, sans-serif;
          text-align: center;
          padding: 80px 20px;
        }}
        h1 {{ color: #38bdf8; }}
        .card {{
          background: #1e293b;
          padding: 30px;
          border-radius: 14px;
          max-width: 550px;
          margin: auto;
        }}
      </style>
    </head>
    <body>
      <div class="card">
        <h1>FinanceCorp v2</h1>
        <h2>Powered by AWS + Terraform</h2>
        <p>Application Server: {SERVER_NAME}</p>
        <p>Three-Tier Cloud Architecture</p>
        <p>Application is running successfully.</p>
      </div>
    </body>
    </html>
    """


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "server": SERVER_NAME
    })


@app.route("/api/summary")
def summary():
    try:
        stats = get_database_stats()
        return jsonify({
            "server": SERVER_NAME,
            "database": "connected",
            "data": stats
        })
    except Exception:
        app.logger.exception("Database summary request failed")
        return jsonify({
            "server": SERVER_NAME,
            "database": "unavailable",
            "error": "Database query failed"
        }), 503


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
