namespace :pynt do
  desc "Updates example rooms from whatever is in the database."
  task update_examples: :environment do
    game = Game.first
    game.rooms.each do |room|
      File.write("doc/#{room.parameterized_name}.yml", room.yaml)
    end
  end
end