# init
require 'ardes/response_for_rc/actions'
require 'ardes/response_for_rc/singleton_actions'

Ardes::ResourcesController.actions = Ardes::ResponseForRc::Actions
Ardes::ResourcesController.singleton_actions = Ardes::ResponseForRc::SingletonActions