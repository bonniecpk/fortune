module Fortune
  class Notification
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: "notifications"

    field :percent,   type: Float

    embedded_in :investment
  end
end
