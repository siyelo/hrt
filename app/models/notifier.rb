# app/models/notifier.rb
class Notifier < ActionMailer::Base
  #default_url_options[:host] = "resourcetracking.heroku.com"
  FROM = "HRT Notifier <hrt-do-not-reply@hrtapp.com>"
  default from: FROM, date: Time.now

  def comment_notification(comment, users)
    @comment = comment

    mail(
      subject: "[Health Resource Tracker] A Comment Has Been Made",
      to: users.map(&:email)
    )
  end

  def send_user_invitation(user, inviter)
    @full_name = user.full_name
    @org = user.organization
    @invite_token = user.invite_token
    @follow_me = "#{edit_invitation_url(user.invite_token)}"
    @sys_admin_org = inviter.organization ? "(#{inviter.organization.try(:name)})" : ''
    @inviter_name = inviter.full_name ||= inviter.email

    mail(
      subject: "[Health Resource Tracker] You have been invited to HRT",
      to: user.email
    )
  end

  def response_rejected_notification(response)
    mail(
      subject: "Your #{response.title} response is Rejected",
      to: response.organization.users.map(&:email)
    )
  end

  def response_accepted_notification(response)
    mail(
      subject: "Your #{response.title} response is Accepted",
      to: response.organization.users.map(&:email)
    )
  end

  def response_restarted_notification(response)
    mail(
      subject: "Your #{response.title} response is Restarted",
      to: response.organization.users.mapmap(&:email)
    )
  end

  def report_download_notification(user, report)
    @report = report
    mail(
      subject: "Download link for your report",
      to: user.email
    )
  end

  def workplan_download_notification(user)
    mail(
      subject: "Download link for your workplan",
      to: user.email
    )
  end
end
