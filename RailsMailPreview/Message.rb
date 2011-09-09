#
#  Message.rb
#  RailsMailPreview
#
#  Created by Fernando Barajas on 8/20/11.
#  Copyright 2011 Fernando Barajas. All rights reserved.
#

class Message < FBDatabaseBase
  field :id,  :type => 'Integer'
  field :from
  field :subject
  field :date
  field :to
  field :cc
  field :reply_to
  field :html
  field :text
  field :timestamp
  has_many :attachments

  def setMessage(mail)
    self.from     = mail.from.to_a.join(" ,")
    self.to       = mail.to.to_a.join(", ")
    self.cc       = mail.cc.to_a.join(", ")
    self.reply_to = mail.reply_to.to_a.join(", ")
    self.subject  = mail.subject.to_s
    self.date     = mail.date.to_s
    self.html     = mail.html_part ? mail.html_part.body.to_s : ""
    self.text     = mail.text_part ? mail.text_part.body.to_s : ""

    mail.attachments.each do |attch|
      attachment = Attachment.new
      attachment.filename     = attch.filename.to_s.tr("/", "_")
      attachment.mime_type    = attch.mime_type
      attachment.data         = attch.body.to_s
      attachment.disposition  = attch.inline? ? "inline" : "attachment"
      self.attachments << attachment
    end
  end

  def brief
    txt = self.trim_text(self.text)
    if txt.size > 0
      txt
    else
      self.trim_text(self.html.flattenHTML)
    end
  end

  def trim_text(txt)
    txt.to_s.gsub(/\n|\r|\t|\s+|\-/, " ").gsub(/\s{2,}/, " ")[0..120].strip
  end

  def self.delete_at_index(id)
    item = find_by_id(id)
    if item
      item.attachments.each do |attachment|
        attachment.destroy!
      end
      super(id)
    end
  end
end
