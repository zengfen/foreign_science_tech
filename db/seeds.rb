# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if User.where(email: ENV["USER_NAME"]).blank?
  User.create(email: ENV["USER_NAME"], name: ENV["USER_NAME"], password: ENV["USER_PASSWORD"])
end







