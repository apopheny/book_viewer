require 'tilt/erubis'
require "sinatra"
require "sinatra/reloader" if development?

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |pgph, idx|
      "<p id=#{idx + 1}>#{pgph}</p>"
    end.join
  end

  def relevant_paragraphs(text, query)
    hits = text.split("\n\n").map.with_index do |pgph, idx|
      {:par => pgph, :number => idx +1} if pgph.include?(query)
    end
  end

  def bold_match(text, query)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end


before do
  @contents = File.readlines './data/toc.txt'
end

not_found do
  redirect("/")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i

  redirect "/" unless (1..@contents.size).include?(number)
  @chapter = File.read("./data/chp#{number}.txt")
  @title = "Chapter #{number}: #{@contents[number - 1]}"
  
  erb :chapter
end

get "/search" do
  @text_query = params[:query]

  @search_results = (1..@contents.size).select do |chap_num|
    File.read("./data/chp#{chap_num}.txt").include?(@text_query) if @text_query
  end
  
  erb(:search)
end