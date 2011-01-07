security = YAML.load_file(File.join(RAILS_ROOT, 'config', 'xml_encryption.yml'))
$SECURITY = {}

class Secure
  attr_accessor :encryption
  attr_accessor :password
  
  def initialize encryption, password
    self.encryption = encryption
    self.password = password
  end
  
  def encrypt data
    enc = OpenSSL::Cipher::Cipher.new encryption
    enc.encrypt.pkcs5_keyivgen password
    data = enc.update data; data << enc.final
    data
  end

  def decrypt data
    dec = OpenSSL::Cipher::Cipher.new encryption
    dec.decrypt.pkcs5_keyivgen password
    data = dec.update data; data << dec.final
    data
  end
end


for key, value in security
  $SECURITY[key.to_sym] = Secure.new 'blowfish', value
end
