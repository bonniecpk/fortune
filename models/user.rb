module Fortune
  class User
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: "users"

    field :email,      type: String
    field :firstname,  type: String
    field :lastname,   type: String
    field :avatar,     type: String
    field :lang,       type: String

    validates_uniqueness_of :email
  end
end
