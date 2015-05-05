class NoteReference < ActiveRecord::Base
  belongs_to :note
  belongs_to :position
end
