# == Schema Information
#
# Table name: answers
#
#  id                 :integer          not null, primary key
#  question_id        :integer
#  voice_file_url     :string(255)
#  numerical_response :integer
#  created_at         :datetime
#  updated_at         :datetime
#  call_id            :integer
#

class Answer < ActiveRecord::Base
  # Numerical response constants
  RESPONSE_AGREE = 1
  RESPONSE_DISAGREE = 2
  VALID_RESPONSES = [RESPONSE_AGREE, RESPONSE_DISAGREE].freeze

  belongs_to :call
  belongs_to :question

  has_one :caller, through: :call
  has_one :location, through: :call

  has_many :location_subscriptions, through: :location

  validates :call, presence: true
  validates :question, presence: true

  validates :numerical_response, presence: true, inclusion: VALID_RESPONSES, if: 'question.try(:numerical_response?)'
  validates :voice_file_url, presence: true, if: 'question.try(:voice_file?)'

  def self.total_calls
    calls = where.not(numerical_response: nil).joins(:location).group(:location_id).count(:numerical_response)
    return {} if calls.empty?

    locations = Location.where(id: calls.keys).index_by(&:id)
    calls.transform_keys { |location_id| locations[location_id] }.compact
  end

  def self.total_responses(numerical_response)
    calls = where(numerical_response: numerical_response).joins(:location).group(:location_id).count(:numerical_response)
    return {} if calls.empty?

    locations = Location.where(id: calls.keys).index_by(&:id)
    calls.transform_keys { |location_id| locations[location_id] }.compact
  end

  def self.voice_messages
    where.not(voice_file_url: nil).order(created_at: :desc)
  end

  def obscured_phone_number
    return 'N/A' unless caller&.phone_number

    phone = caller.phone_number.to_s.gsub(/\D/, '') # Remove non-digits

    case phone.length
    when 10..11
      # US phone format: (XXX) XXX-XXXX
      last_digits = phone[-4..-1]
      "XXX-XXX-#{last_digits}"
    when 7..9
      last_digits = phone[-2..-1]
      "XXX-XX#{last_digits}"
    else
      'XXX-XXXX' # Fallback for unusual formats
    end
  end
end
