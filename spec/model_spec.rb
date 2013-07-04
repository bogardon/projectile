describe "Model" do
  before do
    @json = {
      "post" => {
        "id" => 1,
        "title" => "Projectile",
        "body" => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "comments" => [
          {
            "comment" => {
              "id" => 1,
              "text" => "Cool story bro."
            }
          },
          {
            "comment" => {
              "id" => 2,
              "text" => "La Li Lu Le Lo"
            }
          }
        ]
      }
    }
    @post = Post.new @json
    @comments = @post.comments
    @empty_post = Post.new
  end

  describe "populating attributes" do
    it "has correct attributes" do
      @post.id.should == 1
      @post.title.should == @json['post']['title']
      @post.body.should == @json['post']['body']
    end

    it "has correct defaults" do
      @empty_post.id.should == -1
      @empty_post.title.should == ""
      @empty_post.body.should == ""
    end
  end

  describe "populating relationships" do
    it "has correct relationships" do
      @post.comments.count.should == 2
    end
  end

  describe "generating hash" do
    it "should be the same as json" do
      @post.to_hash.should == @json
    end
  end

end
