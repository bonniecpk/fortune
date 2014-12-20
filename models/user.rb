module Fortune
  class User
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: "users"

    field :email,      type: String
    field :given_name, type: String
    field :surname,    type: String
    field :avatar,     type: String
    field :lang,       type: String
    field :locale,     type: String

    validates_uniqueness_of :email
  end
end
