import os
from datetime import date

import pymysql
from dotenv import load_dotenv
from flask import Flask, flash, g, redirect, render_template, request, url_for

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "dev-secret-change-me")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BLOOD_GROUPS = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]


# ---------------- Database helpers ----------------
def db():
    """Open one MySQL connection per HTTP request."""
    if "db" not in g:
        use_ssl = os.getenv("DB_SSL", "false").lower() == "true"
        ssl_config = None
        if use_ssl:
            ca_path = os.path.join(BASE_DIR, "ca.pem")
            ssl_config = {"ca": ca_path} if os.path.exists(ca_path) else {"ssl_mode": "REQUIRED"}
        g.db = pymysql.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=int(os.getenv("DB_PORT", "3306")),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD", ""),
            database=os.getenv("DB_NAME", "blood_network"),
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            ssl=ssl_config,
        )
    return g.db


@app.teardown_appcontext
def close_db(exc):
    conn = g.pop("db", None)
    if conn is not None:
        conn.close()


def query(sql, params=None, one=False):
    with db().cursor() as cur:
        cur.execute(sql, params)
        rows = cur.fetchall()
    if one:
        return rows[0] if rows else None
    return rows


def execute(sql, params=None):
    """Run INSERT/UPDATE/DELETE. Returns an error message, or None if it worked."""
    try:
        with db().cursor() as cur:
            cur.execute(sql, params)
        return None
    except pymysql.MySQLError as e:
        return e.args[1] if len(e.args) > 1 else str(e)


def notify(err, success_msg):
    flash(err or success_msg, "error" if err else "success")


@app.context_processor
def template_globals():
    return {
        "BLOOD_GROUPS": BLOOD_GROUPS,
        "URGENCY_BADGE": {"Critical": "danger", "High": "warn", "Medium": "info", "Low": "muted"},
        "STATUS_BADGE": {"Open": "warn", "Fulfilled": "ok", "Cancelled": "muted"},
    }


# ---------------- Dashboard ----------------
@app.route("/")
def dashboard():
    def count(sql):
        return query(sql, one=True)["c"]

    stats = {
        "donors": count("SELECT COUNT(*) AS c FROM donors"),
        "eligible": count("SELECT COUNT(*) AS c FROM eligible_donors"),
        "open_requests": count("SELECT COUNT(*) AS c FROM requests WHERE status = 'Open'"),
        "units_month": count("""SELECT COALESCE(SUM(units), 0) AS c FROM donations
                                WHERE YEAR(donation_date) = YEAR(CURDATE())
                                  AND MONTH(donation_date) = MONTH(CURDATE())"""),
    }

    total = {r["blood_group"]: r["c"] for r in query(
        "SELECT blood_group, COUNT(*) AS c FROM donors GROUP BY blood_group")}
    eligible = {r["blood_group"]: r["c"] for r in query(
        "SELECT blood_group, COUNT(*) AS c FROM eligible_donors GROUP BY blood_group")}
    chart = {
        "labels": BLOOD_GROUPS,
        "total": [total.get(bg, 0) for bg in BLOOD_GROUPS],
        "eligible": [eligible.get(bg, 0) for bg in BLOOD_GROUPS],
    }

    urgent = query("""SELECT * FROM requests WHERE status = 'Open'
                      ORDER BY FIELD(urgency, 'Critical', 'High', 'Medium', 'Low'), created_at
                      LIMIT 5""")
    recent = query("""SELECT dn.donation_date, dn.units, d.name, d.blood_group, b.name AS bank
                      FROM donations dn
                      JOIN donors d ON d.donor_id = dn.donor_id
                      JOIN blood_banks b ON b.bank_id = dn.bank_id
                      ORDER BY dn.donation_date DESC, dn.donation_id DESC
                      LIMIT 6""")
    return render_template("dashboard.html", stats=stats, chart=chart,
                           urgent=urgent, recent=recent)


# ---------------- Donors ----------------
@app.route("/donors", methods=["GET", "POST"])
def donors():
    if request.method == "POST":
        f = request.form
        err = execute("""INSERT INTO donors (name, blood_group, gender, dob, phone, email, city)
                         VALUES (%s, %s, %s, %s, %s, %s, %s)""",
                      (f["name"].strip(), f["blood_group"], f["gender"], f["dob"],
                       f["phone"].strip(), f.get("email") or None, f["city"].strip().title()))
        notify(err, "Donor registered successfully.")
        return redirect(url_for("donors"))

    sql = """SELECT d.*, TIMESTAMPDIFF(YEAR, d.dob, CURDATE()) AS age,
                    GREATEST(0, 90 - DATEDIFF(CURDATE(), d.last_donation_date)) AS days_left
             FROM donors d WHERE 1 = 1"""
    params = []
    if request.args.get("blood_group"):
        sql += " AND d.blood_group = %s"
        params.append(request.args["blood_group"])
    if request.args.get("city"):
        sql += " AND d.city LIKE %s"
        params.append(f"%{request.args['city'].strip()}%")
    if request.args.get("eligible") == "1":
        sql += " AND d.donor_id IN (SELECT donor_id FROM eligible_donors)"
    sql += " ORDER BY d.name"

    return render_template("donors.html", donors=query(sql, params), filters=request.args)


