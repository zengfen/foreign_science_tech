class Cipher

  # @password = "DkqiwKphuc4bjT7In5JN21Dwv123aDdz"
  # @saltlen = 8
  # @keylen = 32
  # @iterations = 10002
  RandomStringKey = "DkqiwKphuc4bjT7In5JN21Dwv123aDdz"
  RandomStringIv = "psb0jvfygFakwe3O"

  def self.aes256_encrypt(text)
    cipher = OpenSSL::Cipher.new("AES-256-CFB")
    #salt = OpenSSL::Random.random_bytes(@saltlen)
    #key_iv = OpenSSL::PKCS5.pbkdf2_hmac(@password, salt, @iterations, @keylen+cipher.iv_len, "md5")
    cipher.key = RandomStringKey#key_iv[0, cipher.key_len]
    cipher.iv = RandomStringIv#key_iv[cipher.key_len, cipher.iv_len]
    cipher.encrypt
    text = cipher.update(text) + cipher.final
    #text = salt + key_iv[cipher.key_len, cipher.iv_len] + text
    Base64.encode64(text).strip
  end


  def self.aes256_decrypt(encrypted)
    data = Base64.decode64(encrypted)
    #salt = data[0,@saltlen]
    #data = data[@saltlen, data.size]
    cipher = OpenSSL::Cipher.new("AES-256-CFB")
    #key_iv = OpenSSL::PKCS5.pbkdf2_hmac(@password, salt, @iterations, @keylen+cipher.iv_len, "md5")
    cipher.key = RandomStringKey#key_iv[0, cipher.key_len]
    cipher.iv = RandomStringIv#key_iv[cipher.key_len, cipher.iv_len]
    cipher.decrypt
    data = cipher.update(data) + cipher.final
    #data[cipher.iv_len, data.size]
  end


end
