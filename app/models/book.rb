class Book < ActiveRecord::Base
require 'asin'
require 'date'

  def self.load_info(record)
    if (book = Book.find_by(isbn13: record[:isbn13]))
      record[:title] = book.title
      record[:author] = book.author
      record[:publisher] = book.publisher
      record[:date] = book.publication_date.to_s
    else
      client = ASIN::Client.instance
      begin
        items = client.lookup ISBN.isbn13_to_asin(record[:isbn13])
      rescue
        record[:title] = "(通信障害)"
      end
      if (items && items.first && items.first.item_attributes && items.first.item_attributes.product_group =~ /Book/)
        record[:title] = items.first.item_attributes.title
        record[:author] = items.first.item_attributes.author || "-"
        record[:publisher] = items.first.item_attributes.publisher || "-"
        record[:date] = items.first.item_attributes.publication_date
        date_elements = record[:date].split("-")
        if (date_elements.length == 1)
          date = Date::new(date_elements[0].to_i, 1, 1)
        elsif (date_elements.length == 2)
          date = Date::new(date_elements[0].to_i, date_elements[1].to_i, 1)
        else
          date = record[:date]
        end
        Book.create(isbn13: record[:isbn13], title: record[:title], author: record[:author], publisher: record[:publisher], publication_date: date)
      else
        record[:title] = "<span class='dark_red'><i>エラー</i></span>" unless record[:title]
        record[:author] = "-"
        record[:publisher] = "-"
        record[:date] = " - "
      end
    end
  end
end
