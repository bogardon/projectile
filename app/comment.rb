class Comment < Model
  include IdentityMap
  establish_identity_on :id

  set_attribute name: :id,
    type: :integer,
    default: -1,
    key_path: "comment.id"

  set_attribute name: :text,
    type: :string,
    default: "",
    key_path: "comment.text"
end
