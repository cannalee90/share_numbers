require 'json'
file = File.open(Rails.root.join('db','members.json'))
contents = file.read
json = ActiveSupport::JSON.decode(contents)["user_list"]
json.each do |j|
  User.create(:email => j["email"], :mobile => j["mobile"], :name => j["name"], :password => j["password"],  :role => j["role"], :school => j["school"], :team => j["team"])
end

