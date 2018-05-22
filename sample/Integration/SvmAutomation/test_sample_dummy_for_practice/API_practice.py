import requests
import json



class sample():

    def get_dashboard_items(self):
        url = 'https://uat.app.flexerasoftware.com/api/v1/dashboard-items/'
        token = 'cd6459d7cc4fe7c2f802f446f0fbc55001eb8fb7'
        head = {'Authorization':'token {}'.format(token)}
        r = requests.get(url, headers=head)
        print (r.status_code)
        # print (r.headers)
        our_response = r.json()
        # print (our_response)

        # print(r.raw)
        # print(r.text)
        # print (r.elapsed)

        # for data in our_response:
        #     self.titles = data.get('title')
        #     print(self.titles)

    def post_create_watchlist(self):
        payload = {"name":"anusha123_edited1234","enabled":"true",
                   "advisories_need_approval":"false",
                   "receive_all":"false","vendors":[3217],"products":[117686],"product_releases":[146072],
                   "ticket_threshold_level":5,"notification_level_email":5,"notification_level_sms":1}
        url = 'https://uat.app.flexerasoftware.com/api/asset-lists/'
        token = 'cd6459d7cc4fe7c2f802f446f0fbc55001eb8fb7'
        head = {'Authorization': 'token {}'.format(token)}
        r = requests.post(url, json=payload, headers=head)
        print (r.status_code)
        print (r.json())
        print(r.elapsed)


if __name__ == '__main__':
    sample().post_create_watchlist()