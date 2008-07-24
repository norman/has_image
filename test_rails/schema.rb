ActiveRecord::Schema.define(:version => 1) do

  create_table "pics", :force => true do |t|
    t.string  :has_image_file
    t.datetime :created_at
    t.datetime :updated_at
  end

end
