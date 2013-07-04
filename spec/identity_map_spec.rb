describe "Identity Map" do
  before do
    @json1 = {
      "post" => {
        "id" => 1,
        "title" => "Old Title",
        "body" => "Old Body"
      }
    }
    @post1 = Post.merge_or_insert @json1

    @json2 = {
      "post" => {
        "id" => 1,
        "title" => "New Title",
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
    @post2 = Post.merge_or_insert @json2
    @comments2 = @post2.comments
  end

  describe "merging" do
    it "should have correct values in identity map" do
      Post.identity_map.count.should == 1
      Comment.identity_map.count.should == 2
    end

    it "should merge in new value" do
      @post1.title.should == @json2['post']['title']
    end

    it "should not merge in nil value" do
      @post1.body.should == @json1['post']['body']
    end

    it "should replace relationships" do
      @post1.comments.should == @comments2
    end
  end
end
