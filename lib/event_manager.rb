require 'csv'
require 'google/apis/civicinfo_v2'
puts 'Event Manager Initialized!'

# contents = File.readlines('event_attendees.csv') if File.exist?('event_attendees.csv')

# contents.each_with_index do |line,index|
#   next if index == 0
#   puts line.split(",")[2]
# end
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
# def clean_zipcode(zipcode)
#   if zipcode.nil?
#     zipcode = "00000"
#   elsif zipcode.size < 5
#     zipcode = zipcode.rjust(5, '0')
#   elsif zipcode.size > 5
#     zipcode = zipcode[0..4]
#   else
#     zipcode
#   end
# end

def clean_zipcode(zipcode)
  zipcode.to_s[0..4].rjust(5, '0')
end

contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  begin
  legislators = civic_info.representative_info_by_address(
    address: zipcode,
    levels: 'country',
    roles: ['legislatorUpperBody', 'legislatorLowerBody']
  )

  legislators = legislators.officials
  legislator_names = legislators.map {|legislator| legislator.name}
rescue
  'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

  puts "#{name} #{zipcode} #{legislator_names}"
end
