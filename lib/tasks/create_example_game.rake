namespace :pynt do
  desc "Creates an example game using rooms defined in doc/examples/rooms"
  task create_example_game: :environment do
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
    end
  end
end