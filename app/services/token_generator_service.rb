class TokenGeneratorService
  def self.generate
    SecureRandom.hex
  end
end