module Events
  class Event < ApplicationRecord
    self.table_name = "events"

    validates :billetto_id, :title, presence: true
    validates :billetto_id, uniqueness: true

    scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
    scope :listed,   -> { order(starts_at: :asc).limit(50) }
  end
end