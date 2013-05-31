from xml.etree.ElementTree import ElementTree
import urllib2

class OpenStreetMapAPI:
    def __init__(self, username, password):
        passman = urllib2.HTTPPasswordMgr()
        passman.add_password("Web Password", "https://api.openstreetmap.org/api/0.6", username, password)
        authhandler =  urllib2.HTTPBasicAuthHandler(passman)
        self.opener = urllib2.build_opener(authhandler)

    def user_details(self):
        response = self.opener.open("https://api.openstreetmap.org/api/0.6/user/details")
        tree = ElementTree()
        root = tree.parse(response)
        user = root.find("user")
        return {
            "id": user.attrib["id"],
            "display_name": user.attrib["display_name"]
        }
