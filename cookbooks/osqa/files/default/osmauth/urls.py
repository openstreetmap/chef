from django.conf.urls.defaults import *
from django.views.generic.simple import direct_to_template
from django.utils.translation import ugettext as _
import views as app

urlpatterns = patterns('',
    url(r'^%s%s%s$' % (_('account/'), _('openstreetmap/'),  _('register/')), app.register, name='auth_openstreetmap_register'),
)
