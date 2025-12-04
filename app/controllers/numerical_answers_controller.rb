class NumericalAnswersController < ApplicationController
  def index
    total_counts = Answer.total_calls
    agree_counts = Answer.total_responses(Answer::RESPONSE_AGREE)
    disagree_counts = Answer.total_responses(Answer::RESPONSE_DISAGREE)
    counts = AnswerCounts.new(total_counts, agree_counts, disagree_counts)
    @questions = Question.numerical
    @counts_hash = counts.to_hash
    @sorted_array = counts.to_array
    respond_to do |format|
      format.html
      format.csv { send_data counts.to_csv }
    end
  end

  def export
    data_table = []
    header_row = ["Call ID", "Location"]

    numerical_questions = Question.numerical.order(:id).to_a
    numerical_questions.each do |question|
      header_row << question.question_text
    end

    voice_questions = Question.where(feedback_type: "voice_file").to_a
    voice_questions.each do |question|
      header_row << question.question_text
    end

    data_table << header_row

    # Eager load location and answers to prevent N+1 queries
    calls = Call.where.not(location_id: nil)
                .includes(:location, answers: :question)
                .order(:id)

    calls.each do |call|
      call_array = [call.id, call.location.name]

      # Build hash of answers by question_id for O(1) lookup
      answers_by_question = call.answers.index_by(&:question_id)

      numerical_questions.each do |question|
        answer = answers_by_question[question.id]
        if answer
          call_array << case answer.numerical_response
                        when Answer::RESPONSE_AGREE then "Agree"
                        when Answer::RESPONSE_DISAGREE then "Disagree"
                        else ""
                        end
        else
          call_array << ""
        end
      end

      voice_questions.each do |question|
        answer = answers_by_question[question.id]
        call_array << (answer ? answer.voice_file_url : "")
      end

      data_table << call_array
    end

    respond_to do |format|
      format.csv do
        csv_string = CSV.generate do |csv|
          data_table.each do |row|
            csv << row
          end
        end
        send_data csv_string
      end
    end
  end
end
