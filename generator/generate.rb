require 'open-uri'
require 'json'


def get(key)
  lambda { |s| s[key].empty? ? nil : s[key] }
end

class SessionPresenter
  def initialize(session)
    @session = session
  end

  def filename
    [
      @session['title'].gsub(/\s+/, '-'),
      ('keynote' == @session['category']) ? 'Keynote' : '',
      '.md',
    ].join
  end

  def name
    @session['name']
  end

  def abstract
    @session['abstract']
  end
end

# ["title", "abstract", "name", "bio", "starts_at", "ends_at", "category", "room"] 
title = get('title')
author = get('name')
space = get('room')
desc = get('abstract')
time = get('starts_at')


list = lambda { |items| items.map { |i| "* #{i}" } }
future = lambda { |sess| time[sess] > (Time.now - (45 * 60)) }


# Categories:
# keynote standard products intro external break 'exhibit hall' bohconf
summary = lambda { |sess|
  case sess['category']
    when 'keynote'
    ["Keynote: #{title[sess]}", space[sess]]
    when 'standard'
    [title[sess], author[sess], space[sess]]
    when 'products'
    ["Product: #{title[sess]}", author[sess], space[sess]]
    when 'intro'
    [title[sess], author[sess], space[sess]]
    when 'external'  # Ignite, KidsRuby
    [author[sess], space[sess]]
    when 'break'
    [title[sess]]
    when 'exhibit hall'
    [title[sess]]
    when 'bohconf'
    [title[sess]]
  end.compact.join(', ')
}


sessions = open('http://railsconf2012.com/sessions.json') { |f| JSON.parse(f.read) }


moustache = File.read('Template.md.moustache')



=begin
sessions.group_by(&time).sort_by(&:first).each do |time, ss|
  puts
  puts Time.parse(time).strftime('%Y-%m-%d %H:%M')
  puts list[ss.map(&summary)]
end
=end