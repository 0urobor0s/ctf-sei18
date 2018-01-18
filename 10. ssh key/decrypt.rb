require "openssl"
require "rsa"
pub_key = OpenSSL::PKey::RSA.new File.read('pubkey.pem')
# Use http://factordb.com/
#puts RSA::Math.factorize(pub_key.n.to_i).to_a
puts pub_key.n

p1 = 14324010958278475907
q1 = 17226484919502146417
phi = (p1 - 1) * (q1 - 1)
d = RSA::Math.modinv(pub_key.e.to_i, phi)

priv_key = OpenSSL::PKey::RSA.new 128
priv_key.set_factors(p1, q1)
priv_key.set_key(pub_key.n.to_i, pub_key.e.to_i, d)
puts priv_key.to_s
