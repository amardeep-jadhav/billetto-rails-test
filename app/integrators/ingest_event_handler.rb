class IngestEventHandler
  def call(fact)
    data = fact.data

    event = ::Events::Event.find_or_initialize_by(billetto_id: data.fetch(:billetto_id))

    event.assign_attributes(
      title:        data[:title],
      description:  data[:description],
      starts_at:    parse_time(data[:starts_at]),
      ends_at:      parse_time(data[:ends_at]),
      image_url:    data[:image_url],
      billetto_url: data[:billetto_url],
    )

    event.save!
  end

  private

  def parse_time(value)
    return nil if value.blank?
    Time.parse(value)
  rescue ArgumentError
    nil
  end
end