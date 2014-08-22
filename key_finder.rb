require "bitcoin"

DIR = "scalpel-output"
PUBKEY = "XiJaZKARUACMn69kWTbJ2XYZGh73ifwcFQ"
COIN = "darkcoin" # Only Darkcoin and Bitcoin supported, but it is easy to add others 


if COIN == "bitcoin"
  Bitcoin.network = :bitcoin
  @prefix = "01010420"
  @suffix = "A081853081820201"
elsif COIN == "darkcoin"
  Bitcoin.network = :darkcoin
  @prefix = "D70001D63081D30201010420"
  @suffix = "A08185308182020101302C06072A8648"
end

@keys = Array.new

Dir.foreach(DIR) do |folder|
  if folder.include?("key")
    Dir.foreach(DIR + '/' + folder) do |key|
      if key.include?(".key")

        file = File.open(DIR + '/' + folder + '/' + key.to_s, 'r')
        data = file.read
        hex = data.unpack('H*').first.upcase
        file.close()

        # Delete prefix
        hex.gsub!(@prefix, "")
        # Delete suffix
        hex.gsub!(@suffix, "")
        if hex.size == 64
          @keys << hex
        end
      end
    end
  end
end

p "Potential keys to test: " + @keys.count.to_s

@keys.each_with_index do |potential_key, count|
  loaded_key = Bitcoin::Key.new(potential_key)
  if PUBKEY == loaded_key.addr or PUBKEY == loaded_key.compressed_addr
    p "Found the private key!"
    p "Private Key (HEX):    #{potential_key}"
    p "Private Key (Base58): #{loaded_key.to_base58}"
  else
    p "Failed to match key ( #{loaded_key.compressed_addr} )... #{count + 1} / #{@keys.count}."
  end
  if (count + 1) == @keys.count
    p "Failed to find a match, sorry for your loss."
  end
end


