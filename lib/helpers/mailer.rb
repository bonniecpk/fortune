module Fortune
  class Mailer
    class << self
      def send(opts = {})
        subject = opts[:subject]
        content = opts[:content]

        Pony.mail({
          from:      'exchange@pchui.me',
          to:        'poki.developer@gmail.com',
          subject:   subject,
          html_body: content,
          via:       :smtp,
          via_options: {
            port:    ENV["SMTP_PORT"] ? ENV["SMTP_PORT"] : 25,
            enable_starttls_auto: false
          }
        })
      end
    end
  end
end
