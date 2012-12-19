namespace :pynt do
  desc "Creates an example game using rooms defined in doc/examples/rooms"
  task create_example_game: :environment do
    types = [Construct, Widget, Description, Branch, Conditional, Effect, Entry, Plain, Triggered]
    Game.create(
      title: "PYST", 
      description: "A rather shoddy Myst spoof. Which, uh, has almost nothing at all to do with Myst. Except the name.",
      genre: "Science Fiction",
      author: User.first
    ).tap do |game|
      Dir["doc/examples/rooms/*.yml"].each do |file|
        yaml = File.read(file)
        game.rooms.create(yaml: yaml)
      end
      game.update_attributes!(starting_room: game.rooms.third)
    end
  end
end