
class QuestionFollow
    attr_accessor :id, :user_id, :question_id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows") 
        data.map { |datum| QuestionFollow.new(datum) }
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id) 
            SELECT
                *
            FROM
                question_follows
            WHERE
                id = ?
        SQL
        
        QuestionFollow.new(data.first)
    end

    def self.followers_for_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT  
                *
            FROM
                users
            JOIN 
                questions ON users.id = questions.author_id
            JOIN
                question_follows ON questions.id = question_follows.question_id
            WHERE 
                question_follows.question_id = ? 
        SQL

        # data.empty? ? nil : 
        data.map { |datum| User.new(datum) }
    end

    def self.followed_questions_for_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                questions
            JOIN 
                users on questions.author_id = users.id
            JOIN
                question_follows ON users.id = question_follows.user_id
            WHERE
                question_follows.user_id = ?
        SQL

        # data.empty? ? nil : 
        data.map { |datum| QuestionFollow.new(datum) }
    end

    def self.most_followed_questions(n)
        data = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT 
                *
            FROM    
                questions
            JOIN
                question_follows ON questions.id = question_follows.question_id
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
        @user_id = options['user_id']
        @question_id = options['question_id']
    end
    
end