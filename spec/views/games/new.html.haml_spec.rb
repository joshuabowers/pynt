require 'spec_helper'

describe "games/new" do
  before(:each) do
    assign(:game, stub_model(Game,
      :title => "MyString",
      :description => "MyString",
      :genre => "MyString"
    ).as_new_record)
  end

  it "renders new game form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => games_path, :method => "post" do
      assert_select "input#game_title", :name => "game[title]"
      assert_select "input#game_description", :name => "game[description]"
      assert_select "input#game_genre", :name => "game[genre]"
    end
  end
end
