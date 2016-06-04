require 'twilio-ruby'

# free test auth
#account_sid = "AC24bd9521e73195d4c0cb1071302048c3" 
#auth_token = "68537864cf242067bf8fdf52f2fe9978"

# live paid auth
account_sid = "ACd6d6a314312ca8be844902aff86ff066" 
auth_token = "217ac0433bc7730c43467c3ed033d5ce"

client = Twilio::REST::Client.new account_sid, auth_token

#from = "+15005550006" # Your TEST Twilio number
from = "+18448005227 " # Your LIVE Twilio number
 
friends = {
"+14153334444" => "Curious George",
"+14155557775" => "Boots",
"+14155551234" => "Virgil"
}
friends.each do |key, value|
  client.account.messages.create(
    :from => from,
    :to => key,
    :body => "Hey #{value}, Monkey party at 6PM. Bring Bananas!"
  )
  puts "Sent message to #{value}"
end