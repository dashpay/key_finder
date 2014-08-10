Recover Private Keys From Deleted Wallet Files
====================

In this guide we will use scalpel and a custom ruby script and gem to recover lost private keys from deleted wallet files. The first step when deciding to attempt to recover private keys from a lost wallet file is to determine which public addresses holds the coins you are interested in recovering. Once you determine this you can then attempt to extract all the private keys on a drive iterate through each private key, compute the public key and determine it if is the key you are looking for.

Install And Setup Scalpel
---------------------

Install scalpel via your package manager and open the config file:

    vim /etc/scalpel/scalpel.conf

By analyzing the wallet.dat files of Darkcoin I was able to determine that private keys are always surrounded by the following hex values. I only have found Darkcoin and Bitcoin, if you end up adding more please issue a pull request as it could be helpful for others.

Adding this line to your scalpel config will allow us to extract private keys from the drive:

BITCOIN

    key     y       128  \x01\x01\x04\x20                   \xa0\x81\x85\x30\x81\x82\x02\x01                 

DARKCOIN

    key     y       128  \xd7\x00\x01\xd6\x30\x81\xd3\x02\x01\x01\x04\x20                   \xa0\x81\x85\x30\x81\x82\x02\x01\x01\x30\x2c\x06\x07\x2a\x86\x48

Uncomment this line while leaving all the other options commented out. 

Determine which drive you lost the keys 

    df -h 

Find the drive your wallet was stored on. My primary partition is /dev/sdb1, so I will run the scalpel against that drive. Use the -o (output) flag to specify your output directory.

    mkdir ~/keys && scalpel /dev/sdb1 -o output ~/keys

Tar these files and scp them to a separate computer for analysis

    tar -cvf keys.tar.gz ~/potential_keys/
    scp keys.tar.gz user@otherserver

Analysis Of Scalpel Output
---------------------

To make the process easier I had cuztomed the bitcoin-ruby gem for a friend and added support for Darkcoin. I also modified it to allow easy output for compressed keys (the common version of the key). Add this to your gemfile:

    gem "bitcoin-ruby", :git => "https://github.com/chemicalfire/bitcoin-ruby.git"

First the provided script will extract the keys from the scalpel output to make it easier to analyze. By default it expects the folder for the scalpel output to be named "output" but you can modify the constant DIR at the top of the file to specify your own folder name. 

    DIR = "keys"

Then you will also want to set your public key you determined is holding the funds you are interested in looking for

    PUBKEY = "1NB6BCRctsjneowskMQM7Djx5GAkC9yBmy"

Then finally if you are searching darkcoins change this option to darkcoin otherwise leave it as bitcoin.

    COIN = "bitcoin"

Once all these settings are defined you can then run the key_finder.rb script and see if your private key was found by scalpel:

    bundle exec ruby key_finder.rb

If the script runs successfully, you will see it parse each key and it will end with the number of keys available readied for testing:

		"Potential keys to test: 9943"

It will then begin to load each private key and determine both the uncompressed and compressed versions of the key. 

If it succeeds in locating the key it will give you both a hex and base58 version of the key otherwise you will be prompted that the key was not found. 

Donations
---------------------

I created this to help others and I believe in free open source code so I don't expect to be paid, but if you are able to recover funds and are feeling generous, I accept donations. 

I lost 0.24 bitcoins and unfortunately was not able to recover them, and my significant other 20 lost I gifted to them in aencrypted wallet. 

I was able to recover 10,000 lost Darkcoins using this method though and was grateful it worked and wanted to share my methods with others. 

1NFk9ukkUw6w5oQ7JtaPPr2MpyQ7RkiQXC

