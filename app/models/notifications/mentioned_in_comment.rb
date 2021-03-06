module Notifications
  class MentionedInComment < Notification
    include Notifications::Mentioned

    def popup_translation_key
      "notifications.mentioned_in_comment"
    end

    def deleted_translation_key
      "notifications.mentioned_in_comment_deleted"
    end

    def self.filter_mentions(mentions, mentionable, _recipient_user_ids)
      people = mentionable.people_allowed_to_be_mentioned
      if people == :all
        mentions
      else
        mentions.where(person_id: people)
      end
    end

    def mail_job
      if !recipient.user_preferences.exists?(email_type: "mentioned_in_comment")
        Workers::Mail::MentionedInComment
      elsif shareable.author.owner_id == recipient_id
        Workers::Mail::CommentOnPost
      elsif shareable.participants.local.where(owner_id: recipient_id)
        Workers::Mail::AlsoCommented
      end
    end

    private

    def shareable
      linked_object.parent
    end
  end
end
