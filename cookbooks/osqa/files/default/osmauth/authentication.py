from forum.authentication.base import AuthenticationConsumer, ConsumerTemplateContext, InvalidAuthentication
from forms import OpenStreetMapLoginForm

class OpenStreetMapAuthConsumer(AuthenticationConsumer):
    def process_authentication_request(self, request):
        form_auth = OpenStreetMapLoginForm(request.POST)

        if form_auth.is_valid():
            request.session["auth_consumer_data"] = form_auth.get_user_data()
            return form_auth.get_user()
        else:
            raise InvalidAuthentication(" ".join(form_auth.errors.values()[0]))

    def get_user_data(self, key):
        return {}

class OpenStreetMapAuthContext(ConsumerTemplateContext):
    mode = 'TOP_STACK_ITEM'
    weight = 0
    human_name = 'OpenStreetMap Login'
    stack_item_template = 'modules/osmauth/loginform.html'
