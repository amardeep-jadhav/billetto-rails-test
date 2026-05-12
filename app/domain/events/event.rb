module Events
  class Event < ApplicationRecord
    self.table_name = "events"

    validates :billetto_id, :title, presence: true
    validates :billetto_id, uniqueness: true

    scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  end
end