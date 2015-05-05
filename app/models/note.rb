class Note < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :user
  belongs_to :position
  validates :user, :uniqueness => {:scope => :position}
  has_many :note_references, dependent: :delete_all
  has_many :referred_positions, :through => :note_references, :source => :position
  has_many :comments, dependent: :delete_all
  paginates_per 50
  has_many :activities, as: :trackable, class_name: 'PublicActivity::Activity', dependent: :destroy

  def to_public
    if self.public
      "公開"
    else
      "非公開"
    end
  end

  def update_references
    board = self.position.to_board
    sfens = []
    if self.public
      lines = self.content.split("\n")
      lines.each do |line|
        # Find [[sfen-or-CSAmoves|text]]
        line = line.gsub(/\[{2}(.+?)\|(.+?)\]{2}/) {
          match1 = $1
          match2 = $2
          sfen = nil
          if (match1 =~ /^([\+\-]\d{4}[A-Z]{2})+$/)
            if (referred_board = board.do_moves_str(match1))
              sfen = referred_board.to_sfen 
            end
          elsif (match1 =~ /\A([\+1-9krbgsnlp]+\/){8}[\+1-9krbgsnlp]+\s[bw]\s[0-9rbgsnlp\-]+\z/i)
            sfen = match1
          end
          sfens << sfen if sfen
          ""
        }
      end
    end
    position_ids = []
    sfens.each do |sfen|
      if (position = Position.find_or_create(sfen))
        position_ids << position.id
      end
    end
    positions = sfens.length > 0 ? Position.where(id: position_ids) : []
    self.referred_positions.replace(positions)
  end

  def to_create_tweet
    self.user.username + 'さんが公開マイノート「' + self.title + '」を作成しました。' + (self.position.strategy ? ('(' + self.position.strategy.name + ')') : '') + ' http://kyokumen.jp/notes/' + self.id.to_s
  end
end
