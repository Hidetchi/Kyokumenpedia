class ISBN
  def self.check_digit_isbn13(trunk)
    return nil unless trunk.length == 12
    tmp = 0
    for i in 0..11 do
      weight = (i % 2 == 0) ? 1 : 3
      tmp += trunk[i].to_i * weight 
    end
    tmp = tmp % 10
    if (tmp == 0)
      return "0"
    else
      return (10 - tmp).to_s
    end
  end

  def self.check_digit_asin(trunk)
    return nil unless trunk.length == 9
    tmp = 0
    for i in 0..8 do
      tmp += trunk[i].to_i * (10 - i) 
    end
    tmp = tmp % 11
    if (tmp == 0)
      return "0"
    elsif (tmp == 1)
      return "X"
    else
      return (11 - tmp).to_s
    end
  end

  def self.asin_valid?(asin)
    return false unless asin.length == 10
    asin[9] == check_digit_asin(asin[0..8])
  end

  def self.isbn13_valid?(isbn13)
    return false unless isbn13.length == 13
    return false unless isbn13[0..2] == "978"
    isbn13[12] == check_digit_esbn13(isbn13[0..11])
  end

  def self.asin_to_isbn13(asin)
    isbn13_trunk = "978" + asin[0..8]
    isbn13_trunk + check_digit_isbn13(isbn13_trunk)
  end

  def self.isbn13_to_asin(isbn13)
    asin_trunk = isbn13[3..11]
    asin_trunk + check_digit_asin(asin_trunk)
  end
end
