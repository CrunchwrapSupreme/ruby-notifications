require "notifications/version"

module Notifications
  NOTIF_SERVICE = 'org.freedesktop.Notifications'
  NOTIF_OBJECT = "/org/freedesktop/Notifications"

  class NotificationService
    def initialize(template = nil)
      @bus = DBus::SessionBus.instance
      @service = @bus.service Notifications::NOTIF_SERVICE
      @service_obj = @service.object(Notifications::NOTIF_OBJECT)
      @supports = {}
      capabilities = @service_obj.GetCapabilities
      if capabilities then
        capabilities.each do |string|
          @supports[string] = true
        end
      end
    end

    #returns values of attributes mapped to @supports
    def method_missing(name, *args, &block)
      raise NoMethodError unless args.length == 0 and not block
      m_data = name.match /^supports_([a-zA-Z]+)\?$/
      raise NoMethodError unless m_data
      val = @supports[m_data[1]] ? val : false
    end

    #returns notification after run
    def send_notification(notify_temp, replace_previous=false)
      (replace_previous and notify_temp.id > 0) ? r_id = notify_temp.id : r_id = 0

      id = @service_obj.Notify(notify_temp.appname, r_id
                          notify_temp.app_icon, notify_temp.summary,
                          notify_temp.body, notify_temp.actions.pack,
                          notify_temp.hints, notify_temp.timeout)

      notify_temp.id = id
      notify_temp
    end

    def close_notification(notify_temp)
      @service_obj.CloseNotification(notify_temp.id)
    end

    def get_server_info
      @service_obj.GetServerInformation
    end
  end

  class Action
    attr_accessor :action, :action_string, :callback

    def initialize(action, action_string, callback = nil)
      @action = action
      @action_string = action_string
      @callback = callback
    end

    def normalize
      [@action, @action_string]
    end
  end

  class ActionList
    def initialize(action_list = [])
      @action_list = action_list
    end

    def <<(action)
      @action_list << action
    end

    def pack
      al = action_list.map do |action|
        action.normalize
      end

      al.flatten!
    end
  end

  class Notification
    attr_accessor :actions, :icon, :body, :summary, :hints, :timeout, :id, :appname

    def initialize(icon: '', body: '', summary: '', hints: {}, timeout: -1, appname:)
      @actions = ActionList.new
      @icon = icon
      @body = body
      @summary = summary
      @hints = hints
      @timeout = timeout
      @id = nil
      @appname = appname
    end

    def register_action(action:)
      @actions << action
    end
  end
end
