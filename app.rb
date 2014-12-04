require "sinatra"
require "pony"
require "data_mapper"

DataMapper::setup(:default,
                  ENV["DATABASE_URL"] || "sqlite://#{Dir.pwd}/rating.db")

class Rating
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :email, String
  property :design, Integer
  property :content, Integer
  property :speed, Integer
  property :overall, Integer
end

Rating.auto_upgrade!  #will access or create entries


get "/" do
  erb :index, layout: :default
  #block
end

get "/rate" do
  erb :rate, layout: :default
end

get "/all_ratings" do
  @ratings = Rating.all
  @good_ratings = @ratings.select { |rating| rating.overall > 3 }
  @bad_ratings = @ratings - @good_ratings
  erb :all_ratings, layout: :default
end


post "/rating" do

  Rating.create(name: params[:name],
                 email: params[:email],
                 design: params[:design],
                 content: params[:content],
                 speed: params[:speed],
                 overall: params[:overall],
                 )

  Pony.mail(to: "cameljeet@hotmail.com",
        from: params[:email],
        reply_to: params[:email],
        subject: "#{params[:name]} has rated your site",
        body: "I gave you these ratings
              Design: #{params[:design]}
              Content: #{params[:content]}
              Speed: #{params[:speed]}
              Overall: #{params[:overall]}",
        via: :smtp,
        via_options: {
          address: "smtp.gmail.com",
          port: "587",
          user_name: "answerawesome",
          password: "PASSWORD",
          authentication: :plain,
          enable_startls_auto: true
          })
  params.to_s
  erb :thank_you, layout: :default
end