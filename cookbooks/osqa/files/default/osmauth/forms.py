from osm import OpenStreetMapAPI
from forum.forms import NextUrlField, UserNameField, SetPasswordForm
from django.utils.translation import ugettext as _
from django import forms

class OpenStreetMapLoginForm(forms.Form):
    """ osm account signin form """
    next = NextUrlField()
    username = UserNameField(required=False, skip_clean=True)
    password = forms.CharField(max_length=128,
                               widget=forms.widgets.PasswordInput(attrs={'class':'required login'}),
                               required=False)

    def __init__(self, data=None, files=None, auto_id='id_%s',
                 prefix=None, initial=None):
        super(OpenStreetMapLoginForm, self).__init__(data, files, auto_id,
                                                     prefix, initial)
        self.user_details = None

    def _clean_nonempty_field(self, field):
        value = None
        if field in self.cleaned_data:
            value = self.cleaned_data[field].strip()
            if value == '':
                value = None
        self.cleaned_data[field] = value
        return value

    def clean_username(self):
        return self._clean_nonempty_field('username')

    def clean_password(self):
        return self._clean_nonempty_field('password')

    def clean(self):
        error_list = []
        username = self.cleaned_data['username']
        password = self.cleaned_data['password']

        self.user_details = None
        if username and password:
            api = OpenStreetMapAPI(username, password)

            try:
                self.user_details = api.user_details()
            except:
                del self.cleaned_data['username']
                del self.cleaned_data['password']
                error_list.insert(0, (_("Please enter valid username and password "
                "(both are case-sensitive).")))
                error_list.insert(0, _('Login failed.'))

        elif password == None and username == None:
            error_list.append(_('Please enter username and password'))
        elif password == None:
            error_list.append(_('Please enter your password'))
        elif username == None:
            error_list.append(_('Please enter user name'))
        if len(error_list) > 0:
            self._errors['__all__'] = forms.util.ErrorList(error_list)

        return self.cleaned_data

    def get_user(self):
        """ get authenticated user """
        return "http://www.openstreetmap.org/user/%s" % self.user_details["id"]

    def get_user_data(self):
        """ get user data for authenticated user """
        return {
            "username": self.user_details["display_name"]
        }
