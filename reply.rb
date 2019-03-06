require_relative 'questions_database.rb'

class Reply
    attr_accessor :id, :body, :question_id, :parent_id, :user_id

    def self.all
        data = QuestionsDatabase.instance.execute("SELECT * FROM replies") 
        data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id) 
            SELECT
                *
            FROM
                replies
            WHERE
                id = ?
        SQL
        
        Reply.new(data.first)
    end

    def self.find_by_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                replies
            WHERE
                user_id = ?
        SQL

        raise "User #{user_id} hasn't replied to anything yet" if data.empty?
        
        data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                replies
            WHERE
                question_id = ?
        SQL
        
        raise "Question #{question_id} hasn't been answered yet" if data.empty?
        
        data.map { |datum| Reply.new(datum) }
    end
    
    def initialize(options)
        @id = options['id']
        @body = options['body']
        @question_id = options['question_id']
        @parent_id = options['parent_id']
        @user_id = options['user_id']
    end

    def author
        User.find_by_id(@user_id)
    end

    def question
        Question.find_by_id(@question_id)
    end

    def parent_reply
        @parent_id.nil? ? nil : Reply.find_by_id(@parent_id) 
    end

    def child_replies
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                replies
            WHERE 
                replies.parent_id = ? 
        SQL

        data.map { |datum| Reply.new(datum) }
    end

    def save
        if @id.nil?
            QuestionsDatabase.instance.execute(<<-SQL, @body, @question_id, @parent_id, @user_id)
                INSERT INTO
                    replies(body, question_id, parent_id, user_id)
                VALUES
                    (?, ?, ?, ?)
            SQL
            @id = QuestionsDatabase.instance.last_insert_row_id
        else
            QuestionsDatabase.instance.execute(<<-SQL, @body, @question_id, @parent_id, @user_id, @id)
                UPDATE
                    replies
                SET
                    body = ?, question_id = ?, parent_id = ?, user_id = ?
                WHERE
                    id = ?
            SQL
        end
    end
    
end