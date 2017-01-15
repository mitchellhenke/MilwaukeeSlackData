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
  "Jan" => "01"
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

emails = File.read!("MilwaukeeSlackData.mbox")
         |> String.split(~r/From \d+/)
         |> Enum.reject(&(&1 == ""))

file = File.open!("data.csv", [:write])
IO.binwrite(file, "date,total,public,private,direct,files\n")
Enum.each(emails, fn(x) ->
  [_, day, month, year] = Regex.run(~r/Date:.* (\d{1,2}) (\w{3}) (\d{4})/, x)
  date = "#{year}-#{Map.fetch!(months, month)}-#{String.pad_leading(day, 2, "0")}"
  IO.inspect date

  [_, total] = Regex.run(~r/Your team sent a total of (\d{0,2},{0,1}\d{3}) messages last week/, x)
  total = String.replace(total, ",", "") |> String.to_integer

  [public, private, direct] = if(String.contains?(x, "private") || String.contains?(x, "group")) do
    get_messages_post_private_channels.(x)
  else
    get_messages_pre_private_channels.(x)
  end
  [_, files] = Regex.run(~r/(\d{1,3}) files/, x)
  files = String.to_integer(files)


  data = ["#{date}", total, public, private, direct, files]

  data = Enum.join(data, ",") <> "\n"
  IO.binwrite(file, data)
end)
File.close(file)
