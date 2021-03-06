Template.message.helpers

	own: ->
		return 'own' if this.u?._id is Meteor.userId()

	time: ->
		return moment(this.ts).format('HH:mm')

	date: ->
		return moment(this.ts).format('LL')

	body: ->
		switch this.t
			when 'r'  then t('Room_name_changed', { room_name: this.msg, user_by: this.u.username })
			when 'au' then t('User_added_by', { user_added: this.msg, user_by: this.u.username })
			when 'ru' then t('User_removed_by', { user_removed: this.msg, user_by: this.u.username })
			when 'ul' then t('User_left', { user_left: this.u.username })
			when 'nu' then t('User_added', { user_added: this.u.username })
			when 'uj' then t('User_joined_channel', { user: this.u.username })
			when 'wm' then t('Welcome', { user: this.u.username })
			else
				this.html = this.msg
				if _.trim(this.html) isnt ''
					this.html = _.escapeHTML this.html
				message = RocketChat.callbacks.run 'renderMessage', this
				this.html = message.html.replace /\n/gm, '<br/>'
				return this.html

	system: ->
		return 'system' if this.t in ['s', 'p', 'f', 'r', 'au', 'ru', 'ul', 'nu', 'wm', 'uj']


Template.message.onViewRendered = (context) ->
	view = this
	this._domrange.onAttached (domRange) ->
		lastNode = domRange.lastNode()
		if lastNode.previousElementSibling?.dataset?.date isnt lastNode.dataset.date
			$(lastNode).addClass('new-day')
			$(lastNode).removeClass('sequential')
		else if lastNode.previousElementSibling?.dataset?.username isnt lastNode.dataset.username
			$(lastNode).removeClass('sequential')

		if lastNode.nextElementSibling?.dataset?.date is lastNode.dataset.date
			$(lastNode.nextElementSibling).removeClass('new-day')
			$(lastNode.nextElementSibling).addClass('sequential')
		else
			$(lastNode.nextElementSibling).addClass('new-day')
			$(lastNode.nextElementSibling).removeClass('sequential')

		if lastNode.nextElementSibling?.dataset?.username isnt lastNode.dataset.username
			$(lastNode.nextElementSibling).removeClass('sequential')

		ul = lastNode.parentElement
		wrapper = ul.parentElement

		if context.urls?.length > 0
			for url in context.urls
				do (url) ->
					Meteor.call 'iframely.oembed', url, (error, data) ->
						height = lastNode.clientHeight

						urlNode = lastNode.querySelector('.body a[href="'+url+'"]')
						urlNode?.innerHTML = Blaze.toHTMLWithData Template.iframelyBaseWidget, data

		if not lastNode.nextElementSibling?
			if lastNode.classList.contains('own') is true
				view.parentView.parentView.parentView.parentView.parentView.templateInstance().atBottom = true
			else
				if view.parentView.parentView.parentView.parentView.parentView.templateInstance().atBottom isnt true
					newMessage = document.querySelector(".new-message")
					newMessage.className = "new-message"
