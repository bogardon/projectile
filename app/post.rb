class Post < Model
  include IdentityMap
  establish_identity_on :id

  set_attribute name: :id,
    type: :integer,
    default: -1,
    key_path: "post.id"

  set_attribute name: :title,
    type: :string,
    default: "",
    key_path: "post.title"

  set_attribute name: :body,
   type: :string,
   default: "",
   key_path: "post.body"

  set_relationship name: :comments,
    class_name: :Comment,
    default: [],
    key_path: "post.comments"
end
