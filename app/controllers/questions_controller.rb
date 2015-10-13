class QuestionsController < ApplicationController

  before_action :check_if_question_owner, only: [:show, :destroy, :edit, :update]
  before_action :check_if_event_owner, only: [:new]

  def new
    @event = find_event
    @question = Question.new
    2.times { @question.choices.build }
  end

  def show
    @question = find_question
  end

  def create
    @event = find_event
    @question = @event.questions.new(question_params)

    if @question.save
      flash[:notice] = "Question successfully created"
      redirect_to question_path(@question.id)
    else
      render 'questions/new'
    end
  end

  def destroy
    question = find_question.destroy
    redirect_to event_path(question.event)
    flash[:notice] = "Question successfully deleted"
  end

  def clear_votes
    question = find_question
    question.choices.map{ |choice| choice.votes.destroy_all }
    redirect_to question_path(question)
    flash[:notice] = "Votes successfully cleared"
  end

  def publish_question
    question = Question.find(params["question"])
    event = question.event
    json_object = BuildJSON.call(event, question)
    begin
      push_json_to_pusher(json_object, event.id)
      redirect_to question_path(question)
      flash[:notice] = "Question has been pushed to the audience"
    rescue
      redirect_to event_path(event)
      flash[:notice] = "Error: Question could not be published"
    end
  end

  def push_json_to_pusher(json_object, event_id)
    pusher = Pusher::Client.new app_id: Pusher.app_id, key: Pusher.key, secret: Pusher.secret
    pusher.trigger('test_channel', 'event_' + event_id.to_s, json_object)
  end

  def add_choice
    @question = find_question
    respond_to do |format|
      format.js
    end
  end

  private

  def find_question
    Question.find(params[:id])
  end

  def find_event
    Event.find(params[:event_id])
  end

  def check_if_question_owner
    question = find_question
    if current_user != question.event.user
      redirect_to root_path, notice: "Sorry, but we were unable to serve your request."
    end
  end

  def check_if_event_owner
    event = Event.find(params[:event_id])
    if current_user != event.user
      redirect_to root_path, notice: "Sorry, but we were unable to serve your request."
    end
  end

  def question_number(event, question)
    questions_array = event.questions.all.order(:id)
    question_number = questions_array.index(question).to_i + 1
  end

  def question_params
    params.require(:question).permit(:content, choices_attributes:[:content])
  end
  
end
