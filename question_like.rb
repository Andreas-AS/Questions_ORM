require_relative 'questions_database.rb'

class QuestionLike
    attr_accessor :id, :question_id, :user_id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes") 
        data.map { |datum| QuestionLike.new(datum) }
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id) 
            SELECT
                *
            FROM
                question_likes
            WHERE
                id = ?
        SQL
        
        QuestionLike.new(data.first)
    end

    def self.likers_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM 
                users
            JOIN 
                questions ON users.id = questions.author_id
            JOIN 
                question_likes ON questions.id = question_likes.question_id
            WHERE question_id = ? 
        SQL

        data.map { |datum| User.new(datum) }
    end

    def self.num_likes_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                COUNT(*)
            FROM 
                users
            JOIN 
                questions ON users.id = questions.author_id
            JOIN 
                question_likes ON questions.id = question_likes.question_id
            WHERE question_id = ? 
        SQL

        data.first["COUNT(*)"]
    end

    def self.liked_questions_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                questions
            JOIN 
                question_likes ON questions.id = question_likes.question_id
            JOIN
                users ON question_likes.user_id = users.id
            WHERE
                question_likes.user_id = ?
        SQL

        data.map { |datum| Question.new(datum) }
    end

    def self.most_liked_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT
                *
            FROM 
                questions
            JOIN
                question_likes ON questions.id = question_likes.question_id
            GROUP BY
                question_id
            ORDER BY
                COUNT(*) DESC
            LIMIT ?
        SQL

        data.map { |datum| Question.new(datum) }
    end
    
    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
    
end