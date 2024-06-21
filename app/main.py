#!/usr/bin/env python

from decouple import config
from flask import Flask, render_template, make_response, redirect
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# connection uri
db_host = config("DB_URL", default="localhost")
db_name = config("DB_NAME", default="postgres")
db_user = config("DB_USER", default="postgres")
db_pass = config("DB_PASS", default="postgres")
db_port = config("DB_PORT", default=5432, cast=int)
conn_uri = f"postgresql://{db_user}:{db_pass}@{db_host}:{db_port}/{db_name}"

# app configuration
app.config['SQLALCHEMY_DATABASE_URI'] = conn_uri
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# database instance
db = SQLAlchemy(app)


class Visitors(db.Model):
    """Visitors DB model."""
    id = db.Column(db.Integer, primary_key=True)
    count = db.Column(db.Integer, nullable=False)


# create the database
with app.app_context():
    db.create_all()


# TODO: less naive visitor counting (user agent, IP, etc.)
@app.route('/')
def home():
    visitor = Visitors.query.first()
    if not visitor:
        visitor = Visitors(count=1)
        db.session.add(visitor)
    else:
        visitor.count += 1
    db.session.commit()
    return render_template('index.html', visitor_count=visitor.count)


@app.route('/meetup')
def meetup():
    return redirect('/teatime', code=301)


@app.route('/teatime')
def teatime():
    response = make_response(render_template('teapot.html'))
    response.status_code = 418
    return response


if __name__ == '__main__':
    app.run(debug=True)
