#!/usr/bin/env python

from flask import Flask, render_template, make_response, redirect
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# TODO: migrate to python-decouple
# connection uri
db_host = 'localhost'
db_port = '5432'
db_name = 'visitors'
db_user = 'postgres'
db_pass = 'postgres'
conn_uri = f"postgresql://{db_name}:{db_pass}@{db_host}:{db_port}/{db_name}"

# app configuration
app.config['SQLALCHEMY_DATABASE_URI'] = conn_uri
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# database instance
db = SQLAlchemy(app)


class Visitor(db.Model):
    """Visitor DB model."""
    id = db.Column(db.Integer, primary_key=True)
    count = db.Column(db.Integer, nullable=False)


# create the database
with app.app_context():
    db.create_all()


@app.route('/')
def home():
    visitor = Visitor.query.first()
    if not visitor:
        visitor = Visitor(count=1)
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
