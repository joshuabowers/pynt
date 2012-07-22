require 'spec_helper'

describe "games/edit" do
  before(:each) do
    @game = assign(:game, stub_model(Game,
      :title => "MyString",
      :description => "MyString",
      :genre => "MyString"
    ))
  end

  it "renders the edit game form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => games_path(@game), :method => "post" do
      assert_select "input#game_title", :name => "game[title]"
      assert_select "input#game_description", :name => "game[description]"
      assert_select "input#game_genre", :name => "game[genre]"
    end
  end
end
