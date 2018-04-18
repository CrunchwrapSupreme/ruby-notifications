#require "notifications/version"
require "dbus"
require "timeout"

module Notifications
  NOTIF_SERVICE = 'org.freedesktop.Notifications'
  NOTIF_OBJECT = '/org/freedesktop/Notifications'
  VALID_CAPABILITIES = [ 'action-icons', 'actions', 'body', 'body-hyperlinks', 'body-images',
                         'body-markup', 'icon-multi', 'icon-static', 'persistence', 'sound' ]
  VALID_CAPABILITIES.sort!
  NOTIF_SERVICE.freeze
  NOTIF_OBJECT.freeze
  VALID_CAPABILITIES.freeze
  TIMEOUT = 5

  class NotificationDaemonError < RuntimeError
    def initialize
      super "Notification daemon not implemented or unavailable."
    end
  end

  class CommandNotImplementedError < NoMethodError
    def initialize(command="Command")
      super "#{msg} not implemented by the #{Notifications.NOTIF_SERVICE} service."
    end
  end

  class ObjectIntrospectionError < NoMethodError
    def initialize
      super "Object not introspected. Introspect before calling proxy methods."
    end
  end

  class NotificationService
    attr_reader :bus, :service

    def service_object
      @service_obj
    end

    def introspected?
      @service_obj.introspected
    end

    def capabilities
      @capabilities ||= try_to { @service_obj.GetCapabilities }
      @capabilities
    end

    def initialize
      @bus = DBus::SessionBus.instance
      @service = @bus.service Notifications::NOTIF_SERVICE
      @service_obj = @service.object Notifications::NOTIF_OBJECT


      if not @service.exists? then
        raise NotificationDaemonError.new
      end


      @service_obj.define_singleton_method(:method_missing) do |name, *args, &block|
        if not self.introspected then
          raise ObjectIntrospectionError
        else
          raise CommandNotImplementedError name.to_s
        end
      end

      @supports = {}
    end

    def try_introspect
      begin
        try_to { @service_obj.introspect }
        true
      rescue
        false
      end
    end

    #returns values of attributes mapped to @supports
    def method_missing(name, *args)
      raise NoMethodError unless args.length == 0 and not block
      m_data = name.match /^supports_([a-zA-Z]+)\?$/
      raise NoMethodError unless m_data and m_data[1]
      ( val = @supports[m_data[1]] ) and Notifications::VALID_CAPABILITIES.include?(m_data[1]) ? val : false
    end

    #returns notification after run
    def send_notification(notify_temp, replace_previous=false)
      ( replace_previous and notify_temp.id > 0 ) ? r_id = notify_temp.id : r_id = 0

      id = try_to {
        @service_obj.Notify( notify_temp.appname, r_id, notify_temp.icon, notify_temp.summary,
                             notify_temp.body, notify_temp.actions.pack, notify_temp.hints,
                             notify_temp.timeout )[0]
      }

      if not replace_previous then
        notify_temp = notify_temp.clone
      end

      notify_temp.id = id
      @last_notify = notify_temp
      notify_temp
    end

    def close_notification(notify_temp=nil)
      if notify_temp then
        close = notify_temp
      elsif @last_notify
        close = @last_notify
      else
        return -1
      end

      try_to { @service_obj.CloseNotification(close.id)[0] }
    end

    def get_server_info
      try_to { @service_obj.GetServerInformation }
    end

    private
    def try_to(&block)
      Timeout::timeout(TIMEOUT) { block.call }
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

    def [](id)
      @action_list[id]
    end

    def length
      @action_list.length
    end

    def pack
      al = @action_list.map do |action|
        action.normalize
      end

      al.flatten!
      al
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
