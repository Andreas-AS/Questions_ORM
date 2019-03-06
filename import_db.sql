PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;


CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    author_id INTEGER NOT NULL,

    FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    body TEXT NOT NULL,
    question_id INTEGER NOT NULL,
    parent_id INTEGER,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (parent_id) REFERENCES replies(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL, 

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);


INSERT INTO 
    users(fname, lname)
VALUES
    ("John", "Smith"),
    ("Jane", "Doe"),
    ("Bob", "Jones"),
    ("Becky", "Oneill");


INSERT INTO
    questions(title, body, author_id)
VALUES 
    ("First Question", "What is going on?", 2),
    ("Second Question", "How do it know?", 3),
    ("Riddle me this", "What's Bobby Tables all about?", (SELECT id from users WHERE fname = "John")),
    ("Sally", "Did Sally drop out?", 4);


INSERT INTO
    question_follows(user_id, question_id)
VALUES
    (2, 3),
    (1, 2),
    (2, 4),
    (2, 1);


INSERT INTO
    replies(body, question_id, parent_id, user_id)
VALUES
    ("Magic", 2, NULL, 1),
    ("It's from a comic", 3, NULL, 4),
    ("From XKCD", 3, 2, 2);


INSERT INTO 
    question_likes(question_id, user_id)
VALUES
    (3, 2),
    (3, 4),
    (2, 1),
    (1, 1),
    (1, 4);