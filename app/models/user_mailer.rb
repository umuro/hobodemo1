class UserMailer < ActionMailer::Base
  
  def forgot_password(user, key)
    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host
    @subject    = "#{app_name} -- forgotten password"
    @body       = { :user => user, :key => key, :host => host, :app_name => app_name }
    @recipients = user.email_address
    @from       = "no-reply@#{host}"
    @sent_on    = Time.now
    @headers    = {}
  end

  def invite_user(invitor, recipient_address, key)

    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host

    invitee = User.find_by_email_address(recipient_address)
    activation_url = user_accept_invitation_url :host => host, :id => invitee, :key => key

    @subject    = "#{app_name} -- Become a member"
    @from       = "no-reply@#{host}"
    @recipients = recipient_address
    @body       = {:activation_url => activation_url, :app_name => app_name}
    @sent_on    = Time.now
  end

  def signup_activation(email_address, key)

    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host

    user = User.find_by_email_address(email_address)
    activation_url = user_activate_signup_url :host => host, :id => user, :key => key

    @subject    = "#{app_name} -- Activate your account"
    @from       = "no-reply@#{host}"
    @recipients = email_address
    @body       = {:activation_url => activation_url, :app_name => app_name}
    @sent_on    = Time.now
  end

  def crew_membership_invitation(membership, key)

    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host

    crew = membership.joined_crew
    invitee_email = membership.invitee.email_address

    cm_accept_url = crew_membership_accept_url :host => host, :id => membership.id, :key => key
    cm_ignore_url = crew_membership_ignore_url :host => host, :id => membership.id, :key => key

    @subject    = "#{app_name} -- #{crew.name} crew membership invitation"
    @from       = "no-reply@#{host}"
    @recipients = invitee_email
    @body       = {:activation_url => cm_accept_url, :ignore_url => cm_ignore_url, 
                   :crew_name => crew.name, :app_name => app_name}
    @sent_on    = Time.now
  end

  def crew_membership_accepted(membership)
    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host

    crew = membership.joined_crew
    invitee = membership.invitee
    owner = membership.owner

    @subject    = "#{app_name} -- #{crew.name} membership accepted"
    @from       = "no-reply@#{host}"
    @recipients = owner.email_address
    @body       = {:app_name => app_name, :crew_name => crew, :invitee_email => invitee.email_address}
    @sent_on    = Time.now
  end

  def crew_membership_ignored(membership)
    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host

    crew = membership.joined_crew
    invitee = membership.invitee
    owner = membership.owner

    @subject    = "#{app_name} -- #{crew.name} membership ignored"
    @from       = "no-reply@#{host}"
    @recipients = owner.email_address
    @body       = {:app_name => app_name, :crew_name => crew.name, :invitee_email => invitee.email_address}
    @sent_on    = Time.now
  end

  def event_enrollment_rejected(enrollment)
    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host

    event = enrollment.event
    event_name = event.name
    event_place = event.place
    event_start = event.start_time
    enroller = enrollment.owner.email_address
    motivation = enrollment.admin_comment

    @subject    = "#{app_name} -- #{enrollment.event.name} enrollment rejected"
    @from       = "no-reply@#{host}"
    @recipients = enroller
    @body       = {:app_name => app_name, :event_name => event_name, :event_place=>event_place,
                   :event_start => event_start, :motivation=>motivation}
    @sent_on    = Time.now
  end

  def event_enrollment_accepted(enrollment)
    host = Hobo::Controller.request_host
    app_name = Hobo::Controller.app_name || host

    event = enrollment.event
    event_name = event.name
    event_place = event.place
    event_start = event.start_time
    enroller = enrollment.owner.email_address

    @subject    = "#{app_name} -- #{enrollment.event.name} enrollment accepted"
    @from       = "no-reply@#{host}"
    @recipients = enroller
    @body       = {:app_name => app_name, :event_name => event_name, :event_place=>event_place,
                   :event_start => event_start}
    @sent_on    = Time.now
  end
  
end