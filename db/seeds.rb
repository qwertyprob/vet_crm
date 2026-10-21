# frozen_string_literal: true

puts "Cleaning database..."
Client.destroy_all
User.destroy_all

puts "Seeding users & clients..."

[
  { email: "ivanova@example.com",  firstname: "Анна",    lastname: "Иванова"  },
  { email: "petrov@example.com",   firstname: "Дмитрий", lastname: "Петров"   },
  { email: "sidorova@example.com", firstname: "Ольга",   lastname: "Сидорова" },
  { email: "kozlov@example.com",   firstname: "Сергей",  lastname: "Козлов"   }
].each do |data|
  user = User.create!(
    email:                 data[:email],
    password:              "password123",
    password_confirmation: "password123"
  )

  Client.create!(
    user:      user,
    firstname: data[:firstname],
    lastname:  data[:lastname]
  )

  puts "  #{data[:firstname]} #{data[:lastname]} — #{data[:email]}"
end

puts "\nDone!"
puts "  Users:   #{User.count}"
puts "  Clients: #{Client.count}"
