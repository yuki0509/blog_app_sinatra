require 'rubygems'
require 'bundler'

Bundler.require

set :database, {adapter: "sqlite3", database: "blogs.sqlite3"}
enable :sessions
enable :method_override 

class Blog < ActiveRecord::Base
    validates_presence_of :title
    validates_presence_of :content

    belongs_to :category
end

class Category < ActiveRecord::Base
    has_many :blogs
end

get '/' do
    @blogs = Blog.all
    @message = session.delete :message
    @delete = session.delete :delete
    @update = session.delete :update
    
    erb :index
end

get '/about_me' do
    erb :about_me
end

get '/new' do
    @blog = Blog.new
    @categories = Category.all
    erb :new
end

post '/create' do
    blog_title = params[:title]
    puts params
    @blog = Blog.new(title:params[:title], content:params[:content], category_id:params[:category])
    if @blog.save
        session[:message] = "「#{blog_title}」の記事が書かれました。"
        redirect '/'
    else
        erb :new
    end 
end

get '/show/:id' do
    @blog = Blog.find(params[:id])
    erb :show
end

get '/edit/blogs/:id' do
    @blog = Blog.find(params[:id])
    @categories = Category.all
    erb :edit
end


put '/update/:id' do
    @blog = Blog.find(params[:id])
    edit_success = @blog.update(title:params[:title], content:params[:content], category_id: params[:category])
    if edit_success
        session[:update] = "更新しました"
        redirect '/'
    else
        render :edit
    end
    
end

post '/destroy/:id' do
    @blog = Blog.find(params[:id]).destroy
    session[:delete] = "削除しました。"
    redirect '/'
end


get '/category_new' do
    category = Category.new
    erb :category_new
end

post '/category_create' do
    category_name = params[:name]
    @category = Category.new(name:params[:name])
    if @category.save
        session[:message] = "「#{category_name}」のカテゴリが追加されました。"
        redirect '/'
    else
        erb :category_new
    end 
end