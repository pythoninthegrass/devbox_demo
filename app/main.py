#!/usr/bin/env python

from flask import Flask, render_template, make_response, redirect

app = Flask(__name__)


@app.route('/')
def home():
    return render_template('index.html')


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
