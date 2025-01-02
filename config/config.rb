ROOT = "#{File.dirname(__FILE__)}/.."
$stdout.sync = true
CLOUDINARY_CLOUD_NAME = 'du6que5iy'
CLOUDINARY_API_KEY = '398891255677959'
CLOUDINARY_SECRET = 'MfhbP_H1zf4TNIhAR2XFZypk1bU'

PDO_DOMAIN = ENV['production'] == 'yes' ? 'pdo-b93347e0424d.herokuapp.com' : 'pdo.ngrok.io'
API_DOMAIN = ENV['production'] == 'yes' ? 'nash-c6dd440834c0.herokuapp.com' : 'nash2.ngrok.io'
