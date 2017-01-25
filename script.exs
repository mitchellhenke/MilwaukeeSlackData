months = %{
  "Dec" => "12",
  "Nov" => "11",
  "Oct" => "10",
  "Sep" => "09",
  "Aug" => "08",
  "Jul" => "07",
  "Jun" => "06",
  "May" => "05",
  "Apr" => "04",
  "Mar" => "03",
  "Feb" => "02",
  "Jan" => "01",
  "December" => "12",
  "November" => "11",
  "October" => "10",
  "September" => "09",
  "August" => "08",
  "July" => "07",
  "June" => "06",
  "May" => "05",
  "April" => "04",
  "March" => "03",
  "February" => "02",
  "January" => "01"
}

get_messages_post_private_channels = fn(x) ->
  [_, public_chans, private_chans] = Regex.run(~r/Of those, (\d{1,2})% were in (?:public )?channels(?: and|,)? (\d{1,2})% were/, x)
  public_chans_percent = String.to_integer(public_chans) |> Kernel./(100)
  private_chans_percent = String.to_integer(private_chans) |> Kernel./(100)

  [_, direct_msg] = Regex.run(~r/(\d{1,2})% were direct/, x)
  direct_msg_percent = String.to_integer(direct_msg) |> Kernel./(100)

  [public_chans_percent, private_chans_percent, direct_msg_percent]
end

get_messages_pre_private_channels = fn(x) ->
  [_, public_chans, private_chans] = Regex.run(~r/Of those, (\d{1,2})% were in (?:public )?channels(?: and|,)? (\d{1,2})% were/, x)
  public_chans_percent = String.to_integer(public_chans) |> Kernel./(100)
  direct_msg_percent = String.to_integer(private_chans) |> Kernel./(100)

  [public_chans_percent, 0.0, direct_msg_percent]
end

# open mbox, and split on each "From " line and remove any empty lines
emails = File.read!("MilwaukeeSlackData.mbox")
         |> String.split(~r/From \d+/)
         |> Enum.reject(&(&1 == ""))

# open new csv file
file = File.open!("data.csv", [:write])
# write csv header
IO.binwrite(file, "date,total,public,private,direct,users,files\n")
# for each email, get date and relevant stats, and write to the csv file
Enum.each(emails, fn(x) ->
  [_, _day, month, year] = Regex.run(~r/Date:.* (\d{1,2}) (\w{3}) (\d{4})/, x)
  [_, _, _, month2, day2] = Regex.run(~r/\w+, (\w+) (\d+)\w+ - \w+, (\w+) (\d+)\w+/, x)

  year = if(month == "Jan" && month2 == "December") do
    Integer.to_string((String.to_integer(year) - 1))
  else
    year
  end

  date = "#{year}-#{Map.fetch!(months, month2)}-#{String.pad_leading(day2, 2, "0")}"

  [_, total] = Regex.run(~r/Your team sent a total of (\d{0,2},{0,1}\d{3}) messages last week/, x)
  total = String.replace(total, ",", "") |> String.to_integer

  [public, private, direct] = if(String.contains?(x, "private") || String.contains?(x, "group")) do
    get_messages_post_private_channels.(x)
  else
    get_messages_pre_private_channels.(x)
  end
  [_, files] = Regex.run(~r/(\d{1,3}) files/, x)
  files = String.to_integer(files)
  [_, users]  = Regex.run(~r/there are (\d+) people/, x)


  data = ["#{date}", total, public, private, direct, users, files]

  data = Enum.join(data, ",") <> "\n"
  IO.binwrite(file, data)
end)
File.close(file)
