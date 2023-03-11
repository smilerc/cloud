module TSX

  class Encode

    def self.to_enc(str)
      cipher_salt1 = '12some-random-12salt-'
      cipher_salt2 = '12another-random-12salt-'
      cipher = OpenSSL::Cipher.new('AES-128-ECB').encrypt
      cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(cipher_salt1, cipher_salt2, 20_000, cipher.key_len)
      encrypted = cipher.update(str) + cipher.final
      encrypted.unpack('H*')[0].upcase
    end

    def self.from_enc(encrypted_str)
      cipher_salt1 = '12some-random-12salt-'
      cipher_salt2 = '12another-random-12salt-'
      cipher = OpenSSL::Cipher.new('AES-128-ECB').decrypt
      cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(cipher_salt1, cipher_salt2, 20_000, cipher.key_len)
      decrypted = [encrypted_str].pack('H*').unpack('C*').pack('c*')
      cipher.update(decrypted) + cipher.final
    end

  end

end