@app.post("/donors/<int:donor_id>/delete")
def delete_donor(donor_id):
    notify(execute("DELETE FROM donors WHERE donor_id = %s", (donor_id,)), "Donor removed.")
    return redirect(url_for("donors"))


# ---------------- Requests ----------------
@app.route("/requests", methods=["GET", "POST"])
def blood_requests():
    if request.method == "POST":
        f = request.form
        err = execute("""INSERT INTO requests (patient_name, blood_group, units_needed,
                                               hospital, city, urgency, contact_phone)
                         VALUES (%s, %s, %s, %s, %s, %s, %s)""",
                      (f["patient_name"].strip(), f["blood_group"], f["units_needed"],
                       f["hospital"].strip(), f["city"].strip().title(),
                       f["urgency"], f["contact_phone"].strip()))
        notify(err, "Blood request created.")
        return redirect(url_for("blood_requests"))

    rows = query("""SELECT * FROM requests
                    ORDER BY status = 'Open' DESC,
                             FIELD(urgency, 'Critical', 'High', 'Medium', 'Low'),
                             created_at DESC""")
    return render_template("requests.html", requests=rows)


@app.post("/requests/<int:rid>/cancel")
def cancel_request(rid):
    notify(execute("UPDATE requests SET status = 'Cancelled' WHERE request_id = %s", (rid,)),
           "Request cancelled.")
    return redirect(url_for("blood_requests"))


@app.route("/requests/<int:rid>/match")
def match_donors(rid):
    req = query("SELECT * FROM requests WHERE request_id = %s", (rid,), one=True)
    if not req:
        flash("Request not found.", "error")
        return redirect(url_for("blood_requests"))
    with db().cursor() as cur:
        cur.callproc("find_donors_for_request", (rid,))
        matches = cur.fetchall()
    return render_template("match.html", req=req, matches=matches)


# ---------------- Donations ----------------
@app.route("/donations", methods=["GET", "POST"])
def donations():
    if request.method == "POST":
        f = request.form
        err = execute("""INSERT INTO donations (donor_id, bank_id, request_id, donation_date, units)
                         VALUES (%s, %s, %s, %s, %s)""",
                      (f["donor_id"], f["bank_id"], f.get("request_id") or None,
                       f["donation_date"], f.get("units", 1)))
        notify(err, "Donation recorded. The donor's 90-day cooldown has started.")
        return redirect(url_for("donations"))

    rows = query("""SELECT dn.*, d.name AS donor_name, d.blood_group,
                           b.name AS bank_name, r.patient_name
                    FROM donations dn
                    JOIN donors d ON d.donor_id = dn.donor_id
                    JOIN blood_banks b ON b.bank_id = dn.bank_id
                    LEFT JOIN requests r ON r.request_id = dn.request_id
                    ORDER BY dn.donation_date DESC, dn.donation_id DESC""")
    return render_template(
        "donations.html",
        donations=rows,
        donors_list=query("SELECT donor_id, name, blood_group, city FROM donors ORDER BY name"),
        banks_list=query("SELECT bank_id, name, city FROM blood_banks ORDER BY name"),
        open_reqs=query("""SELECT request_id, patient_name, blood_group, city
                           FROM requests WHERE status = 'Open' ORDER BY created_at DESC"""),
        today=date.today().isoformat(),
        pre_donor=request.args.get("donor_id", ""),
        pre_req=request.args.get("request_id", ""),
    )


# ---------------- Blood banks ----------------
@app.route("/banks", methods=["GET", "POST"])
def banks():
    if request.method == "POST":
        f = request.form
        err = execute("INSERT INTO blood_banks (name, city, phone, address) VALUES (%s, %s, %s, %s)",
                      (f["name"].strip(), f["city"].strip().title(),
                       f.get("phone") or None, f.get("address") or None))
        notify(err, "Blood bank added.")
        return redirect(url_for("banks"))

    rows = query("""SELECT b.*, COUNT(dn.donation_id) AS total_donations,
                           COALESCE(SUM(dn.units), 0) AS total_units
                    FROM blood_banks b
                    LEFT JOIN donations dn ON dn.bank_id = b.bank_id
                    GROUP BY b.bank_id
                    ORDER BY b.name""")
    return render_template("banks.html", banks=rows)


if __name__ == "__main__":
    app.run(debug=True)
