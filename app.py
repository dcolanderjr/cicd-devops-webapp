from flask import Flask, render_template, request, redirect, url_for, flash, session
from flask_wtf import FlaskForm
from wtforms import StringField, RadioField, SubmitField, SelectField
from wtforms.validators import DataRequired
import requests
import secrets

app = Flask(__name__)
app.config['SECRET_KEY'] = secrets.token_hex(32)

class QuizForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    answers = []

def get_questions():
    response = requests.get('https://opentdb.com/api.php?amount=3&type=multiple')
    data = response.json()
    questions = []
    for item in data['results']:
        question = {
            'question': item['question'],
            'choices': [(item['correct_answer'], True)] + [(choice, False) for choice in item['incorrect_answers']]
        }
        questions.append(question)
    return questions

@app.route('/', methods=['GET', 'POST'])
def index():
    form = QuizForm()
    session.clear()  # Clear any existing session data
    session['questions'] = get_questions()  # Store questions in session
    if form.validate_on_submit():
        # Store answers
        for i, question in enumerate(session['questions']):
            selected_answer = request.form.get(f'question_{i}')
            form.answers.append(selected_answer)

        # Redirect to the results page
        return redirect(url_for('results'))
    return render_template('index.html', form=form, questions=session['questions'])

@app.route('/results')
def results():
    form = QuizForm()
    score = 0
    total_questions = len(session['questions'])
    for i, question in enumerate(session['questions']):
        selected_answer = form.answers[i]
        if selected_answer == question['choices'][0][0]:
            score += 1
    return render_template('results.html', score=score, total_questions=total_questions)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')


