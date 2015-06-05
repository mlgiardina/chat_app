class Chatroom < ActiveRecord::Base
  def get(params)
    response_code = "200"
    search_query = {}

    params.each do |k, v|
      search_query[k] = v if k == "id" || k == "name" || k == "current_users" || k == "message_count" || k == "contents"
    end

    response = Chatroom.where(search_query)
    response = response.first if response.size == 1

    [response, response_code]
  end

  def join(user_id)
    response_code = "200"
    user_name = User.find(user_id).name
    if !self.current_users.split("░").include?(user_name)
      self.current_users += user_name + "░"
      self.save
      [self, response_code]
    else
      ["#{user_name} has already joined #{self.name}", response_code]
    end
  end

  def get_contents
    response_code = "200"
    contents_hash = {}
    contents_hash[:user_history] = []
    contents_hash[:message_history] = []
    contents_split2 = []
    contents_split1 = self.contents.split("▓")
    contents_split1.each do |pairs_w_ids|
      contents_split2 << pairs_w_ids.split("▒")
    end

    contents_split2.each do |array|
      contents_hash[:user_history] <<  array[0].split("░").first
      contents_hash[:message_history] << array[1].split("░").first
    end

    [contents_hash, response_code]
  end

  def get_recent_contents(recent_timespan)
    current_time = Time.new
    cutoff_time = current_time - recent_timespan
    response_code = "200"
    contents_hash = {}
    contents_hash[:user_history] = []
    contents_hash[:message_history] = []
    contents_split2 = []
    contents_split1 = self.contents.split("▓")
    contents_split1.each do |pairs_w_ids|
      contents_split2 << pairs_w_ids.split("▒")
    end

    contents_split2.each do |array|
      message_id = array[1].split("░").last.to_i
      message_time = Message.find(message_id).created_at
      next if message_time < cutoff_time
      contents_hash[:user_history] <<  array[0].split("░").first
      contents_hash[:message_history] << array[1].split("░").first
    end

    [contents_hash, response_code]
  end

  def new_message(current_user, new_message)
    response_code = "200"
    self.message_count += 1
    self.contents += current_user.name + "░" + current_user.id.to_s + "▒" + new_message.body + "░" + new_message.id.to_s + "▓"
    self.save
    [self, response_code]
  end
end

