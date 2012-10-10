class SearchController < BaseController
  def search
    @names = set_names
    @search = []
    where_to_search = [Post, Topic, Forum, SbPost]
    where_to_search.each do |s|
      add_search s
    end
    @results = @search
  end

  def add_search klass
    new_search = klass.solr_search do
      fulltext params[:q].to_s
    end
    @search = @search + new_search.results.map{|o| parse_result(o)}
  end

  def set_names
    {:post => "Article", :forum => "Forum", :topic => "Discussion (Forum)", :sbpost => "Message (Forum)"}
  end

  def parse_result(object)
    ret = HashWithIndifferentAccess.new
    if object.is_a?(Post)
      ret[:title] = object.title
      ret[:content] = object.post
      ret[:owner] = object.user
      ret[:route] = [object.user, object]
    elsif object.is_a?(Forum)
      ret[:title] = object.name
      ret[:content] = object.description
      ret[:owner] = object.owner
      ret[:route] = object
    elsif object.is_a?(Topic)
      ret[:title] = object.title
      ret[:content] = object.title
      ret[:owner] = object.user
      ret[:route] = [object.forum, object]
    elsif object.is_a?(SbPost)
      ret[:title] = "Discussion: #{object.topic.title}"
      ret[:content] = object.body
      ret[:owner] = object.author_name
      ret[:route] = [object.topic.forum, object.topic, object]
    end
    ret[:origin] = object
    ret
  end
end
