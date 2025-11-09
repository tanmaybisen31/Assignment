class PhoneNumber < ApplicationRecord
  has_many :calls, dependent: :destroy

  validates :number, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending calling completed failed] }

  scope :pending, -> { where(status: 'pending') }
  scope :test_numbers, -> { where(is_test_number: true) }
  scope :real_numbers, -> { where(is_test_number: false) }

  def formatted_number
    return number if number.start_with?('+')
    "#{country_code}#{number}"
  end

  def real_number?
    number.in?(['8081471151', '+918081471151', '9693764689', '+919693764689'])
  end

  def mark_called!
    update(
      last_called_at: Time.current,
      call_attempts: call_attempts + 1,
      status: 'calling'
    )
  end

  def call_stats
    {
      total_calls: calls.count,
      completed: calls.where(status: 'completed').count,
      failed: calls.where(status: ['failed', 'busy', 'no-answer']).count,
      in_progress: calls.where(status: ['queued', 'ringing', 'in-progress']).count,
      average_duration: calls.where(status: 'completed').average(:duration)&.to_f&.round(2) || 0
    }
  end
end
