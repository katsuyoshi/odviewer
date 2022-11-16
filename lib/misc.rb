def location? v
  return nil unless v.scan(/\./).size == 2
  return nil unless v.scan(/\,/).size == 1
  v.split(",").each do |e|
    return nil unless number? e.strip
  end
  true
end

def number? v
  return nil if v.nil?
  return nil if location? v
  /^[△▲+-]?\s*(\d{1,3}?(\,\d{3})*|\d+)(\.|\.(\d+))?$/ =~ v
end

def number v
  return nil unless number? v
  v.gsub(/[△▲]/, "-").gsub(/[\s\,]/, '').to_f
end
