class Calls::QuestionsController < TwilioController
  before_action :load_call

  def create
    if Question.exists?
      redirect_twilio_to(call_question_answer_path(@call, 0))
    end
  end
end
