Projectile
==========

JSON model layer for RubyMotion applications. Inspired by [Mantle](https://github.com/github/Mantle).

# Example

Using the classic blog example, where we have posts and comments, here's how you could define your subclasses:

    class Post < Model
      set_attribute name: :id,
        type: :integer,
        key_path: "post.id"

      set_attribute name: :title,
        type: :string,
        default: "",
        key_path: "post.title"

      set_attribute name: :body,
       type: :string,
       default: "",
       key_path: "post.body"

      set_attribute name: :created_at,
        type: :date,
        key_path: "post.created_at"

      set_relationship name: :comments,
        class_name: :Comment,
        default: [],
        key_path: "post.comments"
    end

    class Comment < Model
      set_attribute name: :id,
        type: :integer,
        key_path: "comment.id"

      set_attribute name: :text,
        type: :string,
        default: "",
        key_path: "comment.text"
    end

A `Post` has attributes `id`, `title`, `body`, `created_at`, and a to-many relationship to `Comment`.
A `Comment` has attributes `id` and `text`.

Default values are set during object initialization. i.e, `Model#new`.

Key paths define where the values are located in a JSON `Hash`. This is so we know where the value exists during `#new`, and also helps us recreate the `Hash` in `#to_hash`.

# Types

- `integer`
- `float`
- `boolean`
- `date`, only supports `yyyy-MM-dd'T'HH:mm:ssZZZZZ` right now.
- `url`, just turns the string into a `NSURL`
- `string`

# Identity Map

To use an identity map, put these lines at the top of a class definition:

    include IdentityMap
    establish_identity_on :id

What this means:

1. Defines equivalence based on the `id` attribute
2. Holds all instances of class, keyed by `id`, in a class instance variable `@@identity_map`.

Use `#merge_or_insert` instead of `#new` from now on:

    # this will either create a brand new post object, or merge with an existing one.
    json = {
      "post" => {
        "id" => 1,
        "title" => "Hehehoho",
        "body" => "La Li Lu Le Lo",
        "created_at" => "2013-08-02T16:44:34-08:00"
      }
    }
    @post = Post.merge_or_insert json

You can use `Post[1]` to fetch the above object from anywhere. Kind of useful in the REPL.

# Misc

I'm very open to ideas, please create issues, fork, whatever. Oh yeah, MIT.




