class Headline < ActiveRecord::Base
  belongs_to :position

  def self.update(key, position_id)
    if (headline = Headline.find_by(name: key))
      headline.update_attributes(position_id: position_id)
    else
      Headline.create(name: key, position_id: position_id)
    end
  end
  
  def self.get_position(key)
    if (headline = Headline.find_by(name: key))
      headline.position
    else
      nil
    end
  end
end
