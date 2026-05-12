class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string   :billetto_id,  null: false
      t.string   :title,        null: false
      t.text     :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.string   :image_url
      t.string   :billetto_url

      t.timestamps
    end

    add_index :events, :billetto_id, unique: true
    add_index :events, :starts_at
  end
end